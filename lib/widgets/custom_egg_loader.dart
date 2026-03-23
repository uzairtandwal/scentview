import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomEggLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CustomEggLoader({super.key, this.size = 60, this.color});

  @override
  State<CustomEggLoader> createState() => _CustomEggLoaderState();
}

class _CustomEggLoaderState extends State<CustomEggLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? const Color(0xFFFFD700); // Gold

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _EggPainter(color: color),
            ),
          );
        },
      ),
    );
  }
}

class _EggPainter extends CustomPainter {
  final Color color;

  _EggPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Draw an egg shape using a path
    final path = Path();
    path.addOval(Rect.fromLTRB(
      size.width * 0.1, 
      size.height * 0.2, 
      size.width * 0.9, 
      size.height * 0.9
    ));
    
    // Create a slight egg variation
    final eggPath = Path();
    eggPath.moveTo(size.width / 2, size.height * 0.1);
    eggPath.cubicTo(
      size.width * 0.9, size.height * 0.1, 
      size.width, size.height * 0.9, 
      size.width / 2, size.height * 0.95
    );
    eggPath.cubicTo(
      0, size.height * 0.9, 
      size.width * 0.1, size.height * 0.1, 
      size.width / 2, size.height * 0.1
    );

    canvas.drawPath(eggPath, paint);
    
    // Add some "scent" lines or sparkles
    final sparklePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 2, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.4), 3, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), 2, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
