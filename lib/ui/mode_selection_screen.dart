import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:scentview/admin/admin_home_screen.dart';
import 'package:scentview/ui/main_app_screen.dart';
import 'package:scentview/ui/widgets/app_logo.dart';

/// ⚠️ Dev/Testing only screen — remove from production routes
/// Shows mode selection between User and Admin
class ModeSelectionScreen extends StatelessWidget {
  static const routeName = '/mode-select';
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo + Title ──────────────────────────────
                AppLogo(size: 72, showShadow: true),
                const SizedBox(height: 20),
                Text(
                  'ScentView',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Development Mode',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'Select Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 20),

                // ── User Mode Card ────────────────────────────
                _ModeCard(
                  icon: Iconsax.user,
                  title: 'User Mode',
                  subtitle: 'Browse products & shop',
                  color: primary,
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed(MainAppScreen.routeName),
                ),

                const SizedBox(height: 14),

                // ── Admin Mode Card ───────────────────────────
                _ModeCard(
                  icon: Iconsax.setting,
                  title: 'Admin Mode',
                  subtitle: 'Manage products & orders',
                  color: const Color(0xFFE65100),
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed(AdminHomeScreen.routeName),
                ),

                const SizedBox(height: 32),

                Text(
                  'This screen is for development only.\nRemove before production.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mode Card ────────────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}