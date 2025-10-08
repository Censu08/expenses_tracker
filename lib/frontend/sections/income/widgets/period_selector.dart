import 'package:expenses_tracker/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import '../../../themes/app_theme.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';

class PeriodSelector extends StatefulWidget {
  final IncomePageState pageState;

  const PeriodSelector({
    super.key,
    required this.pageState,
  });

  @override
  State<PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: _isHovered ? AppElevations.cardHover : AppElevations.card,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
          ),
          child: Container(
            decoration: IncomeTheme.getPeriodSelectorDecoration(
              context,
              isHovered: _isHovered,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    decoration: IncomeTheme.getIconContainerDecoration(
                      Theme.of(context).colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.date_range,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  ResponsiveUtils.isDesktop(context) ?
                    Text(
                      'Periodo:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ) : SizedBox.shrink(),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: AppSpacing.small),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: widget.pageState.selectedPeriod,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                        items: widget.pageState.periods.map((period) {
                          final isSelected = period == widget.pageState.selectedPeriod;
                          return DropdownMenuItem(
                            value: period,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                    : null,
                                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(right: AppSpacing.small),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  Text(period),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            widget.pageState.setState(() => widget.pageState.selectedPeriod = value);
                            IncomePageFunctions.loadIncomeData(context, widget.pageState);
                          }
                        },
                      ),
                    ),
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