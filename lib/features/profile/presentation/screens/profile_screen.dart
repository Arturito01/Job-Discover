import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/profile_completion_ring.dart';
import '../../../../data/models/models.dart';
import '../../providers/profile_providers.dart';
import '../widgets/profile_skeleton.dart';

/// User profile screen with applied jobs
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Calculate profile completion percentage based on filled fields
  double _calculateProfileCompletion(User user) {
    double score = 0;
    const totalFields = 6;

    // Check each profile field
    if (user.name.isNotEmpty) score++;
    if (user.title.isNotEmpty) score++;
    if (user.location.isNotEmpty) score++;
    if (user.bio.isNotEmpty) score++;
    if (user.skills.isNotEmpty) score++;
    if (user.avatarUrl.isNotEmpty) score++;

    return score / totalFields;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final applicationsAsync = ref.watch(applicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          data: (user) => _buildContent(context, user, applicationsAsync),
          loading: () => const ProfileSkeleton(),
          error: (error, _) => _buildError(context, ref),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    User user,
    AsyncValue<List<Application>> applicationsAsync,
  ) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const Gap.sm(),
                // Avatar with completion ring
                ProfileCompletionRing(
                  progress: _calculateProfileCompletion(user),
                  size: 100,
                  strokeWidth: 4,
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.avatarUrl),
                      onBackgroundImageError: (_, __) {},
                      child: const Icon(Icons.person, size: 40),
                    ),
                  ),
                ),

                const Gap.md(),

                // Name and title
                Text(user.name, style: AppTypography.headlineLarge),
                const Gap.xxs(),
                Text(
                  user.title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const Gap.xs(),

                // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const Gap.xxs(),
                    Text(
                      user.location,
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),

                const Gap.lg(),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(
                      value: applicationsAsync.when(
                        data: (apps) => apps.length.toString(),
                        loading: () => '-',
                        error: (_, __) => '-',
                      ),
                      label: 'Applied',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _StatItem(
                      value: applicationsAsync.when(
                        data: (apps) => apps
                            .where((a) => a.status == ApplicationStatus.interviewing)
                            .length
                            .toString(),
                        loading: () => '-',
                        error: (_, __) => '-',
                      ),
                      label: 'Interviewing',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.border,
                    ),
                    _StatItem(
                      value: user.skills.length.toString(),
                      label: 'Skills',
                    ),
                  ],
                ),

                const Gap.md(),

                // Edit profile button
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: Gap.md()),

        // Bio section
        SliverToBoxAdapter(
          child: _Section(
            title: 'About',
            child: Text(user.bio, style: AppTypography.bodyLarge),
          ),
        ),

        // Skills section
        SliverToBoxAdapter(
          child: _Section(
            title: 'Skills',
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: user.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    skill,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Applications section header
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text('My Applications', style: AppTypography.headlineSmall),
                const Spacer(),
                applicationsAsync.when(
                  data: (apps) => Text(
                    '${apps.length} total',
                    style: AppTypography.bodyMedium,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),

        // Applications list
        applicationsAsync.when(
          data: (applications) {
            if (applications.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const Gap.md(),
                      Text(
                        'No applications yet',
                        style: AppTypography.titleMedium,
                      ),
                      const Gap.xxs(),
                      Text(
                        'Start exploring jobs and apply!',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = applications[index];
                  return _ApplicationCard(
                    application: app,
                    isLast: index == applications.length - 1,
                  );
                },
                childCount: applications.length,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (_, __) => SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: const Text('Failed to load applications'),
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(child: Gap.xl()),
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
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
            'Failed to load profile',
            style: AppTypography.headlineSmall,
          ),
          const Gap.lg(),
          ElevatedButton(
            onPressed: () => ref.invalidate(currentUserProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(label, style: AppTypography.bodySmall),
      ],
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

class _ApplicationCard extends StatelessWidget {
  final Application application;
  final bool isLast;

  const _ApplicationCard({
    required this.application,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.jobDetailPath(application.job.id)),
      child: Container(
        color: AppColors.surface,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          isLast ? AppSpacing.md : AppSpacing.sm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Company logo
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    color: AppColors.surfaceVariant,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    application.job.company.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.business_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),

                const Gap.sm(),

                // Job info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.job.title,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        application.job.company.name,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),

                const Gap.sm(),

                // Status badge
                _StatusBadge(status: application.status),
              ],
            ),

            // Applied date
            Padding(
              padding: const EdgeInsets.only(
                left: 56,
                top: AppSpacing.xxs,
              ),
              child: Row(
                children: [
                  Text(
                    'Applied ${application.appliedDate}',
                    style: AppTypography.labelSmall,
                  ),
                ],
              ),
            ),

            if (!isLast)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Divider(height: 1),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (status) {
      ApplicationStatus.pending => (
          AppColors.surfaceVariant,
          AppColors.textSecondary,
        ),
      ApplicationStatus.reviewed => (
          const Color(0xFFDBEAFE),
          const Color(0xFF1E40AF),
        ),
      ApplicationStatus.interviewing => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
        ),
      ApplicationStatus.offered => (
          const Color(0xFFD1FAE5),
          const Color(0xFF047857),
        ),
      ApplicationStatus.rejected => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
