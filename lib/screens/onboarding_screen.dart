import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';
import 'root_shell.dart';

/// Onboarding / Marketing screen with holographic design
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: HolographicBackground(
        fullScreen: true,
        child: SafeArea(
          child: Stack(
            children: [
              // Abstract wave decorations
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 300),
                  painter: _WaveBackgroundPainter(),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),

                    // Floating credit card
                    Center(
                      child: Hero(
                        tag: 'credit-card',
                        child: Transform.translate(
                          offset: const Offset(0, 20),
                          child: const HolographicCard(
                            width: 300,
                            height: 190,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Title text
                    const Text(
                      'New Age of\nCommercial\nBanking',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.15,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Subtitle
                    Text(
                      'Start by opening an account for your small business now.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Get Started button
                    PrimaryButton(
                      text: 'Get started',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const RootShell(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for subtle wave decorations
class _WaveBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw multiple decorative waves
    for (var i = 0; i < 4; i++) {
      paint.color = Colors.white.withOpacity(0.15 - i * 0.03);

      final path = Path();
      final yOffset = 80.0 + i * 40.0;

      path.moveTo(-20, yOffset);

      for (var x = -20.0; x <= size.width + 20; x += 1) {
        final y = yOffset +
            30 * (0.5 + 0.5 * (x / size.width)) *
                (i % 2 == 0 ? 1 : -1) *
                _wave(x / 80 + i * 0.5);
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }

    // Draw decorative circles
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.1);

    canvas.drawCircle(
      Offset(size.width * 0.85, 60),
      40,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, 180),
      25,
      circlePaint,
    );
  }

  double _wave(double x) {
    return (x - x.floor()) < 0.5
        ? 2 * (x - x.floor())
        : 2 * (1 - (x - x.floor()));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
