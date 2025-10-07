import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../backend/models/income/income_source_enum.dart';

/// Card che mostra il Diversification Score con gauge visuale
class DiversificationScoreCard extends StatelessWidget {
  final int score; // 0-100
  final Map<IncomeSource, double>? sourceStats;
  final bool showDetails;
  final VoidCallback? onTap;

  const DiversificationScoreCard({
    Key? key,
    required this.score,
    this.sourceStats,
    this.showDetails = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scoreLevel = _getScoreLevel(score);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diversificazione',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          scoreLevel.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Score di diversificazione delle fonti di reddito.\n'
                        'Più alto è meglio!',
                    child: Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Gauge
              Center(
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: _buildGauge(context, scoreLevel),
                ),
              ),

              const SizedBox(height: 24),

              // Score Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scoreLevel.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scoreLevel.color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        scoreLevel.icon,
                        color: scoreLevel.color,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            scoreLevel.label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: scoreLevel.color,
                            ),
                          ),
                          Text(
                            'Score: $score/100',
                            style: TextStyle(
                              fontSize: 12,
                              color: scoreLevel.color.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Dettagli
              if (showDetails && sourceStats != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetails(context, scoreLevel),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGauge(BuildContext context, _ScoreLevel scoreLevel) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background arc
        PieChart(
          PieChartData(
            startDegreeOffset: 180,
            sections: [
              // Background
              PieChartSectionData(
                value: 100,
                color: Colors.grey[200],
                radius: 25,
                showTitle: false,
              ),
            ],
            sectionsSpace: 0,
            centerSpaceRadius: 60,
          ),
        ),
        // Score arc
        PieChart(
          PieChartData(
            startDegreeOffset: 180,
            sections: [
              // Filled part
              PieChartSectionData(
                value: score.toDouble(),
                color: scoreLevel.color,
                radius: 25,
                showTitle: false,
                gradient: LinearGradient(
                  colors: [
                    scoreLevel.color,
                    scoreLevel.color.withOpacity(0.7),
                  ],
                ),
              ),
              // Empty part
              PieChartSectionData(
                value: (100 - score).toDouble(),
                color: Colors.transparent,
                radius: 25,
                showTitle: false,
              ),
            ],
            sectionsSpace: 0,
            centerSpaceRadius: 60,
          ),
        ),
        // Center text
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scoreLevel.color,
              ),
            ),
            Text(
              'su 100',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, _ScoreLevel scoreLevel) {
    final sourceCount = sourceStats!.length;
    final totalAmount = sourceStats!.values.fold(0.0, (sum, amount) => sum + amount);
    final primarySource = sourceStats!.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final primaryPercentage = (primarySource.value / totalAmount) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisi',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          context,
          Icons.source,
          'Fonti attive',
          '$sourceCount ${sourceCount == 1 ? 'fonte' : 'fonti'}',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          primarySource.key.icon,
          'Fonte principale',
          '${primarySource.key.displayName} (${primaryPercentage.toStringAsFixed(1)}%)',
          iconColor: primarySource.key.color,
        ),
        const SizedBox(height: 16),
        _buildRecommendation(context, scoreLevel, primaryPercentage),
      ],
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value, {
        Color? iconColor,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation(
      BuildContext context,
      _ScoreLevel scoreLevel,
      double primaryPercentage,
      ) {
    String recommendation;
    IconData icon;
    Color color;

    if (score >= 70) {
      recommendation = 'Ottima diversificazione! Le tue entrate sono ben bilanciate.';
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (score >= 50) {
      recommendation = 'Buona diversificazione, ma puoi migliorare aggiungendo altre fonti.';
      icon = Icons.warning_amber;
      color = Colors.orange;
    } else if (score >= 30) {
      recommendation = 'Dipendi troppo da poche fonti. Considera di diversificare.';
      icon = Icons.error_outline;
      color = Colors.orange;
    } else {
      recommendation = 'Attenzione! Dipendi quasi totalmente da una fonte. Diversifica urgentemente.';
      icon = Icons.error;
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ScoreLevel _getScoreLevel(int score) {
    if (score >= 80) {
      return _ScoreLevel(
        label: 'Eccellente',
        description: 'Le tue entrate sono molto diversificate',
        color: Colors.green,
        icon: Icons.stars,
      );
    } else if (score >= 60) {
      return _ScoreLevel(
        label: 'Buono',
        description: 'Buon livello di diversificazione',
        color: Colors.lightGreen,
        icon: Icons.thumb_up,
      );
    } else if (score >= 40) {
      return _ScoreLevel(
        label: 'Moderato',
        description: 'C\'è spazio per migliorare',
        color: Colors.orange,
        icon: Icons.warning_amber,
      );
    } else if (score >= 20) {
      return _ScoreLevel(
        label: 'Basso',
        description: 'Dipendi da poche fonti',
        color: Colors.deepOrange,
        icon: Icons.error_outline,
      );
    } else {
      return _ScoreLevel(
        label: 'Critico',
        description: 'Altamente concentrato su una fonte',
        color: Colors.red,
        icon: Icons.dangerous,
      );
    }
  }
}

/// Compact version della card
class CompactDiversificationScoreCard extends StatelessWidget {
  final int score;
  final VoidCallback? onTap;

  const CompactDiversificationScoreCard({
    Key? key,
    required this.score,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diversificazione',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScoreLabel(score),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.lightGreen;
    if (score >= 30) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 70) return 'Eccellente';
    if (score >= 50) return 'Buono';
    if (score >= 30) return 'Moderato';
    return 'Basso';
  }
}

/// Helper class per i livelli di score
class _ScoreLevel {
  final String label;
  final String description;
  final Color color;
  final IconData icon;

  _ScoreLevel({
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
  });
}