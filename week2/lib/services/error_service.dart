import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  static ErrorService get instance => _instance;
  ErrorService._internal();

  final List<ErrorReport> _errorHistory = [];
  final int _maxErrorHistory = 100;

  // Report an error
  void reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    final errorReport = ErrorReport(
      error: error,
      stackTrace: stackTrace,
      context: context,
      additionalData: additionalData,
      timestamp: DateTime.now(),
    );

    _errorHistory.add(errorReport);
    
    // Keep only recent errors
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }

    // Log the error
    AppConfig.logError(
      'Error in ${context ?? 'Unknown context'}: $error',
      error,
      stackTrace,
    );

    // In production, you would send this to a crash reporting service
    if (AppConfig.enableCrashReporting && !kDebugMode) {
      _sendToCrashReporting(errorReport);
    }
  }

  // Report a handled exception
  void reportHandledException(
    Exception exception,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    reportError(
      exception,
      stackTrace,
      context: context,
      additionalData: additionalData,
    );
  }

  // Report a warning
  void reportWarning(
    String warning, {
    String? context,
    Map<String, dynamic>? additionalData,
  }) {
    AppConfig.logWarning('Warning in ${context ?? 'Unknown context'}: $warning');
    
    // Store warning in error history for debugging
    final warningReport = ErrorReport(
      error: warning,
      stackTrace: null,
      context: context,
      additionalData: additionalData,
      timestamp: DateTime.now(),
      isWarning: true,
    );
    
    _errorHistory.add(warningReport);
    
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
  }

  // Get error history
  List<ErrorReport> get errorHistory => List.unmodifiable(_errorHistory);

  // Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
  }

  // Get error statistics
  Map<String, int> getErrorStatistics() {
    final stats = <String, int>{};
    
    for (final error in _errorHistory) {
      final errorType = error.error.runtimeType.toString();
      stats[errorType] = (stats[errorType] ?? 0) + 1;
    }
    
    return stats;
  }

  // Check if there are recent critical errors
  bool hasRecentCriticalErrors({Duration window = const Duration(minutes: 5)}) {
    final cutoff = DateTime.now().subtract(window);
    
    return _errorHistory.any((error) =>
        error.timestamp.isAfter(cutoff) &&
        !error.isWarning &&
        _isCriticalError(error.error));
  }

  // Get recent errors
  List<ErrorReport> getRecentErrors({Duration window = const Duration(hours: 1)}) {
    final cutoff = DateTime.now().subtract(window);
    
    return _errorHistory
        .where((error) => error.timestamp.isAfter(cutoff))
        .toList();
  }

  // Private methods
  void _sendToCrashReporting(ErrorReport errorReport) {
    // In a real app, this would send to Firebase Crashlytics,
    // Sentry, or another crash reporting service
    AppConfig.logInfo('Sending error report to crash reporting service');
  }

  bool _isCriticalError(dynamic error) {
    // Define what constitutes a critical error
    final criticalErrorTypes = [
      'StateError',
      'ArgumentError',
      'FormatException',
      'TimeoutException',
      'SecurityException',
    ];
    
    return criticalErrorTypes.any((type) => 
        error.runtimeType.toString().contains(type));
  }
}

class ErrorReport {
  final dynamic error;
  final StackTrace? stackTrace;
  final String? context;
  final Map<String, dynamic>? additionalData;
  final DateTime timestamp;
  final bool isWarning;

  const ErrorReport({
    required this.error,
    this.stackTrace,
    this.context,
    this.additionalData,
    required this.timestamp,
    this.isWarning = false,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Error Report:');
    buffer.writeln('  Type: ${isWarning ? 'Warning' : 'Error'}');
    buffer.writeln('  Time: $timestamp');
    buffer.writeln('  Context: ${context ?? 'Unknown'}');
    buffer.writeln('  Error: $error');
    
    if (stackTrace != null) {
      buffer.writeln('  Stack Trace:');
      buffer.writeln('    ${stackTrace.toString().replaceAll('\n', '\n    ')}');
    }
    
    if (additionalData != null && additionalData!.isNotEmpty) {
      buffer.writeln('  Additional Data:');
      additionalData!.forEach((key, value) {
        buffer.writeln('    $key: $value');
      });
    }
    
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'context': context,
      'additionalData': additionalData,
      'timestamp': timestamp.toIso8601String(),
      'isWarning': isWarning,
    };
  }
} 