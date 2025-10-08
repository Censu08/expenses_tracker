import 'package:flutter/material.dart';
import '../../../../backend/models/models.dart';
import '../../../themes/app_theme.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';
import 'income_source_badge.dart';

class IncomeListTile extends StatelessWidget {
  final IncomeModel income;
  final IncomePageState pageState;

  const IncomeListTile({
    super.key,
    required this.income,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.small,
      ),
      leading: CircleAvatar(
        backgroundColor: income.source.color.withOpacity(0.1),
        child: Icon(income.source.icon, color: income.source.color),
      ),
      title: Text(
        income.description,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            income.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(income.source.icon, size: 14, color: income.source.color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                income.source.description,
                style: IncomeTheme.getLabelTextStyle(context),
              ),
              const SizedBox(width: AppSpacing.medium),
              IncomeSourceBadge(
                source: income.source,
                showLabel: true,
                iconSize: 14,
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+€ ${income.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.successDark : AppColors.success,
              fontSize: 16,
            ),
          ),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: AppSpacing.small),
                    Text('Modifica'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 18,
                      color: isDark ? AppColors.errorDark : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Text(
                      'Elimina',
                      style: TextStyle(
                        color: isDark ? AppColors.errorDark : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) => IncomePageFunctions.handleIncomeAction(
              context,
              pageState,
              value as String,
              income,
            ),
          ),
        ],
      ),
      onTap: () => IncomePageFunctions.showIncomeDetails(context, pageState, income),
    );
  }
}