import 'package:flutter/material.dart';

enum FeedbackType { success, error, info }

Future<void> showFeedbackDialog(
  BuildContext context, {
  required String title,
  required String message,
  FeedbackType type = FeedbackType.info,
}) async {
  final theme = Theme.of(context);
  final Color color = switch (type) {
    FeedbackType.success => Colors.green,
    FeedbackType.error => theme.colorScheme.error,
    FeedbackType.info => theme.colorScheme.primary,
  };

  final IconData icon = switch (type) {
    FeedbackType.success => Icons.check_circle,
    FeedbackType.error => Icons.error_rounded,
    FeedbackType.info => Icons.info_rounded,
  };

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const SizedBox(width: 4),
              const CircularProgressIndicator(strokeWidth: 2.5),
              const SizedBox(width: 16),
              Expanded(child: Text(message ?? 'Please wait...')),
            ],
          ),
        ),
      );
    },
  );
}
