import 'package:flutter/material.dart';

enum FeedbackType { success, error, info, warning }

Future<void> showFeedbackDialog(
  BuildContext context, {
  required String title,
  required String message,
  FeedbackType type = FeedbackType.info,
  String? actionText,
  VoidCallback? onAction,
  bool dismissible = true,
}) async {
  final theme = Theme.of(context);
  final Color color = switch (type) {
    FeedbackType.success => Colors.green.shade600,
    FeedbackType.error => theme.colorScheme.error,
    FeedbackType.info => theme.colorScheme.primary,
    FeedbackType.warning => Colors.orange.shade600,
  };

  final IconData icon = switch (type) {
    FeedbackType.success => Icons.check_circle_rounded,
    FeedbackType.error => Icons.error_outline_rounded,
    FeedbackType.info => Icons.info_outline_rounded,
    FeedbackType.warning => Icons.warning_amber_rounded,
  };

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierDismissible: dismissible,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================ HEADER SECTION ================
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: color,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              
              // ================ MESSAGE SECTION ================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
              
              // ================ ACTION BUTTONS ================
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    // Secondary Button (Cancel)
                    if (dismissible)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    
                    if (dismissible && actionText != null) 
                      const SizedBox(width: 12),
                    
                    // Primary Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAction ?? () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          actionText ?? 'OK',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showLoadingDialog(
  BuildContext context, {
  String? message,
  bool dismissible = false,
  Color? backgroundColor,
}) async {
  final theme = Theme.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    barrierDismissible: dismissible,
    builder: (ctx) {
      return PopScope(
        canPop: dismissible,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Loading Indicator
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Loading Message
                Text(
                  message ?? 'Please wait...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                
                // Optional Subtitle
                if (message != null && message.length > 20)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'This may take a moment',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Quick helper functions for common dialogs
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionText = 'Great!',
  VoidCallback? onAction,
}) {
  return showFeedbackDialog(
    context,
    title: title,
    message: message,
    type: FeedbackType.success,
    actionText: actionText,
    onAction: onAction,
  );
}

Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionText = 'Try Again',
  VoidCallback? onAction,
}) {
  return showFeedbackDialog(
    context,
    title: title,
    message: message,
    type: FeedbackType.error,
    actionText: actionText,
    onAction: onAction,
  );
}