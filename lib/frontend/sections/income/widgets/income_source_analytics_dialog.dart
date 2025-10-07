import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.withOpacity(0.02),
              Colors.white,
            ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 2,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.purple.shade700],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
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
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodHeader(context),
                const SizedBox(height: 24),
                if (isMobile)
                  _buildMobileLayout(context)
                else
                  _buildDesktopLayout(context),
                const SizedBox(height: 24),
                _buildInsights(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.calendar_today,
              color: Colors.purple.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periodo Analizzato',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  period,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
          if (startDate != null && endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _formatDateRange(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple.shade700,
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
        const SizedBox(height: 24),
        IncomeSourcePieChartCard(
          sourceStats: sourceStats,
          title: 'Distribuzione Fonti',
          showLegend: true,
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 24),
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
            const SizedBox(width: 24),
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
    final insights = _generateInsights();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.05),
            Colors.blue.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue.shade700],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Suggerimenti',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...insights.map((insight) => _buildInsightItem(context, insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, _Insight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              insight.icon,
              color: insight.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              insight.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Insight> _generateInsights() {
    final insights = <_Insight>[];

    if (sourceStats.length == 1) {
      insights.add(_Insight(
        icon: Icons.warning,
        color: Colors.red,
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
        color: Colors.orange,
        message:
        '${dominantSource.key.displayName} rappresenta ${dominantPercentage.toStringAsFixed(0)}% del tuo reddito totale. Valuta di bilanciare meglio le tue fonti.',
      ));
    }

    if (score >= 70) {
      insights.add(_Insight(
        icon: Icons.thumb_up,
        color: Colors.green,
        message:
        'Ottimo score di diversificazione (${score}/100)! Mantieni questo equilibrio tra le tue fonti di reddito.',
      ));
    } else if (score >= 40) {
      insights.add(_Insight(
        icon: Icons.work,
        color: Colors.blue,
        message:
        'Score moderato ($score/100). Identifica 1-2 nuove opportunità di reddito da sviluppare nel prossimo trimestre.',
      ));
    } else {
      insights.add(_Insight(
        icon: Icons.priority_high,
        color: Colors.red,
        message:
        'Score critico ($score/100). Azione richiesta: diversifica urgentemente le tue fonti per ridurre la vulnerabilità finanziaria.',
      ));
    }

    final hasPassive = sourceStats.keys.any((source) =>
    source == IncomeSource.investments || source == IncomeSource.rental);

    if (!hasPassive) {
      insights.add(_Insight(
        icon: Icons.psychology,
        color: Colors.purple,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade100),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Funzionalità condivisione in arrivo!'),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.purple.shade100),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Funzionalità export in arrivo!'),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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