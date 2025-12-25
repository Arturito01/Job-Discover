import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../data/models/models.dart';
import '../../providers/job_providers.dart';

/// Bottom sheet for filtering jobs
class JobFilterSheet extends ConsumerWidget {
  const JobFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(jobFiltersProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text('Filters', style: AppTypography.headlineMedium),
                const Spacer(),
                if (filters.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      ref.read(jobFiltersProvider.notifier).clearFilters();
                    },
                    child: Text(
                      'Clear all',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter sections
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Work Location
                  _FilterSection(
                    title: 'Work Location',
                    children: WorkLocation.values.map((location) {
                      return _FilterChip(
                        label: location.label,
                        isSelected: filters.workLocation == location,
                        onTap: () {
                          ref
                              .read(jobFiltersProvider.notifier)
                              .setWorkLocation(location);
                        },
                      );
                    }).toList(),
                  ),

                  const Gap.lg(),

                  // Job Type
                  _FilterSection(
                    title: 'Job Type',
                    children: JobType.values.map((type) {
                      return _FilterChip(
                        label: type.label,
                        isSelected: filters.type == type,
                        onTap: () {
                          ref.read(jobFiltersProvider.notifier).setType(type);
                        },
                      );
                    }).toList(),
                  ),

                  const Gap.lg(),

                  // Experience Level
                  _FilterSection(
                    title: 'Experience Level',
                    children: ExperienceLevel.values.map((level) {
                      return _FilterChip(
                        label: level.label,
                        isSelected: filters.experienceLevel == level,
                        onTap: () {
                          ref
                              .read(jobFiltersProvider.notifier)
                              .setExperienceLevel(level);
                        },
                      );
                    }).toList(),
                  ),

                  const Gap.lg(),
                ],
              ),
            ),
          ),

          // Apply button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  'Show Results',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.titleMedium),
        const Gap.sm(),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: children,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
