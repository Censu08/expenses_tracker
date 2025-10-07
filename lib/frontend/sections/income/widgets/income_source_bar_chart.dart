import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../backend/models/income/income_source_enum.dart';

/// Grafico a barre per confrontare gli importi tra diverse fonti di reddito
class IncomeSourceBarChart extends StatefulWidget {
  final Map<IncomeSource, double> sourceStats;
  final bool showValues;
  final double? height;
  final bool horizontal;

  const IncomeSourceBarChart({
    Key? key,
    required this.sourceStats,
    this.showValues = true,
    this.height,
    this.horizontal = false,
  }) : super(key: key);

  @override
  State<IncomeSourceBarChart> createState() => _IncomeSourceBarChartState();
}

class _IncomeSourceBarChartState extends State<IncomeSourceBarChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.sourceStats.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: widget.height ?? 300,
      child: widget.horizontal
          ? _buildHorizontalBarChart()
          : _buildVerticalBarChart(),
    );
  }

  Widget _buildVerticalBarChart() {
    final sortedEntries = widget.sourceStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = sortedEntries.first.value;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _touchedIndex = null;
                return;
              }
              _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final source = sortedEntries[groupIndex].key;
              return BarTooltipItem(
                '${source.displayName}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '€${rod.toY.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: source.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= sortedEntries.length) {
                  return const SizedBox.shrink();
                }
                final source = sortedEntries[value.toInt()].key;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        source.icon,
                        size: 18,
                        color: source.color,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getShortName(source.displayName),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '€${(value / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: _buildBarGroups(sortedEntries),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
      swapAnimationCurve: Curves.easeInOutQuad,
    );
  }

  Widget _buildHorizontalBarChart() {
    final sortedEntries = widget.sourceStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.separated(
      padding: EdgeInsets.zero, // ⬅️ FIX: Remove default padding
      itemCount: sortedEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8), // ⬅️ FIX: Reduced from 12
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        final source = entry.key;
        final amount = entry.value;
        final maxAmount = sortedEntries.first.value;
        final percentage = (amount / maxAmount);

        return _buildHorizontalBar(
          context,
          source,
          amount,
          percentage,
        );
      },
    );
  }

  Widget _buildHorizontalBar(
      BuildContext context,
      IncomeSource source,
      double amount,
      double percentage,
      ) {
    // ⬅️ FIX: Wrapped in ConstrainedBox to prevent overflow
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 50, // Minimum height for bar
        maxHeight: 70, // Maximum height to prevent overflow
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ⬅️ FIX: Use min size
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, name, amount
          Row(
            children: [
              Icon(
                source.icon,
                size: 18, // ⬅️ FIX: Reduced from 20
                color: source.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  source.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // ⬅️ FIX: Explicit smaller size
                  ),
                  maxLines: 1, // ⬅️ FIX: Prevent text overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '€${amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // ⬅️ FIX: Explicit size
                  color: source.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // ⬅️ FIX: Reduced from 8

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6), // ⬅️ FIX: Reduced radius
            child: SizedBox(
              height: 10, // ⬅️ FIX: Explicit height instead of minHeight
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: source.color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(source.color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
      List<MapEntry<IncomeSource, double>> sortedEntries,
      ) {
    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final source = entry.value.key;
      final amount = entry.value.value;
      final isTouched = index == _touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: source.color,
            width: isTouched ? 28 : 22,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: sortedEntries.first.value * 1.2,
              color: source.color.withOpacity(0.1),
            ),
          ),
        ],
        showingTooltipIndicators: isTouched ? [0] : [],
      );
    }).toList();
  }

  String _getShortName(String name) {
    // Abbrevia nomi lunghi
    if (name.length <= 8) return name;
    return '${name.substring(0, 6)}..';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nessuna fonte di reddito',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card wrapper per il bar chart
class IncomeSourceBarChartCard extends StatelessWidget {
  final Map<IncomeSource, double> sourceStats;
  final String? title;
  final bool horizontal;
  final double? height;

  const IncomeSourceBarChartCard({
    Key? key,
    required this.sourceStats,
    this.title,
    this.horizontal = false,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ⬅️ FIX: Use min size
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Tooltip(
                    message: 'Confronto importi tra fonti di reddito',
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            // ⬅️ FIX: Wrap in Flexible to prevent overflow
            Flexible(
              child: IncomeSourceBarChart(
                sourceStats: sourceStats,
                horizontal: horizontal,
                height: height,
              ),
            ),
          ],
        ),
      ),
    );
  }
}