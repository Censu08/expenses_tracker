import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

class IncomeSourceSelector extends StatelessWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onChanged;
  final String? errorText;
  final bool enabled;

  const IncomeSourceSelector({
    Key? key,
    required this.selectedSource,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            border: Border.all(
              color: errorText != null
                  ? (isDark ? AppColors.errorDark : AppColors.error).withOpacity(0.5)
                  : selectedSource != null
                  ? selectedSource!.color.withOpacity(0.3)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
              width: errorText != null ? 2 : 1.5,
            ),
            boxShadow: [
              if (selectedSource != null)
                BoxShadow(
                  color: selectedSource!.color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: DropdownButtonFormField<IncomeSource>(
            value: selectedSource,
            decoration: InputDecoration(
              labelText: 'Fonte di Reddito',
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selectedSource?.color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(AppSpacing.small),
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: selectedSource != null
                    ? IncomeTheme.getIconContainerDecoration(selectedSource!.color)
                    : BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Icon(
                  selectedSource?.icon ?? Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              errorText: errorText,
              filled: !enabled,
              fillColor: enabled ? null : (isDark ? AppColors.surfaceDark : AppColors.surface).withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.large,
                vertical: AppSpacing.large,
              ),
            ),
            items: IncomeSource.values.map((source) {
              return DropdownMenuItem(
                value: source,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.small,
                    horizontal: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: selectedSource == source ? source.color.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.small),
                        decoration: BoxDecoration(
                          color: source.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppBorderRadius.small),
                        ),
                        child: Icon(
                          source.icon,
                          size: 20,
                          color: source.color,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: Text(
                          source.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (selectedSource == source)
                        Icon(
                          Icons.check_circle,
                          color: source.color,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: (value) {
              if (value == null) {
                return 'Seleziona una fonte di reddito';
              }
              return null;
            },
            isExpanded: true,
            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: selectedSource?.color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class CompactIncomeSourceSelector extends StatelessWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onChanged;

  const CompactIncomeSourceSelector({
    Key? key,
    required this.selectedSource,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: selectedSource != null
              ? selectedSource!.color.withOpacity(0.3)
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          if (selectedSource != null)
            BoxShadow(
              color: selectedSource!.color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: selectedSource != null
                ? IncomeTheme.getIconContainerDecoration(selectedSource!.color)
                : BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Icon(
              selectedSource?.icon ?? Icons.account_balance_wallet,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: DropdownButton<IncomeSource>(
              value: selectedSource,
              hint: Text(
                'Seleziona fonte',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: selectedSource?.color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
              dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              items: IncomeSource.values.map((source) {
                return DropdownMenuItem(
                  value: source,
                  child: Row(
                    children: [
                      Icon(source.icon, size: 18, color: source.color),
                      const SizedBox(width: AppSpacing.small),
                      Text(
                        source.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}