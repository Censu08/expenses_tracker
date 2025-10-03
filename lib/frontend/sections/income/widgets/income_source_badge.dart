import 'package:flutter/material.dart';

import '../../../../backend/models/income/income_source_enum.dart';

/// Badge visuale per mostrare la fonte di reddito
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
        horizontal: showLabel ? 8 : 6,
        vertical: showLabel ? 6 : 6,
      ),
      decoration: BoxDecoration(
        color: source.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: source.color.withOpacity(0.3),
          width: 1,
        ),
      ),
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
      padding: const EdgeInsets.all(4),
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

/// Badge con tooltip che mostra info al tap
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

/// Lista di badge per statistiche (mostra tutte le fonti usate)
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
    if (sourceStats.isEmpty) {
      return const Text(
        'Nessuna fonte di reddito',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: source.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: source.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
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