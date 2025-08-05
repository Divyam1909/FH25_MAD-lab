import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SpaceShooterGame());
}

class SpaceShooterGame extends StatefulWidget {
  const SpaceShooterGame({super.key});

  @override
  _SpaceShooterGameState createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame> {
  static const int maxAsteroids = 5;
  final Random random = Random();

  double bulletX = 0;
  double bulletY = 1.5;
  bool bulletVisible = false;

  List<Asteroid> asteroids = [];
  int score = 0;
  int highScore = 0;
  bool gameOver = false;

  Timer? gameLoopTimer;

  @override
  void initState() {
    super.initState();
    loadHighScore();
    startGame();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      await prefs.setInt('highScore', score);
      setState(() {
        highScore = score;
      });
    }
  }

  void startGame() {
    gameOver = false;
    score = 0;
    bulletVisible = false;
    bulletY = 1.5;
    asteroids.clear();

    for (int i = 0; i < maxAsteroids; i++) {
      asteroids.add(createRandomAsteroid());
    }

    gameLoopTimer?.cancel();
    gameLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      updateGame();
    });
  }

  Asteroid createRandomAsteroid() {
    return Asteroid(
      x: random.nextDouble() * 2 - 1,
      y: random.nextDouble() * -2 - 1,
      speed: 0.01 + random.nextDouble() * 0.02,
      size: 40 + random.nextDouble() * 30,
    );
  }

  void updateGame() {
    if (gameOver) return;

    setState(() {
      if (bulletVisible) {
        bulletY -= 0.05;
        if (bulletY < -1.5) {
          bulletVisible = false;
          bulletY = 1.5;
        }
      }

      for (var asteroid in asteroids) {
        asteroid.y += asteroid.speed;

        if (asteroid.y > 1.3) {
          gameOver = true;
          gameLoopTimer?.cancel();
          saveHighScore();
        }
      }

      if (bulletVisible) {
        for (var asteroid in asteroids) {
          if (hitTest(bulletX, bulletY, 10, asteroid.x, asteroid.y, asteroid.size)) {
            score++;
            bulletVisible = false;
            bulletY = 1.5;
            asteroid.x = random.nextDouble() * 2 - 1;
            asteroid.y = random.nextDouble() * -2 - 1;
            asteroid.speed = 0.01 + random.nextDouble() * 0.02;
            asteroid.size = 40 + random.nextDouble() * 30;
            break;
          }
        }
      }
    });
  }

  bool hitTest(double x1, double y1, double size1, double x2, double y2, double size2) {
    double dx = (x1 - x2) * MediaQuery.of(context).size.width / 2;
    double dy = (y1 - y2) * MediaQuery.of(context).size.height / 2;
    double distance = sqrt(dx * dx + dy * dy);
    return distance < (size1 + size2) / 2;
  }

  void shoot() {
    if (!bulletVisible && !gameOver) {
      setState(() {
        bulletX = 0;
        bulletY = 1;
        bulletVisible = true;
      });
    }
  }

  void restart() {
    startGame();
  }

  @override
  void dispose() {
    gameLoopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Shooter',
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Asteroids
              ...asteroids.map((a) => Align(
                    alignment: Alignment(a.x, a.y),
                    child: Container(
                      width: a.size,
                      height: a.size,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )),

              // Bullet
              if (bulletVisible)
                Align(
                  alignment: Alignment(bulletX, bulletY),
                  child: Container(
                    width: 10,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),

              // Spaceship
              Align(
                alignment: const Alignment(0, 1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.airplanemode_active,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // UI - Score and High Score
              Positioned(
                top: 10,
                left: 10,
                child: Text(
                  'Score: $score',
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Text(
                  'High Score: $highScore',
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),

              // Tap to Shoot
              GestureDetector(
                onTap: shoot,
                child: Container(
                  color: Colors.transparent,
                ),
              ),

              // Game Over
              if (gameOver)
                Center(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Score: $score',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'High Score: $highScore',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: restart,
                          child: const Text('Restart'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Asteroid {
  double x;
  double y;
  double speed;
  double size;

  Asteroid({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
  });
}
