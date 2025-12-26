import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? tintColor;
  final bool showShadow;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppLogo({
    super.key, 
    this.size = 52,
    this.backgroundColor,
    this.tintColor,
    this.showShadow = false,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primary.withOpacity(0.08);
    final logoPadding = padding ?? const EdgeInsets.all(8);

    Widget logoWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: showShadow ? [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ] : null,
      ),
      padding: logoPadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/logo-name/logo1.png',
          width: size - logoPadding.horizontal,
          height: size - logoPadding.vertical,
          fit: BoxFit.contain,
          color: tintColor,
          errorBuilder: (ctx, _, __) {
            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                'assets/logo-name/Name.svg',
                width: size - logoPadding.horizontal,
                height: size - logoPadding.vertical,
                fit: BoxFit.contain,
                colorFilter: tintColor != null 
                    ? ColorFilter.mode(tintColor!, BlendMode.srcIn)
                    : null,
                placeholderBuilder: (_) => Center(
                  child: Icon(
                    Icons.image_rounded,
                    size: (size - logoPadding.horizontal) * 0.6,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Add tap functionality if onTap is provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: logoWidget,
      );
    }

    return logoWidget;
  }
}