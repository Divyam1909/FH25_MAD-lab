import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Show snackbar notification
  void showSnackBar({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final context = AppConfig.navigatorKey.currentContext;
    if (context == null) return;

    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 1),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: color,
                onPressed: onAction ?? () {},
              )
            : null,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show dialog notification
  void showDialog({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    List<DialogAction> actions = const [],
    bool barrierDismissible = true,
  }) {
    final context = AppConfig.navigatorKey.currentContext;
    if (context == null) return;

    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Notification Dialog',
      barrierColor: Colors.black54,
      transitionDuration: AppConfig.animationDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: actions.isEmpty
              ? [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ]
              : actions.map((action) {
                  return TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      action.onPressed?.call();
                    },
                    child: Text(action.label),
                  );
                }).toList(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // Show loading overlay
  void showLoading({
    String? message,
    bool canCancel = false,
    VoidCallback? onCancel,
  }) {
    final context = AppConfig.navigatorKey.currentContext;
    if (context == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: canCancel,
      barrierLabel: 'Loading',
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: AppTheme.cyberCardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (canCancel) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel?.call();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Hide loading overlay
  void hideLoading() {
    final context = AppConfig.navigatorKey.currentContext;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Show confirmation dialog
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    NotificationType type = NotificationType.warning,
  }) async {
    final context = AppConfig.navigatorKey.currentContext;
    if (context == null) return false;

    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Confirmation Dialog',
      barrierColor: Colors.black54,
      transitionDuration: AppConfig.animationDuration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.black,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // Show toast-like notification (non-blocking)
  void showToast({
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final context = AppConfig.navigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-remove after duration
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  // Helper methods
  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppTheme.successGreen;
      case NotificationType.error:
        return AppTheme.errorRed;
      case NotificationType.warning:
        return AppTheme.warningOrange;
      case NotificationType.info:
        return AppTheme.infoBlue;
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
}

class DialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const DialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
  });
} 