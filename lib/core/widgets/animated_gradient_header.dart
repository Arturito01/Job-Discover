import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An animated gradient header that creates a subtle, mesmerizing background effect
class AnimatedGradientHeader extends StatefulWidget {
  final Widget child;
  final double height;
  final List<Color>? colors;
  final Duration duration;
  final bool animate;

  const AnimatedGradientHeader({
    super.key,
    required this.child,
    this.height = 200,
    this.colors,
    this.duration = const Duration(seconds: 8),
    this.animate = true,
  });

  @override
  State<AnimatedGradientHeader> createState() => _AnimatedGradientHeaderState();
}

class _AnimatedGradientHeaderState extends State<AnimatedGradientHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _defaultColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFF2563EB), // Blue (repeat for seamless loop)
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? _defaultColors;

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _GradientPainter(
                  animation: _controller.value,
                  colors: colors,
                ),
              );
            },
          ),
          // Noise overlay for texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.network(
                'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAKklEQVQIW2NkYGD4D8QMQMzIyMjEgASAYhC5AwcOMDIgASQ2mBwTA8MHAHNIBfqXzZXKAAAAAElFTkSuQmCC',
                repeat: ImageRepeat.repeat,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final double animation;
  final List<Color> colors;

  _GradientPainter({
    required this.animation,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Create shifting gradient centers
    final center1 = Offset(
      size.width * (0.3 + 0.4 * math.sin(animation * 2 * math.pi)),
      size.height * (0.3 + 0.3 * math.cos(animation * 2 * math.pi)),
    );

    final center2 = Offset(
      size.width * (0.7 + 0.3 * math.cos(animation * 2 * math.pi + 1)),
      size.height * (0.6 + 0.3 * math.sin(animation * 2 * math.pi + 1)),
    );

    // Draw first gradient blob
    paint.shader = RadialGradient(
      center: Alignment(
        (center1.dx / size.width) * 2 - 1,
        (center1.dy / size.height) * 2 - 1,
      ),
      radius: 1.2,
      colors: [
        colors[0].withValues(alpha: 0.8),
        colors[0].withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw second gradient blob
    paint.shader = RadialGradient(
      center: Alignment(
        (center2.dx / size.width) * 2 - 1,
        (center2.dy / size.height) * 2 - 1,
      ),
      radius: 1.0,
      colors: [
        colors[1].withValues(alpha: 0.6),
        colors[1].withValues(alpha: 0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_GradientPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

/// A simpler gradient background for cards or smaller areas
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              const [
                Color(0xFF2563EB),
                Color(0xFF7C3AED),
              ],
        ),
      ),
      child: child,
    );
  }
}
