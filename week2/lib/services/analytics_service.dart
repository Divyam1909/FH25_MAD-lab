import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final List<AnalyticsEvent> _events = [];
  final Map<String, dynamic> _sessionData = {};
  DateTime? _sessionStart;
  Timer? _performanceTimer;

  // Initialize analytics
  void initialize() {
    if (!AppConfig.enableAnalytics) return;
    
    _sessionStart = DateTime.now();
    _sessionData['session_id'] = _generateSessionId();
    _sessionData['app_version'] = AppConfig.appVersion;
    _sessionData['platform'] = defaultTargetPlatform.name;
    
    // Start performance monitoring
    if (AppConfig.enablePerformanceMonitoring) {
      _startPerformanceMonitoring();
    }
    
    AppConfig.logInfo('Analytics service initialized');
  }

  // Track events
  void trackEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (!AppConfig.enableAnalytics) return;
    
    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
      sessionId: _sessionData['session_id'],
    );
    
    _events.add(event);
    
    // Keep only recent events
    if (_events.length > 1000) {
      _events.removeAt(0);
    }
    
    AppConfig.logInfo('Analytics event: $eventName');
  }

  // Track screen views
  void trackScreenView(String screenName) {
    trackEvent('screen_view', parameters: {
      'screen_name': screenName,
      'previous_screen': _sessionData['current_screen'],
    });
    
    _sessionData['current_screen'] = screenName;
  }

  // Track user actions
  void trackUserAction(String action, {Map<String, dynamic>? context}) {
    trackEvent('user_action', parameters: {
      'action': action,
      'screen': _sessionData['current_screen'],
      ...?context,
    });
  }

  // Track performance metrics
  void trackPerformance(String metric, double value, {String? unit}) {
    if (!AppConfig.enablePerformanceMonitoring) return;
    
    trackEvent('performance_metric', parameters: {
      'metric': metric,
      'value': value,
      'unit': unit ?? 'ms',
      'screen': _sessionData['current_screen'],
    });
  }

  // Track errors
  void trackError(String error, {String? context, bool isFatal = false}) {
    trackEvent('error', parameters: {
      'error': error,
      'context': context,
      'is_fatal': isFatal,
      'screen': _sessionData['current_screen'],
    });
  }

  // Track feature usage
  void trackFeatureUsage(String feature, {Map<String, dynamic>? metadata}) {
    trackEvent('feature_usage', parameters: {
      'feature': feature,
      'screen': _sessionData['current_screen'],
      ...?metadata,
    });
  }

  // Track simulation events
  void trackSimulation({
    required String simulationType,
    required String algorithm,
    required String attackType,
    required Duration duration,
    required bool success,
    Map<String, dynamic>? results,
  }) {
    trackEvent('simulation_completed', parameters: {
      'simulation_type': simulationType,
      'algorithm': algorithm,
      'attack_type': attackType,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      'results': results,
    });
  }

  // Track file uploads
  void trackFileUpload({
    required String fileType,
    required int fileSizeBytes,
    required bool success,
    String? errorMessage,
  }) {
    trackEvent('file_upload', parameters: {
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'success': success,
      'error_message': errorMessage,
    });
  }

  // Get session statistics
  Map<String, dynamic> getSessionStatistics() {
    final now = DateTime.now();
    final sessionDuration = _sessionStart != null 
        ? now.difference(_sessionStart!).inMinutes 
        : 0;
    
    final eventCounts = <String, int>{};
    for (final event in _events) {
      eventCounts[event.name] = (eventCounts[event.name] ?? 0) + 1;
    }
    
    return {
      'session_duration_minutes': sessionDuration,
      'total_events': _events.length,
      'event_counts': eventCounts,
      'screens_visited': _getUniqueScreens(),
      'errors_count': _getErrorCount(),
      'performance_metrics': _getPerformanceMetrics(),
    };
  }

  // Export analytics data
  Map<String, dynamic> exportAnalyticsData() {
    return {
      'session_data': _sessionData,
      'events': _events.map((e) => e.toJson()).toList(),
      'statistics': getSessionStatistics(),
      'export_timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Clear analytics data
  void clearData() {
    _events.clear();
    _sessionData.clear();
    _sessionStart = DateTime.now();
    AppConfig.logInfo('Analytics data cleared');
  }

  // Private methods
  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[random % chars.length]).join();
  }

  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _collectPerformanceMetrics(),
    );
  }

  void _collectPerformanceMetrics() {
    // Collect memory usage, frame rate, etc.
    // This is a simplified version - in production you'd use proper profiling tools
    trackPerformance('memory_usage_mb', _getMemoryUsage());
    trackPerformance('event_queue_size', _events.length.toDouble());
  }

  double _getMemoryUsage() {
    // Simplified memory usage calculation
    return _events.length * 0.1; // Rough estimate
  }

  Set<String> _getUniqueScreens() {
    return _events
        .where((e) => e.name == 'screen_view')
        .map((e) => e.parameters['screen_name'] as String? ?? 'unknown')
        .toSet();
  }

  int _getErrorCount() {
    return _events.where((e) => e.name == 'error').length;
  }

  Map<String, double> _getPerformanceMetrics() {
    final performanceEvents = _events
        .where((e) => e.name == 'performance_metric')
        .toList();
    
    final metrics = <String, List<double>>{};
    
    for (final event in performanceEvents) {
      final metric = event.parameters['metric'] as String;
      final value = event.parameters['value'] as double;
      
      metrics.putIfAbsent(metric, () => []).add(value);
    }
    
    // Calculate averages
    final averages = <String, double>{};
    metrics.forEach((metric, values) {
      averages[metric] = values.reduce((a, b) => a + b) / values.length;
    });
    
    return averages;
  }

  // Dispose resources
  void dispose() {
    _performanceTimer?.cancel();
  }
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? sessionId;

  const AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
    };
  }
}

class ErrorReport {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;

  const ErrorReport({
    required this.error,
    this.stackTrace,
    this.context,
    this.additionalData,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'additionalData': additionalData,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 