import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Holographic gradient background used across screens
class HolographicBackground extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool fullScreen;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const HolographicBackground({
    super.key,
    required this.child,
    this.height,
    this.fullScreen = false,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: AppColors.holographicGradient,
          stops: AppColors.holographicStops,
        ),
      ),
      child: child,
    );

    if (fullScreen) {
      return gradient;
    }

    return gradient;
  }
}

/// Custom gradient painter for more complex holographic effects
class HolographicGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.holographicGradient,
      stops: AppColors.holographicStops,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);

    // Add subtle wave overlay effect
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    for (var i = 0; i < 5; i++) {
      path.moveTo(0, size.height * (0.2 + i * 0.15));
      for (var x = 0.0; x < size.width; x += 10) {
        path.lineTo(
          x,
          size.height * (0.2 + i * 0.15) +
              20 * (0.5 - (x / size.width)).abs() * (i % 2 == 0 ? 1 : -1),
        );
      }
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A widget that displays a holographic card floating effect
class HolographicCard extends StatelessWidget {
  final double width;
  final double height;

  const HolographicCard({
    super.key,
    this.width = 280,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(-0.1)
        ..rotateX(0.05),
      alignment: Alignment.center,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.lavender.withOpacity(0.9),
              AppColors.pastelBlue.withOpacity(0.9),
              AppColors.lilac.withOpacity(0.9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.lilac.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Card chip
            Positioned(
              top: 30,
              left: 25,
              child: Container(
                width: 45,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade200,
                      Colors.amber.shade400,
                    ],
                  ),
                ),
              ),
            ),
            // Contactless icon
            Positioned(
              top: 30,
              right: 25,
              child: Icon(
                Icons.wifi,
                color: Colors.white.withOpacity(0.7),
                size: 28,
              ),
            ),
            // Card number placeholder
            Positioned(
              bottom: 50,
              left: 25,
              child: Text(
                '•••• •••• •••• 4589',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ),
            // Bank name
            Positioned(
              bottom: 25,
              left: 25,
              child: Text(
                'SIBEH GOOD BANK',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
