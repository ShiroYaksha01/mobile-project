import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PhkaChanPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const PhkaChanPainter({
    this.color = HColors.primaryContainer,
    this.opacity = 0.06,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity);

    const spacing = 24.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x, y),
          1,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}