import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Search bar with filter button
class JobSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final int filterCount;

  const JobSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    required this.filterCount,
  });

  @override
  State<JobSearchBar> createState() => _JobSearchBarState();
}

class _JobSearchBarState extends State<JobSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search field
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: _isFocused ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search jobs, companies, skills...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _controller.clear();
                          widget.onChanged('');
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
        ),

        const Gap.sm(),

        // Filter button
        _FilterButton(
          onTap: widget.onFilterTap,
          filterCount: widget.filterCount,
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final int filterCount;

  const _FilterButton({
    required this.onTap,
    required this.filterCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = filterCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: hasFilters ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              color: hasFilters ? Colors.white : AppColors.textSecondary,
            ),
            if (hasFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      filterCount.toString(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
