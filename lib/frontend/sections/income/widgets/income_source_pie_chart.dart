import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

class IncomeSourcePieChart extends StatefulWidget {
  final Map<IncomeSource, double> sourceStats;
  final bool showLegend;
  final bool showPercentage;
  final double? size;

  const IncomeSourcePieChart({
    Key? key,
    required this.sourceStats,
    this.showLegend = true,
    this.showPercentage = true,
    this.size,
  }) : super(key: key);

  @override
  State<IncomeSourcePieChart> createState() => _IncomeSourcePieChartState();
}

class _IncomeSourcePieChartState extends State<IncomeSourcePieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.sourceStats.isEmpty) {
      return _buildEmptyState(context);
    }

    final totalAmount = widget.sourceStats.values.fold(0.0, (sum, amount) => sum + amount);

    return Column(
      children: [
        SizedBox(
          height: widget.size ?? 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: _buildSections(totalAmount),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedIndex = null;
                          return;
                        }
                        _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeInOutQuad,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '€${totalAmount.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Totale',
                    style: IncomeTheme.getLabelTextStyle(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(height: AppSpacing.large),
          _buildLegend(context, totalAmount),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double totalAmount) {
    final sortedEntries = widget.sourceStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final source = entry.value.key;
      final amount = entry.value.value;
      final percentage = (amount / totalAmount) * 100;
      final isTouched = index == _touchedIndex;

      return PieChartSectionData(
        value: amount,
        title: widget.showPercentage ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 60,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        color: source.color,
        badgeWidget: isTouched
            ? Container(
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            source.icon,
            color: source.color,
            size: 20,
          ),
        )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context, double totalAmount) {
    final sortedEntries = widget.sourceStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Wrap(
      spacing: AppSpacing.medium,
      runSpacing: AppSpacing.medium,
      alignment: WrapAlignment.center,
      children: sortedEntries.map((entry) {
        final source = entry.key;
        final amount = entry.value;
        final percentage = (amount / totalAmount) * 100;

        return InkWell(
          onTap: () {
            setState(() {
              final index = sortedEntries.indexOf(entry);
              _touchedIndex = _touchedIndex == index ? null : index;
            });
          },
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            decoration: BoxDecoration(
              color: source.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
              border: Border.all(
                color: source.color.withOpacity(0.3),
                width: 1.5,
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
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: source.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: source.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            'Nessuna fonte di reddito',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Aggiungi entrate per visualizzare la distribuzione',
            style: IncomeTheme.getLabelTextStyle(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class IncomeSourcePieChartCard extends StatelessWidget {
  final Map<IncomeSource, double> sourceStats;
  final String? title;
  final bool showLegend;

  const IncomeSourcePieChartCard({
    Key? key,
    required this.sourceStats,
    this.title,
    this.showLegend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: IncomeTheme.getCardTitleStyle(context).copyWith(fontSize: 16),
                  ),
                  Tooltip(
                    message: 'Distribuzione percentuale delle fonti di reddito',
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
            ],
            IncomeSourcePieChart(
              sourceStats: sourceStats,
              showLegend: showLegend,
            ),
          ],
        ),
      ),
    );
  }
}