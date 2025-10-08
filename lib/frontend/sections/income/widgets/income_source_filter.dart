import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

class IncomeSourceFilter extends StatefulWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onSourceSelected;

  const IncomeSourceFilter({
    Key? key,
    required this.selectedSource,
    required this.onSourceSelected,
  }) : super(key: key);

  @override
  State<IncomeSourceFilter> createState() => _IncomeSourceFilterState();
}

class _IncomeSourceFilterState extends State<IncomeSourceFilter> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 64,
          child: RawScrollbar(
            controller: _scrollController,
            thumbColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            trackColor: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.2),
            trackBorderColor: Colors.transparent,
            radius: Radius.circular(AppBorderRadius.small),
            thickness: 6,
            interactive: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.small),
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.xs,
                ),
                itemCount: IncomeSource.values.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.small),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildFilterChip(
                      context: context,
                      label: 'Tutte',
                      icon: Icons.grid_view,
                      isSelected: widget.selectedSource == null,
                      onTap: () => widget.onSourceSelected(null),
                      color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                    );
                  }

                  final source = IncomeSource.values[index - 1];
                  return _buildFilterChip(
                    context: context,
                    label: source.displayName,
                    icon: source.icon,
                    isSelected: widget.selectedSource == source,
                    onTap: () => widget.onSourceSelected(source),
                    color: source.color,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.circle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        decoration: IncomeTheme.getFilterChipDecoration(color, isSelected: isSelected),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}