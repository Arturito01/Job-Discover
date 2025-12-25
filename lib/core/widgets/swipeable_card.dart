import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';

/// A swipeable card wrapper that provides Tinder-like swipe gestures
/// Swipe right to save/bookmark, swipe left to dismiss
class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;
  final bool enableHaptics;
  final String rightLabel;
  final String leftLabel;
  final IconData rightIcon;
  final IconData leftIcon;
  final Color rightColor;
  final Color leftColor;

  const SwipeableCard({
    super.key,
    required this.child,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.enableHaptics = true,
    this.rightLabel = 'Save',
    this.leftLabel = 'Skip',
    this.rightIcon = Icons.bookmark_rounded,
    this.leftIcon = Icons.close_rounded,
    this.rightColor = const Color(0xFF10B981),
    this.leftColor = const Color(0xFFEF4444),
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  late AnimationController _controller;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _rotationAnimation;
  bool _dragUnderway = false;

  static const double _swipeThreshold = 100;
  static const double _maxRotation = 0.1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragUnderway = false;
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (_dragExtent.abs() > _swipeThreshold || velocity.abs() > 800) {
      // Swipe detected
      if (_dragExtent > 0 || velocity > 800) {
        _completeSwipe(true);
      } else {
        _completeSwipe(false);
      }
    } else {
      // Return to center
      _animateBack();
    }
  }

  void _completeSwipe(bool isRight) {
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = isRight ? screenWidth : -screenWidth;

    _moveAnimation = Tween<Offset>(
      begin: Offset(_dragExtent, 0),
      end: Offset(targetX, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragExtent / 500 * _maxRotation,
      end: isRight ? _maxRotation : -_maxRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0).then((_) {
      if (isRight) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
      // Reset for potential reuse
      setState(() {
        _dragExtent = 0;
      });
      _controller.reset();
    });
  }

  void _animateBack() {
    _moveAnimation = Tween<Offset>(
      begin: Offset(_dragExtent, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _rotationAnimation = Tween<double>(
      begin: _dragExtent / 500 * _maxRotation,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragExtent = 0;
      });
      _controller.reset();
    });
  }

  double get _currentRotation {
    if (_dragUnderway) {
      return _dragExtent / 500 * _maxRotation;
    }
    return _rotationAnimation.value;
  }

  Offset get _currentOffset {
    if (_dragUnderway) {
      return Offset(_dragExtent, 0);
    }
    return _moveAnimation.value;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragExtent / _swipeThreshold).clamp(-1.0, 1.0);

    return Stack(
      children: [
        // Background indicators
        Positioned.fill(
          child: Row(
            children: [
              // Left indicator (dismiss)
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: progress < -0.3 ? (-progress - 0.3) / 0.7 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.leftColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.leftIcon,
                          color: widget.leftColor,
                          size: 32,
                        ),
                        const Gap.xxs(),
                        Text(
                          widget.leftLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: widget.leftColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right indicator (save)
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: progress > 0.3 ? (progress - 0.3) / 0.7 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.rightColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.rightIcon,
                          color: widget.rightColor,
                          size: 32,
                        ),
                        const Gap.xxs(),
                        Text(
                          widget.rightLabel,
                          style: AppTypography.labelMedium.copyWith(
                            color: widget.rightColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // The card itself
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _currentOffset,
              child: Transform.rotate(
                angle: _currentRotation,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onHorizontalDragStart: _handleDragStart,
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
