// lib/main.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: AsteroidBlasterGame()),
    ),
  ));
}

enum PowerUpType {
  rapidFire,
  shield,
  multiShot,
  tripleShot,
  homingMissiles,
  laserBeam,
  extraLife,
  slowMotion,
  magneticBullets,
  piercing,
}

class PowerUpInfo {
  final PowerUpType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const PowerUpInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<PowerUpInfo> allPowerUps = [
  PowerUpInfo(type: PowerUpType.rapidFire, name: "Rapid Fire", description: "Faster shooting", icon: Icons.flash_on, color: Colors.yellow),
  PowerUpInfo(type: PowerUpType.shield, name: "Shield", description: "Temporary protection", icon: Icons.security, color: Colors.blue),
  PowerUpInfo(type: PowerUpType.multiShot, name: "Multi Shot", description: "Triple bullets", icon: Icons.multiple_stop, color: Colors.green),
  PowerUpInfo(type: PowerUpType.tripleShot, name: "Triple Beam", description: "Five parallel beams", icon: Icons.view_stream, color: Colors.purple),
  PowerUpInfo(type: PowerUpType.homingMissiles, name: "Homing", description: "Bullets track targets", icon: Icons.gps_fixed, color: Colors.red),
  PowerUpInfo(type: PowerUpType.laserBeam, name: "Laser Beam", description: "Continuous damage beam", icon: Icons.linear_scale, color: Colors.cyan),
  PowerUpInfo(type: PowerUpType.extraLife, name: "Extra Life", description: "Gain one life", icon: Icons.favorite_border, color: Colors.pink),
  PowerUpInfo(type: PowerUpType.slowMotion, name: "Slow Motion", description: "Slows time briefly", icon: Icons.slow_motion_video, color: Colors.indigo),
  PowerUpInfo(type: PowerUpType.magneticBullets, name: "Magnetic", description: "Bullets attract to targets", icon: Icons.attractions, color: Colors.orange),
  PowerUpInfo(type: PowerUpType.piercing, name: "Piercing", description: "Bullets go through asteroids", icon: Icons.arrow_forward, color: Colors.amber),
];

class Asteroid {
  Offset pos;
  double radius;
  double speed; // pixels per second
  double rotation; // radians
  double rotationSpeed;

  Asteroid({
    required this.pos,
    required this.radius,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class Bullet {
  Offset pos;
  double speed;
  bool isPiercing;
  int piercingCount;

  Bullet({
    required this.pos, 
    required this.speed,
    this.isPiercing = false,
    this.piercingCount = 0,
  });
}

class PowerUp {
  Offset pos;
  double speed;
  PowerUpType type;
  int health;

  PowerUp({
    required this.pos,
    required this.speed,
    required this.type,
    this.health = 2, // Requires 2 shots to collect
  });
}

class Particle {
  Offset pos;
  Offset velocity;
  Color color;
  double size;
  double life;
  double maxLife;

  Particle({
    required this.pos,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
    required this.maxLife,
  });
}

class AsteroidBlasterGame extends StatefulWidget {
  const AsteroidBlasterGame({Key? key}) : super(key: key);

  @override
  _AsteroidBlasterGameState createState() => _AsteroidBlasterGameState();
}

class _AsteroidBlasterGameState extends State<AsteroidBlasterGame>
    with SingleTickerProviderStateMixin {
  // Screen
  Size _size = Size.zero;
  final FocusNode _focusNode = FocusNode();

  // Ship
  late double shipX; // center x coordinate
  final double shipWidth = 60;
  final double shipHeight = 40;
  final double shipYMargin = 30; // distance from bottom

  // Game objects
  final List<Asteroid> asteroids = [];
  final List<Bullet> bullets = [];
  final List<PowerUp> powerUps = [];
  final List<Particle> particles = [];

  // Game loop
  late final AnimationController _controller;
  late DateTime _lastTick;

  // Spawning
  Timer? _spawnTimer;
  Timer? _powerUpTimer;
  final Random _rnd = Random();

  // State
  int score = 0;
  int lives = 3;
  bool running = false;
  bool paused = false;
  bool started = false;

  // Powerup selection system
  bool showPowerUpSelection = false;
  Set<PowerUpType> selectedPermanentPowerUps = {};
  Set<PowerUpType> temporaryActivePowerUps = {};
  Map<PowerUpType, Timer?> powerUpTimers = {};

  // Shooting
  double shootCooldown = 0;
  final double normalShootInterval = 0.3;
  final double rapidShootInterval = 0.1;

  // Difficulty
  double baseSpawnInterval = 1.0; // seconds - slightly harder due to permanent powerups
  double lastDifficultyIncreaseScore = 0;
  double timeScale = 1.0; // For slow motion effect

  // High scores
  List<int> highScores = [];
  SharedPreferences? _prefs;

  // Keyboard input
  final Set<LogicalKeyboardKey> _keysPressed = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(days: 365));
    _controller.addListener(_tick);
    _lastTick = DateTime.now();
    _loadHighScores();
    
    // Request focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _powerUpTimer?.cancel();
    for (var timer in powerUpTimers.values) {
      timer?.cancel();
    }
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHighScores() async {
    _prefs = await SharedPreferences.getInstance();
    final scores = _prefs?.getStringList('highScores');
    if (scores != null) {
      highScores = scores.map(int.parse).toList();
    }
    setState(() {});
  }

  Future<void> _saveHighScore() async {
    highScores.add(score);
    highScores.sort((a, b) => b.compareTo(a));
    highScores = highScores.take(5).toList(); // Keep top 5 scores
    await _prefs?.setStringList('highScores', highScores.map((e) => e.toString()).toList());
  }

  void _selectPowerUp(PowerUpType type) {
    if (selectedPermanentPowerUps.length < 3 && !selectedPermanentPowerUps.contains(type)) {
      selectedPermanentPowerUps.add(type);
      if (selectedPermanentPowerUps.length == 3) {
        setState(() {
          showPowerUpSelection = false;
        });
        startGame(); // Now actually start the game
      } else {
        setState(() {});
      }
    }
  }

  bool _isPowerUpActive(PowerUpType type) {
    return selectedPermanentPowerUps.contains(type) || temporaryActivePowerUps.contains(type);
  }

  void startGame() {
    if (selectedPermanentPowerUps.length < 3) {
      setState(() {
        showPowerUpSelection = true;
      });
      return;
    }

    setState(() {
      score = 0;
      lives = 3;
      asteroids.clear();
      bullets.clear();
      powerUps.clear();
      particles.clear();
      started = true;
      running = true;
      paused = false;
      lastDifficultyIncreaseScore = 0;
      baseSpawnInterval = 1.0; // Slightly harder due to permanent powerups
      shootCooldown = 0;
      temporaryActivePowerUps.clear();
      timeScale = 1.0;
    });

    // Clear any active temporary power-up timers
    for (var timer in powerUpTimers.values) {
      timer?.cancel();
    }
    powerUpTimers.clear();

    // ensure ship position initializes once size known
    shipX = _size.width / 2;

    _lastTick = DateTime.now();
    _controller.forward();
    _startSpawning();
    _startPowerUpSpawning();
    
    // Request focus for keyboard input
    _focusNode.requestFocus();
  }

  void _startSpawning() {
    _spawnTimer?.cancel();
    _spawnTimer = Timer.periodic(
        Duration(milliseconds: (baseSpawnInterval * 1000).toInt()), (_) {
      if (running && !paused) _spawnAsteroid();
      // adapt spawn interval slightly with score
      final newInterval = max(0.35, 1.0 - (score / 250)); // Adjusted for difficulty
      if ((newInterval - baseSpawnInterval).abs() > 0.01) {
        baseSpawnInterval = newInterval;
        _spawnTimer?.cancel();
        _startSpawning();
      }
    });
  }

  void _startPowerUpSpawning() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (running && !paused && _rnd.nextDouble() < 0.6) {
        _spawnPowerUp();
      }
    });
  }

  void _spawnAsteroid() {
    if (_size == Size.zero) return;
    // Randomize size and speed
    final r = (_rnd.nextDouble() * 28) + 12; // 12..40 px
    final x = (_rnd.nextDouble() * (_size.width - 2 * r)) + r;
    final speed = (_rnd.nextDouble() * 90) + 60 + (score * 0.1); // px/s
    final rotation = _rnd.nextDouble() * pi * 2;
    final rotationSpeed = (_rnd.nextDouble() - 0.5) * 1.5; // rad/s
    asteroids.add(Asteroid(
        pos: Offset(x, -r - 10),
        radius: r,
        speed: speed,
        rotation: rotation,
        rotationSpeed: rotationSpeed));
  }

  void _spawnPowerUp() {
    if (_size == Size.zero) return;
    final x = (_rnd.nextDouble() * (_size.width - 30)) + 15;
    
    // Only spawn powerups that aren't permanent
    final availableTypes = allPowerUps
        .where((p) => !selectedPermanentPowerUps.contains(p.type))
        .map((p) => p.type)
        .toList();
    
    if (availableTypes.isEmpty) return;
    
    final type = availableTypes[_rnd.nextInt(availableTypes.length)];
    
    powerUps.add(PowerUp(
      pos: Offset(x, -20),
      speed: 80,
      type: type,
      health: 2, // Requires 2 shots to collect
    ));
  }

  void _createExplosion(Offset position, {Color color = Colors.orange}) {
    for (int i = 0; i < 15; i++) {
      final angle = _rnd.nextDouble() * pi * 2;
      final speed = _rnd.nextDouble() * 200 + 50;
      final velocity = Offset(cos(angle) * speed, sin(angle) * speed);
      
      particles.add(Particle(
        pos: position,
        velocity: velocity,
        color: color,
        size: _rnd.nextDouble() * 4 + 2,
        life: _rnd.nextDouble() * 1.0 + 0.5,
        maxLife: _rnd.nextDouble() * 1.0 + 0.5,
      ));
    }
  }

  void _tick() {
    if (!running || paused) return;

    final now = DateTime.now();
    final rawDt = now.difference(_lastTick).inMilliseconds / 1000.0;
    final dt = rawDt * timeScale; // Apply time scale for slow motion
    _lastTick = now;
    if (rawDt <= 0) return;

    // Update shoot cooldown
    shootCooldown = max(0, shootCooldown - rawDt); // Use raw dt for shooting

    // Handle keyboard input
    _handleKeyboardInput(dt);

    // Update bullets
    for (int i = bullets.length - 1; i >= 0; i--) {
      final b = bullets[i];
      
      // Magnetic bullets - attract to nearest asteroid
      if (_isPowerUpActive(PowerUpType.magneticBullets) && asteroids.isNotEmpty) {
        Asteroid? nearest;
        double minDist = double.infinity;
        for (final a in asteroids) {
          final dist = (a.pos - b.pos).distance;
          if (dist < minDist && dist < 150) { // Within attraction range
            minDist = dist;
            nearest = a;
          }
        }
        
        if (nearest != null) {
          final direction = (nearest.pos - b.pos).normalized();
          final newPos = b.pos + direction * b.speed * dt;
          bullets[i] = Bullet(
            pos: newPos,
            speed: b.speed,
            isPiercing: b.isPiercing,
            piercingCount: b.piercingCount,
          );
        } else {
          final newY = b.pos.dy - b.speed * dt;
          bullets[i] = Bullet(
            pos: Offset(b.pos.dx, newY),
            speed: b.speed,
            isPiercing: b.isPiercing,
            piercingCount: b.piercingCount,
          );
        }
      } else {
        final newY = b.pos.dy - b.speed * dt;
        bullets[i] = Bullet(
          pos: Offset(b.pos.dx, newY),
          speed: b.speed,
          isPiercing: b.isPiercing,
          piercingCount: b.piercingCount,
        );
      }
      
      // remove off-screen bullets
      if (bullets[i].pos.dy < -10) bullets.removeAt(i);
    }

    // Update asteroids
    for (int i = asteroids.length - 1; i >= 0; i--) {
      final a = asteroids[i];
      final newY = a.pos.dy + a.speed * dt;
      final newRotation = a.rotation + a.rotationSpeed * dt;
      asteroids[i] = Asteroid(
        pos: Offset(a.pos.dx, newY),
        radius: a.radius,
        speed: a.speed,
        rotation: newRotation,
        rotationSpeed: a.rotationSpeed,
      );
    }

    // Update power-ups
    for (int i = powerUps.length - 1; i >= 0; i--) {
      final p = powerUps[i];
      final newY = p.pos.dy + p.speed * dt;
      powerUps[i] = PowerUp(
        pos: Offset(p.pos.dx, newY),
        speed: p.speed,
        type: p.type,
        health: p.health,
      );
      // Remove off-screen power-ups
      if (newY > _size.height + 20) {
        powerUps.removeAt(i);
      }
    }

    // Update particles
    for (int i = particles.length - 1; i >= 0; i--) {
      final p = particles[i];
      p.life -= dt;
      if (p.life <= 0) {
        particles.removeAt(i);
        continue;
      }
      p.pos = p.pos + p.velocity * dt;
      p.velocity = p.velocity * 0.98; // Slow down over time
    }

    _handleCollisions();

    // Remove asteroids off bottom (and penalize)
    for (int i = asteroids.length - 1; i >= 0; i--) {
      final a = asteroids[i];
      if (a.pos.dy - a.radius > _size.height + 10) {
        // asteroid escaped: deduct a life only if no shield
        asteroids.removeAt(i);
        if (!_isPowerUpActive(PowerUpType.shield)) {
          lives--;
          if (lives <= 0) {
            _gameOver();
            return;
          }
        }
      }
    }

    // small difficulty bump based on score
    if (score - lastDifficultyIncreaseScore > 30) { // Adjusted for new difficulty
      lastDifficultyIncreaseScore = score as double;
      baseSpawnInterval = max(0.4, baseSpawnInterval - 0.06);
      _startSpawning();
    }

    setState(() {});
  }

  void _handleKeyboardInput(double dt) {
    double dx = 0, dy = 0;
    const speed = 600.0; // Increased movement speed

    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      dx -= speed * dt;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      dx += speed * dt;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      dy -= speed * dt;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      dy += speed * dt;
    }
    
    if (_keysPressed.contains(LogicalKeyboardKey.space)) {
      shoot();
    }

    // Update ship position
    if (dx != 0 || dy != 0) {
      moveShip(dx, dy);
    }
  }

  void _handleCollisions() {
    // bullets vs asteroids
    for (int i = asteroids.length - 1; i >= 0; i--) {
      final a = asteroids[i];
      for (int j = bullets.length - 1; j >= 0; j--) {
        final b = bullets[j];
        final dist = (a.pos - b.pos).distance;
        if (dist < a.radius + 6) {
          // hit
          _createExplosion(a.pos);
          asteroids.removeAt(i);
          
          // Handle piercing bullets
          if (b.isPiercing && b.piercingCount < 3) {
            bullets[j] = Bullet(
              pos: b.pos,
              speed: b.speed,
              isPiercing: true,
              piercingCount: b.piercingCount + 1,
            );
          } else {
            bullets.removeAt(j);
          }
          
          score += (50 - a.radius.toInt()).clamp(5, 40); // smaller asteroid -> more score
          break;
        }
      }
    }

    // bullets vs power-ups (must shoot to collect)
    for (int i = powerUps.length - 1; i >= 0; i--) {
      final p = powerUps[i];
      for (int j = bullets.length - 1; j >= 0; j--) {
        final b = bullets[j];
        final dist = (p.pos - b.pos).distance;
        if (dist < 20) {
          // shot power-up
          powerUps[i] = PowerUp(
            pos: p.pos,
            speed: p.speed,
            type: p.type,
            health: p.health - 1,
          );
          bullets.removeAt(j);
          _createExplosion(p.pos, color: Colors.greenAccent);
          
          if (powerUps[i].health <= 0) {
            _activatePowerUp(p.type);
            powerUps.removeAt(i);
          }
          break;
        }
      }
    }

    // asteroid vs ship (only if no shield)
    if (!_isPowerUpActive(PowerUpType.shield)) {
      final shipTop = _size.height - shipYMargin - shipHeight;
      for (int i = asteroids.length - 1; i >= 0; i--) {
        final a = asteroids[i];
        // approximate ship as a rectangle centered at (shipX, shipBaseY)
        final shipCenter = Offset(shipX, _size.height - shipYMargin - shipHeight / 2);
        // If asteroid near bottom area, check collision
        if (a.pos.dy + a.radius >= shipTop) {
          final dx = (a.pos.dx - shipCenter.dx).abs();
          final dxThreshold = shipWidth / 2 + a.radius * 0.8;
          if (dx < dxThreshold) {
            // collision
            _createExplosion(a.pos, color: Colors.red);
            _createExplosion(shipCenter, color: Colors.cyan);
            asteroids.removeAt(i);
            lives--;
            if (lives <= 0) {
              _gameOver();
              return;
            }
          }
        }
      }
    }
  }

  void _activatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.rapidFire:
        temporaryActivePowerUps.add(type);
        powerUpTimers[type]?.cancel();
        powerUpTimers[type] = Timer(const Duration(seconds: 8), () {
          temporaryActivePowerUps.remove(type);
        });
        break;
      case PowerUpType.shield:
        temporaryActivePowerUps.add(type);
        powerUpTimers[type]?.cancel();
        powerUpTimers[type] = Timer(const Duration(seconds: 10), () {
          temporaryActivePowerUps.remove(type);
        });
        break;
      case PowerUpType.multiShot:
        temporaryActivePowerUps.add(type);
        powerUpTimers[type]?.cancel();
        powerUpTimers[type] = Timer(const Duration(seconds: 6), () {
          temporaryActivePowerUps.remove(type);
        });
        break;
      case PowerUpType.tripleShot:
        temporaryActivePowerUps.add(type);
        powerUpTimers[type]?.cancel();
        powerUpTimers[type] = Timer(const Duration(seconds: 8), () {
          temporaryActivePowerUps.remove(type);
        });
        break;
      case PowerUpType.extraLife:
        lives++;
        break;
      case PowerUpType.slowMotion:
        timeScale = 0.5;
        Timer(const Duration(seconds: 5), () {
          timeScale = 1.0;
        });
        break;
      case PowerUpType.magneticBullets:
        temporaryActivePowerUps.add(type);
        powerUpTimers[type]?.cancel();
        powerUpTimers[type] = Timer(const Duration(seconds: 12), () {
          temporaryActivePowerUps.remove(type);
        });
        break;
      case PowerUpType.piercing:
        temporaryActivePowerUps.add(type);
        powerUpTimers[type]?.cancel();
        powerUpTimers[type] = Timer(const Duration(seconds: 10), () {
          temporaryActivePowerUps.remove(type);
        });
        break;
      default:
        break;
    }
  }

  void shoot() {
    if (!running || paused || shootCooldown > 0) return;
    
    final bulletSpeed = 500.0;
    final shipTop = _size.height - shipYMargin - shipHeight;
    
    bool isRapidFire = _isPowerUpActive(PowerUpType.rapidFire);
    bool isMultiShot = _isPowerUpActive(PowerUpType.multiShot);
    bool isTripleShot = _isPowerUpActive(PowerUpType.tripleShot);
    bool isPiercing = _isPowerUpActive(PowerUpType.piercing);
    
    if (isTripleShot) {
      // Five parallel beams
      for (int i = -2; i <= 2; i++) {
        bullets.add(Bullet(
          pos: Offset(shipX + i * 12, shipTop - 6), 
          speed: bulletSpeed,
          isPiercing: isPiercing,
        ));
      }
    } else if (isMultiShot) {
      // Triple shot
      bullets.add(Bullet(
        pos: Offset(shipX, shipTop - 6), 
        speed: bulletSpeed,
        isPiercing: isPiercing,
      ));
      bullets.add(Bullet(
        pos: Offset(shipX - 15, shipTop - 6), 
        speed: bulletSpeed,
        isPiercing: isPiercing,
      ));
      bullets.add(Bullet(
        pos: Offset(shipX + 15, shipTop - 6), 
        speed: bulletSpeed,
        isPiercing: isPiercing,
      ));
    } else {
      // Single shot
      bullets.add(Bullet(
        pos: Offset(shipX, shipTop - 6), 
        speed: bulletSpeed,
        isPiercing: isPiercing,
      ));
    }
    
    shootCooldown = isRapidFire ? rapidShootInterval : normalShootInterval;
    
    // optional: limit bullets
    if (bullets.length > 30) {
      bullets.removeRange(0, bullets.length - 30);
    }
    setState(() {});
  }

  void moveShipTo(double x) {
    // clamp within screen
    final half = shipWidth / 2;
    shipX = x.clamp(half, _size.width - half);
    // No setState needed here as it's called frequently during panning
  }

  void moveShip(double dx, double dy) {
    final half = shipWidth / 2;
    shipX = (shipX + dx).clamp(half, _size.width - half);
    // Note: We don't move the ship vertically in this version to maintain the original gameplay
    setState(() {});
  }

  void pauseResume() {
    setState(() {
      paused = !paused;
      if (paused) {
        _controller.stop();
      } else {
        _lastTick = DateTime.now();
        _controller.forward();
      }
    });
  }

  void _gameOver() async {
    running = false;
    _spawnTimer?.cancel();
    _powerUpTimer?.cancel();
    for (var timer in powerUpTimers.values) {
      timer?.cancel();
    }
    
    // Stop controller but keep state to show Game Over overlay
    _controller.stop();
    
    // Save high score
    await _saveHighScore();
    
    setState(() {});
  }

  // UI: restart
  void restart() {
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          _keysPressed.add(event.logicalKey);
        } else if (event is KeyUpEvent) {
          _keysPressed.remove(event.logicalKey);
        }
      },
      child: LayoutBuilder(builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_size != newSize) {
          _size = newSize;
          shipX = _size.width / 2;
        }

        return Stack(
          children: [
            // Gesture area + painter
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                // Fire on tap in top half; else move ship
                final local = details.localPosition;
                if (local.dy < _size.height * 0.6) {
                  shoot();
                } else {
                  moveShipTo(local.dx);
                  setState(() {}); // Ensure immediate visual update
                }
              },
              onPanUpdate: (details) {
                moveShipTo(details.localPosition.dx);
              },
              child: CustomPaint(
                size: _size,
                painter: _GamePainter(
                  shipX: shipX,
                  shipWidth: shipWidth,
                  shipHeight: shipHeight,
                  shipYMargin: shipYMargin,
                  asteroids: List.unmodifiable(asteroids),
                  bullets: List.unmodifiable(bullets),
                  powerUps: List.unmodifiable(powerUps),
                  particles: List.unmodifiable(particles),
                  activePowerUps: Set.from(selectedPermanentPowerUps)..addAll(temporaryActivePowerUps),
                  timeScale: timeScale,
                ),
              ),
            ),

            // HUD: Score, Lives, Power-ups
            Positioned(
              top: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hudChip('Score: $score', Icons.star),
                  const SizedBox(height: 8),
                  _hudChip('Lives: $lives', Icons.favorite),
                  // Show permanent powerups
                  ...selectedPermanentPowerUps.map((type) {
                    final info = allPowerUps.firstWhere((p) => p.type == type);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _hudChip('${info.name} ⚡', info.icon, color: info.color),
                    );
                  }),
                  // Show temporary powerups
                  ...temporaryActivePowerUps.map((type) {
                    final info = allPowerUps.firstWhere((p) => p.type == type);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _hudChip('${info.name}!', info.icon, color: info.color),
                    );
                  }),
                  if (timeScale < 1.0) ...[
                    const SizedBox(height: 8),
                    _hudChip('SLOW MOTION', Icons.slow_motion_video, color: Colors.indigo),
                  ],
                ],
              ),
            ),

            // High Scores (top right)
            if (highScores.isNotEmpty)
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _hudChip('High Scores', Icons.leaderboard),
                    const SizedBox(height: 4),
                    ...highScores.take(3).map((score) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _hudChip('$score', Icons.emoji_events, compact: true),
                        )),
                  ],
                ),
              ),

            // Fire button
            Positioned(
              right: 14,
              bottom: 14,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(18),
                ),
                onPressed: shoot,
                child: const Icon(Icons.whatshot, color: Colors.white, size: 28),
              ),
            ),

            // Pause / Restart buttons
            Positioned(
              left: 12,
              bottom: 12,
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: pauseResume,
                    icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                    label: Text(paused ? 'Resume' : 'Pause'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: restart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Restart'),
                  ),
                ],
              ),
            ),

            // Start screen / Game over overlay
            if (!started)
              _overlay(
                title: 'Asteroid Blaster',
                subtitle: 'Choose 3 permanent powerups first!\nDrag to move • Tap/Space to shoot\nWASD/Arrow keys to move\nShoot powerups to collect them!\nSurvive & score high!',
                buttonLabel: 'SELECT POWERUPS',
                buttonAction: startGame,
              ),

            if (started && !running)
              _overlay(
                title: 'Game Over',
                subtitle: 'Score: $score\n${highScores.isNotEmpty ? 'High Score: ${highScores.first}' : ''}',
                buttonLabel: 'Restart',
                buttonAction: restart,
              ),

            // Powerup selection overlay
            if (showPowerUpSelection)
              Container(
                color: Colors.black87,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Choose 3 Permanent Powerups',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text('Selected: ${selectedPermanentPowerUps.length}/3',
                            style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 20),
                        Container(
                          constraints: BoxConstraints(maxWidth: _size.width * 0.9),
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            alignment: WrapAlignment.center,
                            children: allPowerUps.map((powerUp) {
                              final isSelected = selectedPermanentPowerUps.contains(powerUp.type);
                              return GestureDetector(
                                onTap: isSelected ? null : () => _selectPowerUp(powerUp.type),
                                child: Container(
                                  width: 120,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: isSelected ? powerUp.color.withOpacity(0.3) : Colors.white12,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? powerUp.color : Colors.white24,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(powerUp.icon, color: powerUp.color, size: 30),
                                      const SizedBox(height: 8),
                                      Text(powerUp.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(powerUp.description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Other powerups can be collected during gameplay\nby shooting them (requires 2 hits)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _hudChip(String text, IconData icon, {Color? color, bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10, 
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color ?? Colors.white).withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 14 : 16, color: color ?? Colors.white70),
          const SizedBox(width: 6),
          Text(
            text, 
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlay({
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback buttonAction,
  }) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: buttonAction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

extension OffsetNormalize on Offset {
  Offset normalized() {
    final len = distance;
    if (len == 0) return this;
    return this / len;
  }
}

class _GamePainter extends CustomPainter {
  final double shipX;
  final double shipWidth;
  final double shipHeight;
  final double shipYMargin;
  final List<Asteroid> asteroids;
  final List<Bullet> bullets;
  final List<PowerUp> powerUps;
  final List<Particle> particles;
  final Set<PowerUpType> activePowerUps;
  final double timeScale;

  _GamePainter({
    required this.shipX,
    required this.shipWidth,
    required this.shipHeight,
    required this.shipYMargin,
    required this.asteroids,
    required this.bullets,
    required this.powerUps,
    required this.particles,
    required this.activePowerUps,
    required this.timeScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // background gradient
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: timeScale < 1.0 
          ? [Colors.black, Colors.indigo.shade900, Colors.purple.shade900]
          : [Colors.black, Colors.blueGrey.shade900],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // stars (simple)
    final starPaint = Paint()..color = Colors.white24;
    final rnd = Random(42); // deterministic
    for (int i = 0; i < 60; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), rnd.nextDouble() < 0.85 ? 0.6 : 1.4, starPaint);
    }

    // Draw particles
    for (final p in particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final particlePaint = Paint()..color = p.color.withOpacity(alpha);
      canvas.drawCircle(p.pos, p.size, particlePaint);
    }

    // Draw bullets
    for (final b in bullets) {
      _drawBullet(canvas, b);
    }

    // Draw power-ups
    for (final p in powerUps) {
      _drawPowerUp(canvas, p);
    }

    // Draw asteroids
    for (final a in asteroids) {
      _drawAsteroid(canvas, a);
    }

    // Draw ship (triangle)
    final shipBaseY = size.height - shipYMargin;
    final shipTop = Offset(shipX, shipBaseY - shipHeight);
    final shipLeft = Offset(shipX - shipWidth / 2, shipBaseY);
    final shipRight = Offset(shipX + shipWidth / 2, shipBaseY);
    final shipPath = Path()..moveTo(shipTop.dx, shipTop.dy);
    shipPath.lineTo(shipLeft.dx, shipLeft.dy);
    shipPath.lineTo(shipRight.dx, shipRight.dy);
    shipPath.close();

    final shipPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.cyanAccent, Colors.blueAccent])
          .createShader(Rect.fromLTWH(shipX - shipWidth/2, shipTop.dy, shipWidth, shipHeight));
    canvas.drawShadow(shipPath, Colors.black, 6, true);
    canvas.drawPath(shipPath, shipPaint);

    // cockpit
    final cockpit = Rect.fromCenter(center: shipTop.translate(0, shipHeight*0.25), width: shipWidth*0.45, height: shipHeight*0.4);
    canvas.drawOval(cockpit, Paint()..color = Colors.white24);

    // Draw shield effect if active
    if (activePowerUps.contains(PowerUpType.shield)) {
      final shieldCenter = Offset(shipX, shipBaseY - shipHeight / 2);
      final shieldPaint = Paint()
        ..color = Colors.blueAccent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(shieldCenter, shipWidth * 0.8, shieldPaint);
      
      // Animated shield rings
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      for (int i = 0; i < 3; i++) {
        final radius = shipWidth * (0.6 + 0.2 * i) + sin(time * 3 + i) * 5;
        final alpha = (0.5 - i * 0.15) * (0.5 + 0.5 * sin(time * 2 + i));
        final ringPaint = Paint()
          ..color = Colors.cyanAccent.withOpacity(alpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(shieldCenter, radius, ringPaint);
      }
    }
  }

  void _drawBullet(Canvas canvas, Bullet bullet) {
    Color bulletColor = Colors.yellowAccent;
    double bulletWidth = 6;
    double bulletHeight = 12;
    
    // Different bullet types based on active powerups
    if (bullet.isPiercing) {
      bulletColor = Colors.amber;
      bulletWidth = 8;
      bulletHeight = 16;
    }
    
    final bulletPaint = Paint()..color = bulletColor;
    canvas.drawRect(Rect.fromCenter(center: bullet.pos, width: bulletWidth, height: bulletHeight), bulletPaint);
    canvas.drawCircle(bullet.pos.translate(0, -bulletHeight/2 - 3), bulletWidth/2, bulletPaint);
    
    // Piercing bullet trail
    if (bullet.isPiercing) {
      final trailPaint = Paint()
        ..color = Colors.amber.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRect(Rect.fromCenter(center: bullet.pos.translate(0, 10), width: bulletWidth * 0.7, height: bulletHeight * 2), trailPaint);
    }
  }

  void _drawPowerUp(Canvas canvas, PowerUp powerUp) {
    final paint = Paint()..isAntiAlias = true;
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Pulsing effect
    final pulseScale = 1.0 + sin(time * 4) * 0.1;
    final size = 20 * pulseScale;
    
    final info = allPowerUps.firstWhere((p) => p.type == powerUp.type);
    final color = info.color;
    
    // Health indicator - show cracks if damaged
    final healthRatio = powerUp.health / 2.0;
    
    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(powerUp.pos, size + 5, glowPaint);
    
    // Main circle
    paint.color = color.withOpacity(healthRatio);
    canvas.drawCircle(powerUp.pos, size, paint);
    
    // Inner highlight
    paint.color = color.withOpacity(0.6 * healthRatio);
    canvas.drawCircle(powerUp.pos, size * 0.7, paint);
    
    // Damage cracks
    if (powerUp.health < 2) {
      final crackPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.save();
      canvas.translate(powerUp.pos.dx, powerUp.pos.dy);
      // Draw crack lines
      canvas.drawLine(Offset(-size * 0.7, -size * 0.3), Offset(size * 0.4, size * 0.6), crackPaint);
      canvas.drawLine(Offset(-size * 0.2, -size * 0.8), Offset(size * 0.3, -size * 0.1), crackPaint);
      canvas.restore();
    }
    
    // Rotating border
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.save();
    canvas.translate(powerUp.pos.dx, powerUp.pos.dy);
    canvas.rotate(time * 2);
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * pi * 2;
      final start = Offset(cos(angle) * size, sin(angle) * size);
      final end = Offset(cos(angle) * (size + 5), sin(angle) * (size + 5));
      canvas.drawLine(start, end, paint);
    }
    canvas.restore();
  }

  void _drawAsteroid(Canvas canvas, Asteroid a) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.save();
    canvas.translate(a.pos.dx, a.pos.dy);
    canvas.rotate(a.rotation);

    final path = Path();
    final numPoints = 8 + (a.radius ~/ 6);
    final rnd = Random(a.pos.dx.toInt() + a.pos.dy.toInt());
    for (int i = 0; i < numPoints; i++) {
      final t = (i / numPoints) * pi * 2;
      final variance = 0.75 + rnd.nextDouble() * 0.6;
      final r = a.radius * (0.8 + 0.4 * sin(t * 3 + rnd.nextDouble()));
      final x = cos(t) * r;
      final y = sin(t) * r;
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);

    // crater highlight
    canvas.drawCircle(Offset(-a.radius * 0.25, -a.radius * 0.15), a.radius * 0.25, Paint()..color = Colors.black26);
    canvas.drawCircle(Offset(a.radius * 0.18, a.radius * 0.2), a.radius * 0.13, Paint()..color = Colors.black26);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GamePainter oldDelegate) {
    return true; // always repaint every frame while running
  }
}