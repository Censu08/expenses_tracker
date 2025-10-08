import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

class IncomeSourceBadge extends StatelessWidget {
  final IncomeSource source;
  final bool showLabel;
  final double? iconSize;
  final bool compact;

  const IncomeSourceBadge({
    Key? key,
    required this.source,
    this.showLabel = true,
    this.iconSize = 16,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactBadge();
    }

    return _buildFullBadge();
  }

  Widget _buildFullBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? AppSpacing.small : 6,
        vertical: showLabel ? 6 : 6,
      ),
      decoration: IncomeTheme.getSourceBadgeDecoration(source.color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            source.icon,
            size: iconSize,
            color: source.color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              source.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: source.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactBadge() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: source.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        source.icon,
        size: iconSize ?? 14,
        color: source.color,
      ),
    );
  }
}

class InteractiveIncomeSourceBadge extends StatelessWidget {
  final IncomeSource source;
  final bool showLabel;

  const InteractiveIncomeSourceBadge({
    Key? key,
    required this.source,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${source.displayName}\n${source.description}',
      child: IncomeSourceBadge(
        source: source,
        showLabel: showLabel,
      ),
    );
  }
}

class IncomeSourceBadgesList extends StatelessWidget {
  final Map<IncomeSource, double> sourceStats;
  final bool showAmounts;

  const IncomeSourceBadgesList({
    Key? key,
    required this.sourceStats,
    this.showAmounts = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (sourceStats.isEmpty) {
      return Text(
        'Nessuna fonte di reddito',
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.small,
      runSpacing: AppSpacing.small,
      children: sourceStats.entries.map((entry) {
        return _SourceBadgeWithAmount(
          source: entry.key,
          amount: entry.value,
          showAmount: showAmounts,
        );
      }).toList(),
    );
  }
}

class _SourceBadgeWithAmount extends StatelessWidget {
  final IncomeSource source;
  final double amount;
  final bool showAmount;

  const _SourceBadgeWithAmount({
    required this.source,
    required this.amount,
    required this.showAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: source.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: source.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            source.icon,
            size: 16,
            color: source.color,
          ),
          const SizedBox(width: 6),
          Text(
            source.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: source.color,
            ),
          ),
          if (showAmount) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: source.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                '€${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: source.color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}