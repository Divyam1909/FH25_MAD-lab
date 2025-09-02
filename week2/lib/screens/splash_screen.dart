import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../services/analytics_service.dart';
import '../services/error_service.dart';
import '../services/ml_security_service.dart';
import '../services/quantum_crypto_service.dart';
import '../services/blockchain_security_service.dart';
import '../models/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;
  
  String _loadingText = 'Initializing Cybersecurity Lab...';
  double _progress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    
    _logoController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      final steps = [
        ('Initializing services...', _initializeServices),
        ('Loading ML models...', _initializeMLModels),
        ('Setting up quantum crypto...', _initializeQuantumCrypto),
        ('Configuring blockchain...', _initializeBlockchain),
        ('Preparing user interface...', _initializeUI),
        ('Finalizing setup...', _finalizeSetup),
      ];

      for (int i = 0; i < steps.length; i++) {
        final (message, initFunction) = steps[i];
        
        setState(() {
          _loadingText = message;
          _progress = (i + 1) / steps.length;
        });
        
        await initFunction();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Navigate to dashboard
      if (mounted) {
        await AppRoutes.pushReplacementNamed(AppRoutes.dashboard);
      }
    } catch (error, stackTrace) {
      setState(() {
        _hasError = true;
        _loadingText = 'Initialization failed. Please try again.';
      });
      
      ErrorService.instance.reportError(
        error,
        stackTrace,
        context: 'SplashScreen initialization',
      );
    }
  }

  Future<void> _initializeServices() async {
    // Initialize analytics
    AnalyticsService().initialize();
    
    // Track app launch
    AnalyticsService().trackEvent('app_launch', parameters: {
      'version': AppConfig.appVersion,
      'platform': defaultTargetPlatform.name,
    });
  }

  Future<void> _initializeMLModels() async {
    try {
      final mlService = context.read<MLSecurityService>();
      await mlService.initializeModels();
    } catch (e) {
      AppConfig.logWarning('ML models initialization failed: $e');
    }
  }

  Future<void> _initializeQuantumCrypto() async {
    try {
      final quantumService = context.read<QuantumCryptoService>();
      // Initialize quantum crypto if needed
      AppConfig.logInfo('Quantum crypto service ready');
    } catch (e) {
      AppConfig.logWarning('Quantum crypto initialization failed: $e');
    }
  }

  Future<void> _initializeBlockchain() async {
    try {
      final blockchainService = context.read<BlockchainSecurityService>();
      // Initialize blockchain service if needed
      AppConfig.logInfo('Blockchain service ready');
    } catch (e) {
      AppConfig.logWarning('Blockchain initialization failed: $e');
    }
  }

  Future<void> _initializeUI() async {
    // Pre-load any heavy UI components or assets
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _finalizeSetup() async {
    // Final setup steps
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cyberGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.5),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.security,
                        size: 80,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // App Title
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              // App Description
              Text(
                AppConfig.appDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 60),
              
              // Loading Section
              if (!_hasError) ...[
                // Progress Bar
                Container(
                  width: 300,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progress * _progressAnimation.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.primaryGreen,
                        ),
                      );
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1200.ms, duration: 600.ms),
                
                const SizedBox(height: 24),
                
                // Loading Text
                Text(
                  _loadingText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 1400.ms, duration: 600.ms),
                
                const SizedBox(height: 16),
                
                // Loading Spinner
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                  strokeWidth: 2,
                )
                    .animate()
                    .fadeIn(delay: 1600.ms, duration: 600.ms),
              ] else ...[
                // Error State
                Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _loadingText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.errorRed,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _progress = 0.0;
                        });
                        _startInitialization();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 40),
              
              // Version Info
              Text(
                'Version ${AppConfig.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDisabled,
                ),
              )
                  .animate()
                  .fadeIn(delay: 2000.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
} 