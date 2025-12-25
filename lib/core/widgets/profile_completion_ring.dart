import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// An animated circular progress ring for profile completion
class ProfileCompletionRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Duration animationDuration;
  final List<Color>? gradientColors;

  const ProfileCompletionRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.gradientColors,
  });

  @override
  State<ProfileCompletionRing> createState() => _ProfileCompletionRingState();
}

class _ProfileCompletionRingState extends State<ProfileCompletionRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(ProfileCompletionRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: 1.0,
                    strokeWidth: widget.strokeWidth,
                    color: AppColors.surfaceVariant,
                  ),
                ),
                // Progress ring with gradient
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _GradientRingPainter(
                    progress: _progressAnimation.value,
                    strokeWidth: widget.strokeWidth,
                    colors: widget.gradientColors ??
                        const [
                          Color(0xFF2563EB),
                          Color(0xFF7C3AED),
                          Color(0xFF10B981),
                        ],
                  ),
                ),
                // Glow effect at the end
                if (_progressAnimation.value > 0.05)
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _GlowPainter(
                      progress: _progressAnimation.value,
                      strokeWidth: widget.strokeWidth,
                      color: widget.gradientColors?.last ?? const Color(0xFF10B981),
                    ),
                  ),
                // Child content
                if (widget.child != null) widget.child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> colors;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: math.pi * 2 - math.pi / 2,
      colors: colors,
      transform: const GradientRotation(-math.pi / 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start from top
      math.pi * 2 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _GlowPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _GlowPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Calculate end point of arc
    final angle = -math.pi / 2 + math.pi * 2 * progress;
    final endPoint = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    // Draw glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(endPoint, strokeWidth / 2 + 4, glowPaint);

    // Draw bright dot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(endPoint, strokeWidth / 3, dotPaint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// A compact version showing percentage with the ring
class ProfileCompletionBadge extends StatelessWidget {
  final double progress;
  final double size;

  const ProfileCompletionBadge({
    super.key,
    required this.progress,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return ProfileCompletionRing(
      progress: progress,
      size: size,
      strokeWidth: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percentage%',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: percentage == 100 ? const Color(0xFF10B981) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
