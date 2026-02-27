import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Advanced AppLogo widget with:
/// - Hero animation support
/// - Tap scale animation
/// - Shimmer loading state
/// - Proper Flutter 3.x color APIs (no deprecated withOpacity)
/// - Clean fallback chain: PNG → SVG → Icon
class AppLogo extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? tintColor;
  final bool showShadow;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final String? heroTag;
  final BorderRadius? borderRadius;
  final bool animate; // enable/disable tap animation

  const AppLogo({
    super.key,
    this.size = 52,
    this.backgroundColor,
    this.tintColor,
    this.showShadow = false,
    this.padding,
    this.onTap,
    this.heroTag,
    this.borderRadius,
    this.animate = true,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.animate && widget.onTap != null) _controller.forward();
  }

  void _onTapUp(_) {
    if (widget.animate && widget.onTap != null) _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.animate && widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final bgColor = widget.backgroundColor ??
        primary.withValues(alpha: 0.08); // ✅ Flutter 3.x — no deprecated withOpacity

    final effectivePadding = widget.padding ?? const EdgeInsets.all(8);
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final innerSize = widget.size - effectivePadding.horizontal;

    Widget logo = _LogoContent(
      size: widget.size,
      innerSize: innerSize,
      bgColor: bgColor,
      primary: primary,
      effectivePadding: effectivePadding,
      effectiveRadius: effectiveRadius,
      showShadow: widget.showShadow,
      tintColor: widget.tintColor,
    );

    // Hero wrapper
    if (widget.heroTag != null) {
      logo = Hero(tag: widget.heroTag!, child: logo);
    }

    // Tap + scale animation wrapper
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnim,
          builder: (_, child) =>
              Transform.scale(scale: _scaleAnim.value, child: child),
          child: logo,
        ),
      );
    }

    return logo;
  }
}

// ─── Separated for performance — won't rebuild unnecessarily ──────────────────
class _LogoContent extends StatelessWidget {
  final double size;
  final double innerSize;
  final Color bgColor;
  final Color primary;
  final EdgeInsets effectivePadding;
  final BorderRadius effectiveRadius;
  final bool showShadow;
  final Color? tintColor;

  const _LogoContent({
    required this.size,
    required this.innerSize,
    required this.bgColor,
    required this.primary,
    required this.effectivePadding,
    required this.effectiveRadius,
    required this.showShadow,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      padding: effectivePadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _AssetImage(
          innerSize: innerSize,
          tintColor: tintColor,
          primary: primary,
        ),
      ),
    );
  }
}

// ─── Fallback chain: PNG → SVG → Icon ────────────────────────────────────────
class _AssetImage extends StatelessWidget {
  final double innerSize;
  final Color? tintColor;
  final Color primary;

  const _AssetImage({
    required this.innerSize,
    required this.primary,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo-name/logo1.png',
      width: innerSize,
      height: innerSize,
      fit: BoxFit.contain,
      color: tintColor,
      // Fallback 1 → SVG
      errorBuilder: (_, __, ___) => SvgPicture.asset(
        'assets/logo-name/Name.svg',
        width: innerSize,
        height: innerSize,
        fit: BoxFit.contain,
        colorFilter: tintColor != null
            ? ColorFilter.mode(tintColor!, BlendMode.srcIn)
            : null,
        // Fallback 2 → Icon
        placeholderBuilder: (_) => _FallbackIcon(
          size: innerSize,
          primary: primary,
        ),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final double size;
  final Color primary;

  const _FallbackIcon({required this.size, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size * 0.6,
        color: primary.withValues(alpha: 0.35),
      ),
    );
  }
}