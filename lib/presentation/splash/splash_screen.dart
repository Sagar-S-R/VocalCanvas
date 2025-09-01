import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Navigate after ~2 seconds to the Auth page
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/auth');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final maxRadius = (size.shortestSide) * 0.6;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Green ripple waves
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    size: size,
                    painter: _RipplePainter(
                      progress: _controller.value,
                      color: primary,
                      maxRadius: maxRadius,
                    ),
                  );
                },
              ),
              // Centered logo (fallback to an Icon if asset missing)
              SizedBox(
                width: size.shortestSide * 0.80,
                height: size.shortestSide * 0.80,
                child: _LogoWidget(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use logo_dark.png for splash screen
    return Image.asset(
      'assets/logo_dark.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        return Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) {
            return const FittedBox(
              fit: BoxFit.contain,
              child: Icon(Icons.palette, color: Colors.teal, size: 64),
            );
          },
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress; // 0 -> 1
  final Color color;
  final double maxRadius;

  _RipplePainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw multiple expanding circles with decreasing opacity
    final waves = 3;
    for (int i = 0; i < waves; i++) {
      final t = (progress + i * 0.25) % 1.0;
      final radius = 8 + t * maxRadius;
      final alpha = (1.0 - t).clamp(0.0, 1.0);
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..color = color.withOpacity(0.25 * alpha);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.maxRadius != maxRadius;
  }
}
