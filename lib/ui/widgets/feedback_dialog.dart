import 'package:flutter/material.dart';

// ─── Feedback Type ────────────────────────────────────────────────────────────
enum FeedbackType { success, error, info, warning }

extension _FeedbackTypeX on FeedbackType {
  Color color(ThemeData theme) => switch (this) {
        FeedbackType.success => const Color(0xFF2E7D32),
        FeedbackType.error   => theme.colorScheme.error,
        FeedbackType.info    => theme.colorScheme.primary,
        FeedbackType.warning => const Color(0xFFE65100),
      };

  IconData get icon => switch (this) {
        FeedbackType.success => Icons.check_circle_rounded,
        FeedbackType.error   => Icons.error_outline_rounded,
        FeedbackType.info    => Icons.info_outline_rounded,
        FeedbackType.warning => Icons.warning_amber_rounded,
      };
}

// ─── Main Feedback Dialog ─────────────────────────────────────────────────────
Future<void> showFeedbackDialog(
  BuildContext context, {
  required String title,
  required String message,
  FeedbackType type = FeedbackType.info,
  String? actionText,
  VoidCallback? onAction,
  bool dismissible = true,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 280),
    // ✅ Scale + Fade entry animation
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.82, end: 1.0).animate(curved), child: child),
      );
    },
    pageBuilder: (ctx, _, __) => _FeedbackDialogContent(
      title: title,
      message: message,
      type: type,
      actionText: actionText,
      onAction: onAction,
      dismissible: dismissible,
    ),
  );
}

class _FeedbackDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final FeedbackType type;
  final String? actionText;
  final VoidCallback? onAction;
  final bool dismissible;

  const _FeedbackDialogContent({
    required this.title,
    required this.message,
    required this.type,
    required this.dismissible,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = type.color(theme);
    final icon = type.icon;

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
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 8),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────
            _DialogHeader(color: color, icon: icon, title: title, theme: theme),

            // ── Message ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),

            // ── Buttons ─────────────────────────────────────
            _DialogActions(
              color: color,
              actionText: actionText,
              onAction: onAction,
              dismissible: dismissible,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dialog Header ────────────────────────────────────────────────────────────
class _DialogHeader extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final ThemeData theme;

  const _DialogHeader({
    required this.color,
    required this.icon,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Icon circle
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dialog Actions ───────────────────────────────────────────────────────────
class _DialogActions extends StatelessWidget {
  final Color color;
  final String? actionText;
  final VoidCallback? onAction;
  final bool dismissible;
  final ThemeData theme;

  const _DialogActions({
    required this.color,
    required this.dismissible,
    required this.theme,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          // Cancel button
          if (dismissible) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Primary action button
          Expanded(
            child: ElevatedButton(
              onPressed: onAction ?? () => Navigator.of(context).pop(),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading Dialog ───────────────────────────────────────────────────────────
Future<void> showLoadingDialog(
  BuildContext context, {
  String? message,
  bool dismissible = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Loading',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 220),
    transitionBuilder: (_, anim, __, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween(begin: 0.88, end: 1.0).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOut),
        ),
        child: child,
      ),
    ),
    pageBuilder: (ctx, _, __) => PopScope(
      canPop: dismissible,
      child: _LoadingDialogContent(message: message),
    ),
  );
}

class _LoadingDialogContent extends StatelessWidget {
  final String? message;

  const _LoadingDialogContent({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primary,
                backgroundColor: primary.withValues(alpha: 0.12),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message ?? 'Please wait...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper Functions (complete set) ─────────────────────────────────────────
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionText = 'Great!',
  VoidCallback? onAction,
}) => showFeedbackDialog(
      context,
      title: title,
      message: message,
      type: FeedbackType.success,
      actionText: actionText,
      onAction: onAction,
    );

Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionText = 'Try Again',
  VoidCallback? onAction,
}) => showFeedbackDialog(
      context,
      title: title,
      message: message,
      type: FeedbackType.error,
      actionText: actionText,
      onAction: onAction,
    );

Future<void> showWarningDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionText = 'Got it',
  VoidCallback? onAction,
  bool dismissible = true,
}) => showFeedbackDialog(
      context,
      title: title,
      message: message,
      type: FeedbackType.warning,
      actionText: actionText,
      onAction: onAction,
      dismissible: dismissible,
    );

Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String actionText = 'OK',
  VoidCallback? onAction,
}) => showFeedbackDialog(
      context,
      title: title,
      message: message,
      type: FeedbackType.info,
      actionText: actionText,
      onAction: onAction,
    );
