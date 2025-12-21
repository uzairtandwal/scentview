import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    // Prefer PNG logo1 as requested; fall back to SVG/placeholder if needed
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/logo-name/logo1.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (ctx, _, __) {
          return SvgPicture.asset(
            'assets/logo-name/Name.svg',
            width: size,
            height: size,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => Icon(Icons.image_rounded, size: size),
          );
        },
      ),
    );
  }
}
