import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/upload_screen.dart';
import '../screens/test_screen.dart';
import '../screens/metrics_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';
import '../screens/error_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String upload = '/upload';
  static const String test = '/test';
  static const String metrics = '/metrics';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String error = '/error';

  // Navigation helper
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Route generation
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      
      case dashboard:
        return _buildRoute(const DashboardScreen(), settings);
      
      case upload:
        return _buildRoute(const UploadScreen(), settings);
      
      case test:
        return _buildRoute(const TestScreen(), settings);
      
      case metrics:
        return _buildRoute(const MetricsScreen(), settings);
      
      case settings:
        return _buildRoute(const SettingsScreen(), settings);
      
      case help:
        return _buildRoute(const HelpScreen(), settings);
      
      case error:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ErrorScreen(
            error: args?['error'] ?? 'Unknown error',
            stackTrace: args?['stackTrace'],
          ),
          settings,
        );
      
      default:
        return _buildRoute(
          const ErrorScreen(
            error: 'Route not found',
            message: 'The requested page could not be found.',
          ),
          settings,
        );
    }
  }

  // Custom route builder with animations
  static PageRoute<T> _buildRoute<T extends Object?>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Cyber-themed slide transition
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        // Add fade transition
        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  // Navigation helpers
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  static Future<T?> pushNamedAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(
      ModalRoute.withName(routeName),
    );
  }

  // Route guards and validation
  static bool isValidRoute(String routeName) {
    const validRoutes = [
      splash,
      dashboard,
      upload,
      test,
      metrics,
      settings,
      help,
      error,
    ];
    return validRoutes.contains(routeName);
  }

  // Deep linking support (for future web URLs)
  static String getRouteFromPath(String path) {
    final uri = Uri.parse(path);
    final segments = uri.pathSegments;
    
    if (segments.isEmpty) return splash;
    
    switch (segments.first) {
      case 'dashboard':
        return dashboard;
      case 'upload':
        return upload;
      case 'test':
        return test;
      case 'metrics':
        return metrics;
      case 'settings':
        return settings;
      case 'help':
        return help;
      default:
        return dashboard;
    }
  }

  // Route information
  static const Map<String, RouteInfo> routeInfo = {
    splash: RouteInfo(
      title: 'Cybersecurity Lab',
      icon: Icons.security,
      description: 'Loading application...',
    ),
    dashboard: RouteInfo(
      title: 'Dashboard',
      icon: Icons.dashboard,
      description: 'Main application dashboard',
    ),
    upload: RouteInfo(
      title: 'Upload Code',
      icon: Icons.upload_file,
      description: 'Upload custom encryption and attack algorithms',
    ),
    test: RouteInfo(
      title: 'Test Code',
      icon: Icons.play_circle,
      description: 'Run simulations and test algorithms',
    ),
    metrics: RouteInfo(
      title: 'Metrics & Analytics',
      icon: Icons.analytics,
      description: 'View performance metrics and analysis',
    ),
    settings: RouteInfo(
      title: 'Settings',
      icon: Icons.settings,
      description: 'Application settings and preferences',
    ),
    help: RouteInfo(
      title: 'Help & Documentation',
      icon: Icons.help,
      description: 'User guide and documentation',
    ),
  };

  static RouteInfo getRouteInfo(String routeName) {
    return routeInfo[routeName] ?? const RouteInfo(
      title: 'Unknown',
      icon: Icons.error,
      description: 'Unknown route',
    );
  }
}

class RouteInfo {
  final String title;
  final IconData icon;
  final String description;
  final bool requiresAuth;
  final List<String> permissions;

  const RouteInfo({
    required this.title,
    required this.icon,
    required this.description,
    this.requiresAuth = false,
    this.permissions = const [],
  });
} 