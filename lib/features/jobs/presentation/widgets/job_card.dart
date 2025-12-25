import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/storage/settings_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../data/models/models.dart';
import '../../providers/job_providers.dart';
import 'job_type_badge.dart';

/// Card widget for displaying a job listing with animations
class JobCard extends ConsumerWidget {
  final Job job;
  final Duration animationDelay;

  const JobCard({
    super.key,
    required this.job,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(bookmarkedJobsProvider).contains(job.id);
    final hapticEnabled = ref.watch(settingsProvider).hapticFeedbackEnabled;

    return GestureDetector(
      onTap: () {
        if (hapticEnabled) {
          HapticFeedback.lightImpact();
        }
        context.push(AppRoutes.jobDetailPath(job.id));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with company logo and bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company logo with Hero animation
                  Hero(
                    tag: 'company-logo-${job.id}',
                    child: _CompanyLogo(logoUrl: job.company.logoUrl),
                  ),
                  const Gap.sm(),
                  // Company and job info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.company.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          semanticsLabel: 'Company: ${job.company.name}',
                        ),
                        const Gap.xxs(),
                        Hero(
                          tag: 'job-title-${job.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              job.title,
                              style: AppTypography.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              semanticsLabel: 'Job title: ${job.title}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bookmark button
                  _BookmarkButton(
                    isBookmarked: isBookmarked,
                    onTap: () {
                      if (hapticEnabled) {
                        HapticFeedback.selectionClick();
                      }
                      ref.read(bookmarkedJobsProvider.notifier).toggle(job.id);
                    },
                  ),
                ],
              ),

              const Gap.sm(),

              // Location and time
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                    semanticLabel: 'Location',
                  ),
                  const Gap.xxs(),
                  Expanded(
                    child: Text(
                      job.company.location,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    job.timeAgo,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    semanticsLabel: 'Posted ${job.timeAgo}',
                  ),
                ],
              ),

              const Gap.sm(),

              // Badges row
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  JobTypeBadge.workLocation(job.workLocation),
                  JobTypeBadge.jobType(job.type),
                  JobTypeBadge.experienceLevel(job.experienceLevel),
                ],
              ),

              const Gap.sm(),

              // Salary
              Row(
                children: [
                  Text(
                    job.salaryRange,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                    ),
                    semanticsLabel: 'Salary: ${job.salaryRange}',
                  ),
                  if (job.type != JobType.contract)
                    Text(
                      ' /year',
                      style: AppTypography.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }
}

class _CompanyLogo extends StatelessWidget {
  final String logoUrl;

  const _CompanyLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        color: AppColors.surfaceVariant,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        logoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.business_rounded,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onTap;

  const _BookmarkButton({
    required this.isBookmarked,
    required this.onTap,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.isBookmarked ? 'Remove bookmark' : 'Add bookmark',
      child: GestureDetector(
        onTap: _handleTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: widget.isBookmarked
                  ? AppColors.primary.withValues(alpha:0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                widget.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                key: ValueKey(widget.isBookmarked),
                size: 22,
                color: widget.isBookmarked
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
