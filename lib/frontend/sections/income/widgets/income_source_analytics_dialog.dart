import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'income_source_pie_chart.dart';
import 'income_source_bar_chart.dart';
import 'diversification_score_card.dart';

/// Dialog fullscreen con analisi completa delle fonti di reddito
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Analisi Fonti di Reddito'),
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
                // Header con periodo
                _buildPeriodHeader(context),
                const SizedBox(height: 24),

                // Layout responsive
                if (isMobile)
                  _buildMobileLayout(context)
                else
                  _buildDesktopLayout(context),

                // Insights
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Periodo Analizzato',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  period,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (startDate != null && endDate != null)
            Text(
              _formatDateRange(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        // Diversification Score
        DiversificationScoreCard(
          score: score,
          sourceStats: sourceStats,
          showDetails: true,
        ),
        const SizedBox(height: 24),

        // Pie Chart
        IncomeSourcePieChartCard(
          sourceStats: sourceStats,
          title: 'Distribuzione Fonti',
          showLegend: true,
        ),
        const SizedBox(height: 24),

        // Bar Chart
        IncomeSourceBarChartCard(
          sourceStats: sourceStats,
          title: 'Confronto Importi',
          horizontal: true,
          height: sourceStats.length * 80.0,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        // Prima riga: Score
        DiversificationScoreCard(
          score: score,
          sourceStats: sourceStats,
          showDetails: true,
        ),
        const SizedBox(height: 24),

        // Seconda riga: Grafici side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pie Chart
            Expanded(
              child: IncomeSourcePieChartCard(
                sourceStats: sourceStats,
                title: 'Distribuzione Fonti',
                showLegend: true,
              ),
            ),
            const SizedBox(width: 24),

            // Bar Chart
            Expanded(
              child: IncomeSourceBarChartCard(
                sourceStats: sourceStats,
                title: 'Confronto Importi',
                horizontal: false,
                height: 350,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsights(BuildContext context) {
    final totalAmount =
    sourceStats.values.fold(0.0, (sum, amount) => sum + amount);
    final primarySource =
    sourceStats.entries.reduce((a, b) => a.value > b.value ? a : b);
    final primaryPercentage = (primarySource.value / totalAmount) * 100;

    final insights = _generateInsights(primaryPercentage);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Insights & Raccomandazioni',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildInsightItem(context, insight),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, _Insight insight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: insight.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            insight.icon,
            color: insight.color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: insight.color.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_Insight> _generateInsights(double primaryPercentage) {
    final insights = <_Insight>[];

    // Insight 1: Dipendenza dalla fonte principale
    if (primaryPercentage > 70) {
      insights.add(_Insight(
        icon: Icons.warning,
        color: Colors.red,
        message:
        'Attenzione! Dipendi al ${primaryPercentage.toStringAsFixed(0)}% '
            'da una singola fonte. Questo rappresenta un rischio finanziario elevato. '
            'Sviluppa fonti alternative per aumentare la stabilità.',
      ));
    } else if (primaryPercentage > 50) {
      insights.add(_Insight(
        icon: Icons.info,
        color: Colors.orange,
        message:
        'La tua fonte principale rappresenta ${primaryPercentage.toStringAsFixed(0)}% '
            'del reddito. È un buon inizio, ma considera di bilanciare meglio le fonti.',
      ));
    } else {
      insights.add(_Insight(
        icon: Icons.check_circle,
        color: Colors.green,
        message:
        'Ottimo! Nessuna fonte supera il 50% del reddito totale. '
            'Questo riduce significativamente il rischio finanziario.',
      ));
    }

    // Insight 2: Numero di fonti
    if (sourceStats.length <= 2) {
      insights.add(_Insight(
        icon: Icons.arrow_upward,
        color: Colors.orange,
        message:
        'Hai solo ${sourceStats.length} ${sourceStats.length == 1 ? 'fonte attiva' : 'fonti attive'}. '
            'Obiettivo consigliato: almeno 3-4 fonti diverse per una buona diversificazione.',
      ));
    } else if (sourceStats.length <= 4) {
      insights.add(_Insight(
        icon: Icons.trending_up,
        color: Colors.blue,
        message:
        'Hai ${sourceStats.length} fonti attive. Buon punto di partenza! '
            'Continua a esplorare opportunità per aumentare la resilienza finanziaria.',
      ));
    } else {
      insights.add(_Insight(
        icon: Icons.stars,
        color: Colors.green,
        message:
        'Eccellente! Con ${sourceStats.length} fonti attive hai una diversificazione superiore alla media. '
            'Questo ti protegge da imprevisti su singole fonti.',
      ));
    }

    // Insight 3: Score-based
    if (score >= 70) {
      insights.add(_Insight(
        icon: Icons.celebration,
        color: Colors.green,
        message:
        'Il tuo score di diversificazione ($score/100) è ottimo! '
            'Mantieni questo equilibrio tra le fonti.',
      ));
    } else if (score >= 40) {
      insights.add(_Insight(
        icon: Icons.work,
        color: Colors.blue,
        message:
        'Score moderato ($score/100). Focus sul prossimo trimestre: '
            'identifica 1-2 nuove opportunità di reddito da sviluppare.',
      ));
    } else {
      insights.add(_Insight(
        icon: Icons.priority_high,
        color: Colors.red,
        message:
        'Score critico ($score/100). Azione richiesta: diversifica urgentemente '
            'le tue fonti di reddito per ridurre la vulnerabilità finanziaria.',
      ));
    }

    // Insight 4: Fonti passive
    final hasPassive = sourceStats.keys.any((source) =>
    source == IncomeSource.investments || source == IncomeSource.rental);

    if (!hasPassive) {
      insights.add(_Insight(
        icon: Icons.psychology,
        color: Colors.purple,
        message:
        'Suggerimento: considera di sviluppare fonti di reddito passive '
            '(investimenti, affitti) per aumentare la stabilità a lungo termine.',
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
      const SnackBar(
        content: Text('Funzionalità condivisione in arrivo!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funzionalità export in arrivo!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Helper class per gli insights
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