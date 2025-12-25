import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/storage/settings_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../providers/job_providers.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_sheet.dart';
import '../widgets/job_search_bar.dart';
import '../widgets/jobs_loading_skeleton.dart';

/// Main job listing screen with search, filters, pull-to-refresh, and pagination
class JobListScreen extends ConsumerStatefulWidget {
  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Infinite scroll - load more when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    // Simulate loading more (in real app, this would fetch next page)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    // Haptic feedback on refresh
    final hapticEnabled = ref.read(settingsProvider).hapticFeedbackEnabled;
    if (hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    ref.invalidate(jobsProvider);
    // Wait for the provider to reload
    await ref.read(jobsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);
    final filters = ref.watch(jobFiltersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with settings button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find your next',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Dream Job',
                          style: AppTypography.displayLarge,
                        ),
                      ],
                    ),
                  ),
                  // Settings button
                  IconButton(
                    onPressed: () => context.push(AppRoutes.settings),
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            const Gap.sm(),

            // Search bar
            Padding(
              padding: AppSpacing.screenPadding,
              child: JobSearchBar(
                onChanged: (query) {
                  ref.read(jobFiltersProvider.notifier).setSearchQuery(query);
                },
                onFilterTap: () => _showFilterSheet(context, ref),
                filterCount: filters.activeFilterCount,
              ),
            ),

            const Gap.md(),

            // Results count and filter chips
            Padding(
              padding: AppSpacing.screenPadding,
              child: jobsAsync.when(
                data: (jobs) => Row(
                  children: [
                    Text(
                      '${jobs.length} jobs found',
                      style: AppTypography.bodyMedium,
                    ),
                    if (filters.hasActiveFilters) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ref.read(jobFiltersProvider.notifier).clearFilters();
                        },
                        child: Text(
                          'Clear filters',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Job list with pull-to-refresh
            Expanded(
              child: jobsAsync.when(
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return _buildEmptyState(context, filters.hasActiveFilters);
                  }
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.xl,
                      ),
                      itemCount: jobs.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => const Gap.sm(),
                      itemBuilder: (context, index) {
                        // Loading indicator at bottom
                        if (index == jobs.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        return JobCard(
                          job: jobs[index],
                          // Add staggered animation
                          animationDelay: Duration(milliseconds: index * 50),
                        );
                      },
                    ),
                  );
                },
                loading: () => const JobsLoadingSkeleton(),
                error: (error, _) => _buildErrorState(context, ref, error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    // Haptic feedback
    final hapticEnabled = ref.read(settingsProvider).hapticFeedbackEnabled;
    if (hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const JobFilterSheet(),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasFilters) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const Gap.md(),
                  Text(
                    hasFilters ? 'No matching jobs' : 'No jobs available',
                    style: AppTypography.headlineSmall,
                  ),
                  const Gap.xs(),
                  Text(
                    hasFilters
                        ? 'Try adjusting your filters to see more results'
                        : 'Pull down to refresh',
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const Gap.md(),
                  Text(
                    'Something went wrong',
                    style: AppTypography.headlineSmall,
                  ),
                  const Gap.xs(),
                  Text(
                    'Pull down to refresh or tap retry',
                    style: AppTypography.bodyMedium,
                  ),
                  const Gap.lg(),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(jobsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
