import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AppConfig {
  // App Information
  static const String appName = 'Advanced Cybersecurity Lab';
  static const String appVersion = '2.0.0';
  static const String appDescription =
      'Comprehensive cybersecurity testing and education platform';

  // Navigation
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Logger
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Performance Settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int maxLogEntries = 1000;
  static const int maxBenchmarkResults = 100;

  // Security Settings
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileExtensions = [
    '.dart',
    '.py',
    '.js',
    '.ts'
  ];
  static const int maxCustomCodeLength = 50000; // 50KB
  static const Duration sessionTimeout = Duration(hours: 2);

  // UI Constants
  static const double sidebarWidth = 280;
  static const double minScreenWidth = 1024;
  static const double minScreenHeight = 768;
  static const EdgeInsets defaultPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const BorderRadius defaultBorderRadius =
      BorderRadius.all(Radius.circular(16));

  // Simulation Settings
  static const int defaultNetworkNodes = 5;
  static const int maxNetworkNodes = 20;
  static const Duration simulationStepDelay = Duration(milliseconds: 100);
  static const int maxSimulationSteps = 1000;

  // Crypto Constants
  static const int defaultKeySize = 256;
  static const int defaultIVSize = 16;
  static const int defaultSaltSize = 32;
  static const int defaultIterations = 10000;

  // ML Model Settings
  static const double defaultMLThreshold = 0.8;
  static const int defaultWindowSize = 1000;
  static const int defaultSequenceLength = 50;

  // Feature Flags
  static const bool enableQuantumCrypto = true;
  static const bool enableMLSecurity = true;
  static const bool enableBlockchainAnalysis = true;
  static const bool enableAdvancedVisualization = true;
  static const bool enableRealTimeMonitoring = true;
  static const bool enableExportFeatures = true;

  // API Configuration (for future backend integration)
  static const String baseApiUrl = 'https://api.cyberlab.local';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Analytics
  static const bool enableAnalytics = false; // Disabled for privacy
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;

  // Development Settings
  static const bool isDebugMode = true;
  static const bool enableVerboseLogging = true;
  static const bool showPerformanceOverlay = false;

  // Initialize configuration
  static Future<void> initialize() async {
    logger.i('Initializing AppConfig...');

    // Initialize any async configuration here
    await _initializeServices();

    logger.i('AppConfig initialized successfully');
  }

  static Future<void> _initializeServices() async {
    // Initialize any required services
    // This could include loading configuration from storage,
    // initializing analytics, etc.
  }

  // Utility methods
  static bool get isLargeScreen =>
      WidgetsBinding
          .instance.platformDispatcher.views.first.physicalSize.width >
      minScreenWidth *
          WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio;

  static bool get isMobile => !isLargeScreen;

  static void logInfo(String message) {
    if (enableVerboseLogging) {
      logger.i(message);
    }
  }

  static void logError(String message,
      [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void logWarning(String message) {
    logger.w(message);
  }
}
