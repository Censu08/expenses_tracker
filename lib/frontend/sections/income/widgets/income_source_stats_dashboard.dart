import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'diversification_score_card.dart';
import 'income_source_bar_chart.dart';
import 'income_source_pie_chart.dart';


/// Dashboard completa per le statistiche delle fonti di reddito
/// Combina tutti i widget di visualizzazione in un'unica vista
class IncomeSourceStatsDashboard extends StatelessWidget {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const IncomeSourceStatsDashboard({
    Key? key,
    required this.userId,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener per caricare i dati quando serve
        BlocListener<IncomeBloc, IncomeState>(
          listener: (context, state) {
            // Eventuali side effects
          },
        ),
      ],
      child: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
          // Carica dati se non già in stato loaded
          if (state is! IncomeStatsBySourceLoaded &&
              state is! IncomeLoading) {
            context.read<IncomeBloc>().add(
              LoadIncomeStatsBySourceEvent(
                userId: userId,
                startDate: startDate,
                endDate: endDate,
              ),
            );
          }

          if (state is IncomeLoading) {
            return _buildLoadingState(context);
          }

          if (state is IncomeStatsBySourceLoaded) {
            return _buildLoadedState(context, state.stats);
          }

          if (state is IncomeError) {
            return _buildErrorState(context, state.message);
          }

          return _buildEmptyState(context);
        },
      ),
    );
  }

  Widget _buildLoadedState(
      BuildContext context,
      Map<IncomeSource, double> stats,
      ) {
    if (stats.isEmpty) {
      return _buildEmptyState(context);
    }

    final isMobile = ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // Calcola diversification score
    return FutureBuilder<int>(
      future: _calculateDiversificationScore(context),
      builder: (context, snapshot) {
        final score = snapshot.data ?? 0;

        if (isMobile) {
          return _buildMobileLayout(context, stats, score);
        } else if (isTablet) {
          return _buildTabletLayout(context, stats, score);
        } else {
          return _buildDesktopLayout(context, stats, score);
        }
      },
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      Map<IncomeSource, double> stats,
      int score,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 16),

          // Diversification Score
          DiversificationScoreCard(
            score: score,
            sourceStats: stats,
            showDetails: true,
          ),
          const SizedBox(height: 16),

          // Pie Chart
          IncomeSourcePieChartCard(
            sourceStats: stats,
            title: 'Distribuzione Fonti',
            showLegend: true,
          ),
          const SizedBox(height: 16),

          // Bar Chart
          IncomeSourceBarChartCard(
            sourceStats: stats,
            title: 'Confronto Importi',
            horizontal: true,
            height: stats.length * 80.0,
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
      BuildContext context,
      Map<IncomeSource, double> stats,
      int score,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 24),

          // Prima riga: Score + Pie Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: DiversificationScoreCard(
                  score: score,
                  sourceStats: stats,
                  showDetails: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: IncomeSourcePieChartCard(
                  sourceStats: stats,
                  title: 'Distribuzione Fonti',
                  showLegend: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Seconda riga: Bar Chart
          IncomeSourceBarChartCard(
            sourceStats: stats,
            title: 'Confronto Importi',
            horizontal: false,
            height: 300,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      Map<IncomeSource, double> stats,
      int score,
      ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context),
          const SizedBox(height: 32),

          // Prima riga: 3 colonne
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score
              Expanded(
                flex: 2,
                child: DiversificationScoreCard(
                  score: score,
                  sourceStats: stats,
                  showDetails: true,
                ),
              ),
              const SizedBox(width: 20),
              // Pie Chart
              Expanded(
                flex: 3,
                child: IncomeSourcePieChartCard(
                  sourceStats: stats,
                  title: 'Distribuzione Fonti',
                  showLegend: true,
                ),
              ),
              const SizedBox(width: 20),
              // Bar Chart
              Expanded(
                flex: 3,
                child: IncomeSourceBarChartCard(
                  sourceStats: stats,
                  title: 'Confronto Importi',
                  horizontal: false,
                  height: 350,
                ),
              ),
            ],
          ),

          // Insights aggiuntivi
          const SizedBox(height: 20),
          _buildInsightsSection(context, stats, score),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final dateRange = _buildDateRangeText();

    return Column(
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
                    'Analisi Fonti di Reddito',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (dateRange != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      dateRange,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<IncomeBloc>().add(
                  LoadIncomeStatsBySourceEvent(
                    userId: userId,
                    startDate: startDate,
                    endDate: endDate,
                  ),
                );
              },
              tooltip: 'Aggiorna dati',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightsSection(
      BuildContext context,
      Map<IncomeSource, double> stats,
      int score,
      ) {
    final insights = _generateInsights(stats, score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                  size: 24,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  String? _buildDateRangeText() {
    if (startDate == null && endDate == null) {
      return 'Tutti i periodi';
    }
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
    }
    if (startDate != null) {
      return 'Dal ${_formatDate(startDate!)}';
    }
    if (endDate != null) {
      return 'Fino al ${_formatDate(endDate!)}';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<String> _generateInsights(Map<IncomeSource, double> stats, int score) {
    final insights = <String>[];
    final totalAmount = stats.values.fold(0.0, (sum, amount) => sum + amount);
    final primarySource = stats.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final primaryPercentage = (primarySource.value / totalAmount) * 100;

    // Insight sulla fonte principale
    if (primaryPercentage > 70) {
      insights.add(
          'Dipendi al ${primaryPercentage.toStringAsFixed(0)}% da ${primarySource.key.displayName}. '
              'Considera di sviluppare fonti alternative.');
    } else if (primaryPercentage > 50) {
      insights.add(
          '${primarySource.key.displayName} rappresenta ${primaryPercentage.toStringAsFixed(0)}% '
              'del tuo reddito. Buon equilibrio, ma puoi migliorare.');
    } else {
      insights.add(
          'Ottimo! Nessuna fonte supera il 50% del reddito totale.');
    }

    // Insight sul numero di fonti
    if (stats.length <= 2) {
      insights.add(
          'Hai solo ${stats.length} ${stats.length == 1 ? 'fonte' : 'fonti'} attiva. '
              'Diversifica per ridurre il rischio finanziario.');
    } else if (stats.length <= 4) {
      insights.add(
          'Hai ${stats.length} fonti attive. Buon punto di partenza, '
              'ma puoi esplorare altre opportunità.');
    } else {
      insights.add(
          'Eccellente! Hai ${stats.length} fonti di reddito diverse, '
              'il che riduce significativamente il rischio.');
    }

    // Insight sul diversification score
    if (score < 40) {
      insights.add(
          'Score di diversificazione basso ($score/100). '
              'Focus prioritario: sviluppare nuove fonti di reddito.');
    } else if (score < 70) {
      insights.add(
          'Score moderato ($score/100). '
              'Sei sulla strada giusta, continua a diversificare.');
    }

    // Suggerimento fonti passive
    final hasPassiveIncome = stats.keys.any((source) =>
    source == IncomeSource.investments ||
        source == IncomeSource.rental);

    if (!hasPassiveIncome) {
      insights.add(
          'Considera di sviluppare fonti di reddito passive '
              'come investimenti o affitti per aumentare la stabilità.');
    }

    return insights;
  }

  Future<int> _calculateDiversificationScore(BuildContext context) async {
    final bloc = context.read<IncomeBloc>();
    bloc.add(LoadDiversificationScoreEvent(userId: userId));

    // Wait for the state change
    await Future.delayed(const Duration(milliseconds: 100));

    return Future.value(50); // Placeholder - sarà sostituito dal vero valore
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Errore nel caricamento',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<IncomeBloc>().add(
                LoadIncomeStatsBySourceEvent(
                  userId: userId,
                  startDate: startDate,
                  endDate: endDate,
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Nessuna entrata registrata',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Aggiungi le tue entrate per visualizzare '
                  'le statistiche sulle fonti di reddito',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}