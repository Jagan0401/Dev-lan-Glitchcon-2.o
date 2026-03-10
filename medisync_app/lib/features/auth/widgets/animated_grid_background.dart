import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Renders the subtle dot-grid background from the login HTML
/// (linear-gradient grid lines at 50px intervals, ~3% opacity teal).
class AnimatedGridBackground extends StatelessWidget {
  const AnimatedGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Paint _paint = Paint()
    ..color = AppColors.primary.withOpacity(0.035)
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 50.0;

    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _paint);
    }
    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
