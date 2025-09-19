import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class ExpenseSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Riepilogo Mensile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dicembre 2024',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            isMobile
                ? _buildMobileSummaryItems(context)
                : _buildDesktopSummaryItems(context),
            SizedBox(height: isMobile ? 12 : 16),
            LinearProgressIndicator(
              value: 0.62,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '62% del budget mensile utilizzato',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSummaryItems(BuildContext context) {
    return Column(
      children: [
        _buildSummaryItem(
          context,
          'Spese Totali',
          '€ 1.247,50',
          Icons.trending_up,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildSummaryItem(
          context,
          'Budget Rimasto',
          '€ 752,50',
          Icons.account_balance_wallet,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildDesktopSummaryItems(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            context,
            'Spese Totali',
            '€ 1.247,50',
            Icons.trending_up,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            context,
            'Budget Rimasto',
            '€ 752,50',
            Icons.account_balance_wallet,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      BuildContext context,
      String label,
      String amount,
      IconData icon,
      Color color,
      ) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 14 : 16),
              SizedBox(width: isMobile ? 3 : 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 3 : 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }
}