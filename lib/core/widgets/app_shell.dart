import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../storage/settings_provider.dart';
import '../theme/theme.dart';
import 'offline_indicator.dart';

/// Bottom navigation shell with animated indicator
class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _indicatorAnimation;
  int _previousIndex = 0;

  final _navItems = const [
    _NavItemData(
      icon: Icons.work_outline_rounded,
      activeIcon: Icons.work_rounded,
      label: 'Jobs',
      route: AppRoutes.jobs,
    ),
    _NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.profile)) return 1;
    return 0;
  }

  void _animateToIndex(int newIndex) {
    if (newIndex == _previousIndex) return;

    _indicatorAnimation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: newIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0);
    _previousIndex = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final hapticEnabled = ref.watch(settingsProvider).hapticFeedbackEnabled;

    // Animate indicator when index changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentIndex != _previousIndex) {
        _animateToIndex(currentIndex);
      }
    });

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Stack(
              children: [
                // Animated indicator background
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final itemWidth =
                        (MediaQuery.of(context).size.width - AppSpacing.lg * 2) /
                            _navItems.length;
                    final position = _indicatorAnimation.value * itemWidth;

                    return Positioned(
                      left: position + itemWidth * 0.1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: itemWidth * 0.8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF7C3AED),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Nav items
                Row(
                  children: List.generate(_navItems.length, (index) {
                    final item = _navItems[index];
                    final isActive = currentIndex == index;

                    return Expanded(
                      child: _AnimatedNavItem(
                        icon: item.icon,
                        activeIcon: item.activeIcon,
                        label: item.label,
                        isActive: isActive,
                        onTap: () {
                          if (hapticEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          context.go(item.route);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.3, curve: Curves.easeIn),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = widget.isActive
                ? 1.0 + (_bounceAnimation.value * 0.15) - (_scaleAnimation.value - 1.0).abs() * 0.5
                : 1.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale.clamp(0.8, 1.15),
                  child: Icon(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    size: 26,
                    color: widget.isActive ? Colors.white : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTypography.labelSmall.copyWith(
                    color: widget.isActive ? Colors.white : AppColors.textTertiary,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(widget.label),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
