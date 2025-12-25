import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/settings_provider.dart';
import '../../../../core/theme/theme.dart';

/// Onboarding screen data
class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// Onboarding screen
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    OnboardingPage(
      title: 'Discover Opportunities',
      subtitle: 'Browse thousands of jobs from top companies tailored to your skills and preferences.',
      icon: Icons.search_rounded,
      color: Color(0xFF2563EB),
    ),
    OnboardingPage(
      title: 'Smart Filters',
      subtitle: 'Find exactly what you\'re looking for with powerful filters for location, salary, and job type.',
      icon: Icons.tune_rounded,
      color: Color(0xFF10B981),
    ),
    OnboardingPage(
      title: 'One-Click Apply',
      subtitle: 'Apply to jobs instantly with your saved profile. Track all your applications in one place.',
      icon: Icons.touch_app_rounded,
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref.read(settingsProvider.notifier).setHasSeenOnboarding(true);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageContent(page: _pages[index]);
                },
              ),
            ),

            // Indicators and buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _PageIndicator(
                        isActive: index == _currentPage,
                        color: _pages[index].color,
                      ),
                    ),
                  ),

                  const Gap.xl(),

                  // Next/Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: _pages[_currentPage].color,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final OnboardingPage page;

  const _OnboardingPageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.color,
            ),
          ),

          const Gap.xxl(),

          // Title
          Text(
            page.title,
            style: AppTypography.displayLarge,
            textAlign: TextAlign.center,
          ),

          const Gap.md(),

          // Subtitle
          Text(
            page.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _PageIndicator({
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
