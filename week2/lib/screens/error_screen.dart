import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../config/app_routes.dart';
import '../widgets/cyber_card.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  final String? message;
  final StackTrace? stackTrace;
  final bool canRetry;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    required this.error,
    this.message,
    this.stackTrace,
    this.canRetry = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: AppTheme.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => AppRoutes.pushNamedAndClearStack(AppRoutes.dashboard),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.errorRed,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRed,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Error Title
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              if (message != null)
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 32),
              
              // Error Details Card
              CyberCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.bug_report,
                          color: AppTheme.errorRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Error Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Error Type
                    _buildDetailRow('Error Type:', error),
                    
                    if (stackTrace != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow('Stack Trace:', 'Available (tap to view)'),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Actions
                    Row(
                      children: [
                        if (stackTrace != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showStackTrace(context),
                              icon: const Icon(Icons.code),
                              label: const Text('View Stack Trace'),
                            ),
                          ),
                        if (stackTrace != null) const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyErrorDetails(),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Details'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => AppRoutes.pushNamedAndClearStack(AppRoutes.dashboard),
                    icon: const Icon(Icons.home),
                    label: const Text('Go to Dashboard'),
                  ),
                  
                  if (canRetry) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: onRetry ?? () => _defaultRetry(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningOrange,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Help Text
              Text(
                'If this error persists, please check the troubleshooting guide in Help & Documentation.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDisabled,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  void _showStackTrace(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stack Trace'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              stackTrace.toString(),
              style: AppTheme.codeTextStyle,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: stackTrace.toString()));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stack trace copied to clipboard'),
                ),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _copyErrorDetails() {
    final details = StringBuffer();
    details.writeln('Error: $error');
    if (message != null) {
      details.writeln('Message: $message');
    }
    if (stackTrace != null) {
      details.writeln('Stack Trace:');
      details.writeln(stackTrace.toString());
    }
    
    Clipboard.setData(ClipboardData(text: details.toString()));
  }

  void _defaultRetry(BuildContext context) {
    // Default retry behavior - go back to previous screen
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      AppRoutes.pushNamedAndClearStack(AppRoutes.dashboard);
    }
  }
} 