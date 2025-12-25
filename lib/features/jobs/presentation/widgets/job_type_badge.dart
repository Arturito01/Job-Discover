import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../data/models/models.dart';

/// Styled badge for job type, work location, and experience level
class JobTypeBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const JobTypeBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  /// Factory for work location badge
  factory JobTypeBadge.workLocation(WorkLocation location) {
    final (bg, text) = switch (location) {
      WorkLocation.remote => (AppColors.badgeRemote, AppColors.badgeRemoteText),
      WorkLocation.hybrid => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E)
        ),
      WorkLocation.onSite => (AppColors.surfaceVariant, AppColors.textSecondary),
    };

    return JobTypeBadge(
      label: location.label,
      backgroundColor: bg,
      textColor: text,
    );
  }

  /// Factory for job type badge
  factory JobTypeBadge.jobType(JobType type) {
    final (bg, text) = switch (type) {
      JobType.fullTime => (AppColors.badgeFullTime, AppColors.badgeFullTimeText),
      JobType.partTime => (
          const Color(0xFFE0E7FF),
          const Color(0xFF3730A3)
        ),
      JobType.contract => (AppColors.badgeContract, AppColors.badgeContractText),
      JobType.internship => (
          const Color(0xFFFCE7F3),
          const Color(0xFF9D174D)
        ),
    };

    return JobTypeBadge(
      label: type.label,
      backgroundColor: bg,
      textColor: text,
    );
  }

  /// Factory for experience level badge
  factory JobTypeBadge.experienceLevel(ExperienceLevel level) {
    return JobTypeBadge(
      label: level.label,
      backgroundColor: AppColors.surfaceVariant,
      textColor: AppColors.textSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
