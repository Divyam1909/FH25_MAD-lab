import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

// Core imports
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';

// Services
import 'services/encryption_service.dart';
import 'services/attack_service.dart';
import 'services/benchmark_service.dart';
import 'services/quantum_crypto_service.dart';
import 'services/ml_security_service.dart';
import 'services/blockchain_security_service.dart';
import 'services/notification_service.dart';
import 'services/error_service.dart';
import 'services/analytics_service.dart';

// State Management
import 'models/app_state.dart';

// Screens
// ...existing code...
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger()
        .e('Flutter Error: ${details.exception}', stackTrace: details.stack);
    ErrorService.instance.reportError(details.exception, details.stack);
  };

  // Set preferred orientations for web
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  // Initialize app configuration
  await AppConfig.initialize();

  runApp(const CybersecurityLabApp());
}

class CybersecurityLabApp extends StatelessWidget {
  const CybersecurityLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // State Management
        ChangeNotifierProvider(create: (_) => AppState()),

        // Core Services
        Provider(create: (_) => EncryptionService()),
        Provider(create: (_) => AttackService()),
        Provider(create: (_) => BenchmarkService()),

        // Advanced Services
        Provider(create: (_) => QuantumCryptoService()),
        Provider(create: (_) => MLSecurityService()),
        Provider(create: (_) => BlockchainSecurityService()),

        // Utility Services
        Provider(create: (_) => NotificationService()),
        Provider(create: (_) => ErrorService.instance),
        Provider(create: (_) => AnalyticsService()),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,

            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Navigation Configuration
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            navigatorKey: AppConfig.navigatorKey,

            // Error Handling
            builder: (context, widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _buildErrorWidget(context, errorDetails);
              };

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: 1.0, // Prevent system font scaling issues
                ),
                child: widget ?? const SizedBox.shrink(),
              );
            },

            // Localization (future enhancement)
            supportedLocales: const [
              Locale('en', 'US'),
            ],

            // Home screen
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(
      BuildContext context, FlutterErrorDetails errorDetails) {
    return Scaffold(
      backgroundColor: AppTheme.darkColors.background,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.darkColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.darkColors.error,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.darkColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Application Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.darkColors.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'An unexpected error occurred. The development team has been notified.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkColors.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Restart app
                      SystemNavigator.pop();
                    },
                    child: const Text('Restart App'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      // Show error details
                      _showErrorDetails(context, errorDetails);
                    },
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDetails(
      BuildContext context, FlutterErrorDetails errorDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Text(
            errorDetails.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
