import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../themes/app_theme.dart';
import 'income_source_pie_chart.dart';
import 'income_source_bar_chart.dart';
import 'diversification_score_card.dart';

class IncomeSourceAnalyticsDialog extends StatelessWidget {
  final Map<IncomeSource, double> sourceStats;
  final int score;
  final DateTime? startDate;
  final DateTime? endDate;
  final String period;

  const IncomeSourceAnalyticsDialog({
    Key? key,
    required this.sourceStats,
    required this.score,
    this.startDate,
    this.endDate,
    required this.period,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: AppColors.primary.withOpacity(0.5),
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.5),
        ),
        child: Scaffold(
          backgroundColor: AppColors.primary.withOpacity(0.5),
          appBar: AppBar(
            elevation: AppElevations.card,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.small),
                  decoration: IncomeTheme.getIconContainerDecoration(
                    isDark ? AppColors.accentDark : AppColors.accent,
                  ),
                  child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSpacing.medium),
                const Text('Analisi Fonti di Reddito'),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _handleShare(context),
                tooltip: 'Condividi',
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _handleExport(context),
                tooltip: 'Esporta',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? AppSpacing.large : AppSpacing.xxxLarge),
            child: ColoredBox(
              color: AppColors.primary.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodHeader(context),
                  const SizedBox(height: AppSpacing.xLarge),
                  if (isMobile)
                    _buildMobileLayout(context)
                  else
                    _buildDesktopLayout(context),
                  const SizedBox(height: AppSpacing.xLarge),
                  _buildInsights(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.1),
            accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Icon(
              Icons.calendar_today,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periodo Analizzato',
                  style: IncomeTheme.getLabelTextStyle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  period,
                  style: IncomeTheme.getCardTitleStyle(context).copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          if (startDate != null && endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Text(
                _formatDateRange(),
                style: TextStyle(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        DiversificationScoreCard(
          score: score,
          sourceStats: sourceStats,
          showDetails: true,
        ),
        const SizedBox(height: AppSpacing.xLarge),
        IncomeSourcePieChartCard(
          sourceStats: sourceStats,
          title: 'Distribuzione Fonti',
          showLegend: true,
        ),
        const SizedBox(height: AppSpacing.xLarge),
        IncomeSourceBarChartCard(
          sourceStats: sourceStats,
          title: 'Confronto Importi',
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        DiversificationScoreCard(
          score: score,
          sourceStats: sourceStats,
          showDetails: true,
        ),
        const SizedBox(height: AppSpacing.xLarge),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: IncomeSourcePieChartCard(
                sourceStats: sourceStats,
                title: 'Distribuzione Fonti',
                showLegend: true,
              ),
            ),
            const SizedBox(width: AppSpacing.xLarge),
            Expanded(
              child: IncomeSourceBarChartCard(
                sourceStats: sourceStats,
                title: 'Confronto Importi',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsights(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final insights = _generateInsights(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryColor.withOpacity(0.05),
            secondaryColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: secondaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: IncomeTheme.getIconContainerDecoration(secondaryColor),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Text(
                'Suggerimenti',
                style: IncomeTheme.getCardTitleStyle(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.large),
          ...insights.map((insight) => _buildInsightItem(context, insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, _Insight insight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: insight.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: insight.color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppBorderRadius.small),
            ),
            child: Icon(
              insight.icon,
              color: insight.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Text(
              insight.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Insight> _generateInsights(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = <_Insight>[];

    if (sourceStats.length == 1) {
      insights.add(_Insight(
        icon: Icons.warning,
        color: isDark ? AppColors.errorDark : AppColors.error,
        message:
        'Attenzione: dipendi da una sola fonte di reddito. Considera di diversificare per ridurre il rischio finanziario.',
      ));
    }

    final dominantSource = sourceStats.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final totalAmount = sourceStats.values.fold(0.0, (sum, val) => sum + val);
    final dominantPercentage = (dominantSource.value / totalAmount) * 100;

    if (dominantPercentage > 70) {
      insights.add(_Insight(
        icon: Icons.pie_chart,
        color: isDark ? AppColors.warningDark : AppColors.warning,
        message:
        '${dominantSource.key.displayName} rappresenta ${dominantPercentage.toStringAsFixed(0)}% del tuo reddito totale. Valuta di bilanciare meglio le tue fonti.',
      ));
    }

    if (score >= 70) {
      insights.add(_Insight(
        icon: Icons.thumb_up,
        color: isDark ? AppColors.successDark : AppColors.success,
        message:
        'Ottimo score di diversificazione (${score}/100)! Mantieni questo equilibrio tra le tue fonti di reddito.',
      ));
    } else if (score >= 40) {
      insights.add(_Insight(
        icon: Icons.work,
        color: isDark ? AppColors.secondaryDark : AppColors.secondary,
        message:
        'Score moderato ($score/100). Identifica 1-2 nuove opportunità di reddito da sviluppare nel prossimo trimestre.',
      ));
    } else {
      insights.add(_Insight(
        icon: Icons.priority_high,
        color: isDark ? AppColors.errorDark : AppColors.error,
        message:
        'Score critico ($score/100). Azione richiesta: diversifica urgentemente le tue fonti per ridurre la vulnerabilità finanziaria.',
      ));
    }

    final hasPassive = sourceStats.keys.any((source) =>
    source == IncomeSource.investments || source == IncomeSource.rental);

    if (!hasPassive) {
      insights.add(_Insight(
        icon: Icons.psychology,
        color: isDark ? AppColors.accentDark : AppColors.accent,
        message:
        'Considera di sviluppare fonti di reddito passive (investimenti, affitti) per aumentare la stabilità a lungo termine.',
      ));
    }

    return insights;
  }

  String _formatDateRange() {
    if (startDate == null || endDate == null) return '';
    return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleShare(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: (isDark ? AppColors.secondaryDark : AppColors.secondary).withOpacity(0.8),
            ),
            const SizedBox(width: AppSpacing.medium),
            const Expanded(
              child: Text('Funzionalità condivisione in arrivo!'),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.secondaryDark : AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
      ),
    );
  }

  void _handleExport(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: (isDark ? AppColors.accentDark : AppColors.accent).withOpacity(0.8),
            ),
            const SizedBox(width: AppSpacing.medium),
            const Expanded(
              child: Text('Funzionalità export in arrivo!'),
            ),
          ],
        ),
        backgroundColor: isDark ? AppColors.accentDark : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.small),
        ),
      ),
    );
  }
}

class _Insight {
  final IconData icon;
  final Color color;
  final String message;

  _Insight({
    required this.icon,
    required this.color,
    required this.message,
  });
}