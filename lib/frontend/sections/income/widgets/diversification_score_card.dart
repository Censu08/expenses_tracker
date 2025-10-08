import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

class DiversificationScoreCard extends StatelessWidget {
  final int score;
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
    final scoreLevel = _getScoreLevel(context, score);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diversificazione',
                          style: IncomeTheme.getCardTitleStyle(context),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          scoreLevel.description,
                          style: IncomeTheme.getLabelTextStyle(context),
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xLarge),

              Center(
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: _buildGauge(context, scoreLevel),
                ),
              ),

              const SizedBox(height: AppSpacing.xLarge),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.medium,
                  ),
                  decoration: BoxDecoration(
                    color: scoreLevel.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.circle),
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
                      const SizedBox(width: AppSpacing.medium),
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

              if (showDetails && sourceStats != null) ...[
                const SizedBox(height: AppSpacing.xLarge),
                const Divider(),
                const SizedBox(height: AppSpacing.large),
                _buildDetails(context, scoreLevel),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGauge(BuildContext context, _ScoreLevel scoreLevel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            startDegreeOffset: 180,
            sections: [
              PieChartSectionData(
                value: 100,
                color: isDark
                    ? AppColors.textSecondaryDark.withOpacity(0.2)
                    : AppColors.textSecondary.withOpacity(0.2),
                radius: 25,
                showTitle: false,
              ),
            ],
            sectionsSpace: 0,
            centerSpaceRadius: 60,
          ),
        ),
        PieChart(
          PieChartData(
            startDegreeOffset: 180,
            sections: [
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
              style: IncomeTheme.getLabelTextStyle(context),
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
        const SizedBox(height: AppSpacing.medium),
        _buildDetailRow(
          context,
          Icons.source,
          'Fonti attive',
          '$sourceCount ${sourceCount == 1 ? 'fonte' : 'fonti'}',
        ),
        const SizedBox(height: AppSpacing.small),
        _buildDetailRow(
          context,
          primarySource.key.icon,
          'Fonte principale',
          '${primarySource.key.displayName} (${primaryPercentage.toStringAsFixed(1)}%)',
          iconColor: primarySource.key.color,
        ),
        const SizedBox(height: AppSpacing.large),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            label,
            style: IncomeTheme.getLabelTextStyle(context),
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
      color = Theme.of(context).brightness == Brightness.dark
          ? AppColors.successDark
          : AppColors.success;
    } else if (score >= 50) {
      recommendation = 'Buona diversificazione, ma puoi migliorare aggiungendo altre fonti.';
      icon = Icons.warning_amber;
      color = Theme.of(context).brightness == Brightness.dark
          ? AppColors.warningDark
          : AppColors.warning;
    } else if (score >= 30) {
      recommendation = 'Dipendi troppo da poche fonti. Considera di diversificare.';
      icon = Icons.error_outline;
      color = Theme.of(context).brightness == Brightness.dark
          ? AppColors.warningDark
          : AppColors.warning;
    } else {
      recommendation = 'Attenzione! Dipendi quasi totalmente da una fonte. Diversifica urgentemente.';
      icon = Icons.error;
      color = Theme.of(context).brightness == Brightness.dark
          ? AppColors.errorDark
          : AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
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
          const SizedBox(width: AppSpacing.medium),
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

  _ScoreLevel _getScoreLevel(BuildContext context, int score) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (score >= 80) {
      return _ScoreLevel(
        label: 'Eccellente',
        description: 'Le tue entrate sono molto diversificate',
        color: isDark ? AppColors.successDark : AppColors.success,
        icon: Icons.stars,
      );
    } else if (score >= 60) {
      return _ScoreLevel(
        label: 'Buono',
        description: 'Buon livello di diversificazione',
        color: isDark ? AppColors.successDark.withOpacity(0.8) : AppColors.success.withOpacity(0.8),
        icon: Icons.thumb_up,
      );
    } else if (score >= 40) {
      return _ScoreLevel(
        label: 'Moderato',
        description: 'C\'è spazio per migliorare',
        color: isDark ? AppColors.warningDark : AppColors.warning,
        icon: Icons.warning_amber,
      );
    } else if (score >= 20) {
      return _ScoreLevel(
        label: 'Basso',
        description: 'Dipendi da poche fonti',
        color: isDark ? AppColors.warningDark : AppColors.warning.withOpacity(0.9),
        icon: Icons.error_outline,
      );
    } else {
      return _ScoreLevel(
        label: 'Critico',
        description: 'Altamente concentrato su una fonte',
        color: isDark ? AppColors.errorDark : AppColors.error,
        icon: Icons.dangerous,
      );
    }
  }
}

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
    final color = _getScoreColor(score, context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
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
              const SizedBox(width: AppSpacing.large),
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
                    const SizedBox(height: AppSpacing.xs),
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark.withOpacity(0.4)
                    : AppColors.textSecondary.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (score >= 70) return isDark ? AppColors.successDark : AppColors.success;
    if (score >= 50) return isDark ? AppColors.successDark.withOpacity(0.8) : AppColors.success.withOpacity(0.8);
    if (score >= 30) return isDark ? AppColors.warningDark : AppColors.warning;
    return isDark ? AppColors.errorDark : AppColors.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 70) return 'Eccellente';
    if (score >= 50) return 'Buono';
    if (score >= 30) return 'Moderato';
    return 'Basso';
  }
}

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