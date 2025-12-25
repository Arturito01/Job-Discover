import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/theme.dart';

/// Shimmer loading skeleton for profile screen
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const Gap.sm(),
                  // Avatar
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                  const Gap.md(),

                  // Name
                  Container(
                    height: 24,
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                  const Gap.xs(),

                  // Title
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const Gap.sm(),

                  // Location
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const Gap.lg(),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatSkeleton(),
                      Container(width: 1, height: 40, color: AppColors.border),
                      _StatSkeleton(),
                      Container(width: 1, height: 40, color: AppColors.border),
                      _StatSkeleton(),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  const Gap.md(),

                  // Button
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ],
              ),
            ),

            const Gap.md(),

            // About section
            _SectionSkeleton(
              lineCount: 3,
              delay: 350,
            ),

            // Skills section
            _SkillsSkeleton(),

            // Applications section
            _ApplicationsSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 24,
          width: 30,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Gap.xxs(),
        Container(
          height: 12,
          width: 50,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  final int lineCount;
  final int delay;

  const _SectionSkeleton({
    this.lineCount = 2,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Container(
            height: 18,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap.sm(),
          // Lines
          ...List.generate(
            lineCount,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Container(
                height: 14,
                width: index == lineCount - 1
                    ? MediaQuery.of(context).size.width * 0.6
                    : double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay));
  }
}

class _SkillsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap.sm(),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: List.generate(
              6,
              (index) => Container(
                height: 28,
                width: 60 + (index * 10) % 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }
}

class _ApplicationsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap.md(),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                  const Gap.sm(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 150,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap.xxs(),
                        Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 450.ms);
  }
}
