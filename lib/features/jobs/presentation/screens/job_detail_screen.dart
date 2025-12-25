import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../data/models/models.dart';
import '../../../profile/providers/profile_providers.dart';
import '../../providers/job_providers.dart';
import '../widgets/job_type_badge.dart';

/// Detailed view of a job listing
class JobDetailScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isApplying = false;
  bool _hasApplied = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));
    final isBookmarked = ref.watch(bookmarkedJobsProvider).contains(widget.jobId);
    final appliedJobIds = ref.watch(appliedJobIdsProvider);
    final hasApplied = _hasApplied || appliedJobIds.contains(widget.jobId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          jobAsync.when(
            data: (job) => _buildContent(context, job, isBookmarked, hasApplied),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildError(context),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Color(0xFF2563EB),
                Color(0xFF7C3AED),
                Color(0xFF10B981),
                Color(0xFFF59E0B),
                Color(0xFFEF4444),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: jobAsync.whenData((job) => _buildBottomBar(job, hasApplied)).value,
    );
  }

  Widget _buildContent(
    BuildContext context,
    Job job,
    bool isBookmarked,
    bool hasApplied,
  ) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              ),
              color: isBookmarked ? AppColors.primary : AppColors.textPrimary,
              onPressed: () {
                ref.read(bookmarkedJobsProvider.notifier).toggle(job.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {
                // Share functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share functionality coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company info row
                    Row(
                      children: [
                        _CompanyLogo(logoUrl: job.company.logoUrl),
                        const Gap.sm(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.company.name,
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                job.company.industry,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Gap.md(),

                    // Job title
                    Text(job.title, style: AppTypography.headlineLarge),

                    const Gap.sm(),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const Gap.xxs(),
                        Text(
                          job.company.location,
                          style: AppTypography.bodyMedium,
                        ),
                        const Gap.md(),
                        const Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const Gap.xxs(),
                        Text(
                          job.timeAgo,
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),

                    const Gap.md(),

                    // Badges
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        JobTypeBadge.workLocation(job.workLocation),
                        JobTypeBadge.jobType(job.type),
                        JobTypeBadge.experienceLevel(job.experienceLevel),
                      ],
                    ),

                    const Gap.md(),

                    // Salary
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text(
                        job.type == JobType.contract
                            ? job.salaryRange
                            : '${job.salaryRange} /year',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap.md(),

              // Description section
              _Section(
                title: 'About this role',
                child: Text(job.description, style: AppTypography.bodyLarge),
              ),

              // Responsibilities
              _Section(
                title: 'Responsibilities',
                child: Column(
                  children: job.responsibilities.map((item) {
                    return _BulletPoint(text: item);
                  }).toList(),
                ),
              ),

              // Requirements
              _Section(
                title: 'Requirements',
                child: Column(
                  children: job.requirements.map((item) {
                    return _BulletPoint(text: item);
                  }).toList(),
                ),
              ),

              // Skills
              _Section(
                title: 'Skills',
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: job.skills.map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        skill,
                        style: AppTypography.labelMedium,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Benefits
              _Section(
                title: 'Benefits',
                child: Column(
                  children: job.benefits.map((item) {
                    return _BulletPoint(text: item, icon: Icons.check_circle_outline);
                  }).toList(),
                ),
              ),

              // Company info
              _Section(
                title: 'About ${job.company.name}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.company.about, style: AppTypography.bodyLarge),
                    const Gap.md(),
                    Row(
                      children: [
                        _CompanyInfoChip(
                          icon: Icons.people_outline,
                          label: job.company.size,
                        ),
                        const Gap.xs(),
                        _CompanyInfoChip(
                          icon: Icons.business,
                          label: job.company.industry,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom padding for button
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Job job, bool hasApplied) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: hasApplied || _isApplying
                    ? null
                    : () => _applyToJob(job.id),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: hasApplied ? AppColors.success : AppColors.primary,
                  disabledBackgroundColor:
                      hasApplied ? AppColors.success : AppColors.primary.withValues(alpha: 0.5),
                ),
                child: _isApplying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasApplied ? Icons.check_circle : Icons.send_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const Gap.xs(),
                          Text(
                            hasApplied ? 'Applied' : 'Apply Now',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyToJob(String jobId) async {
    setState(() => _isApplying = true);

    try {
      await ref.read(applyToJobProvider(jobId).future);

      if (mounted) {
        setState(() {
          _isApplying = false;
          _hasApplied = true;
        });

        // Trigger confetti celebration!
        _confettiController.play();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                Gap.xs(),
                Text('Application submitted successfully!'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error,
          ),
          const Gap.md(),
          Text(
            'Failed to load job',
            style: AppTypography.headlineSmall,
          ),
          const Gap.lg(),
          ElevatedButton(
            onPressed: () => ref.invalidate(jobDetailProvider(widget.jobId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String logoUrl;

  const _CompanyLogo({required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: AppColors.surfaceVariant,
        border: Border.all(color: AppColors.border),
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSmall),
          const Gap.sm(),
          child,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final IconData icon;

  const _BulletPoint({
    required this.text,
    this.icon = Icons.fiber_manual_record,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              icon,
              size: icon == Icons.fiber_manual_record ? 8 : 18,
              color: icon == Icons.fiber_manual_record
                  ? AppColors.textSecondary
                  : AppColors.success,
            ),
          ),
          const Gap.xs(),
          Expanded(
            child: Text(text, style: AppTypography.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _CompanyInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CompanyInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const Gap.xxs(),
          Text(label, style: AppTypography.labelMedium),
        ],
      ),
    );
  }
}
