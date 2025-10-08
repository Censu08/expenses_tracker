import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../themes/app_theme.dart';
import 'diversification_score_card.dart';
import 'income_source_bar_chart.dart';
import 'income_source_pie_chart.dart';

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
        BlocListener<IncomeBloc, IncomeState>(
          listener: (context, state) {},
        ),
      ],
      child: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
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
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.large),
          DiversificationScoreCard(
            score: score,
            sourceStats: stats,
            showDetails: true,
          ),
          const SizedBox(height: AppSpacing.large),
          IncomeSourcePieChartCard(
            sourceStats: stats,
            title: 'Distribuzione Fonti',
            showLegend: true,
          ),
          const SizedBox(height: AppSpacing.large),
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
      padding: const EdgeInsets.all(AppSpacing.xLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.xLarge),
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
              const SizedBox(width: AppSpacing.large),
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
          const SizedBox(height: AppSpacing.large),
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
      padding: const EdgeInsets.all(AppSpacing.xxxLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.xxxLarge),
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
              const SizedBox(width: AppSpacing.large),
              Expanded(
                flex: 3,
                child: IncomeSourcePieChartCard(
                  sourceStats: stats,
                  title: 'Distribuzione Fonti',
                  showLegend: true,
                ),
              ),
              const SizedBox(width: AppSpacing.large),
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
          const SizedBox(height: AppSpacing.large),
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
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      dateRange,
                      style: IncomeTheme.getLabelTextStyle(context).copyWith(fontSize: 14),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insights = _generateInsights(stats, score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: isDark ? AppColors.warningDark : AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.medium),
                Text(
                  'Insights & Raccomandazioni',
                  style: IncomeTheme.getCardTitleStyle(context).copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.small),
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
    final primarySource = stats.entries.reduce((a, b) => a.value > b.value ? a : b);
    final primaryPercentage = (primarySource.value / totalAmount) * 100;

    if (primaryPercentage > 70) {
      insights.add(
        'Dipendi al ${primaryPercentage.toStringAsFixed(0)}% da ${primarySource.key.displayName}. '
            'Considera di sviluppare fonti alternative.',
      );
    } else if (primaryPercentage > 50) {
      insights.add(
        '${primarySource.key.displayName} rappresenta ${primaryPercentage.toStringAsFixed(0)}% '
            'del tuo reddito. Buon equilibrio, ma puoi migliorare.',
      );
    } else {
      insights.add('Ottimo! Nessuna fonte supera il 50% del reddito totale.');
    }

    if (stats.length <= 2) {
      insights.add(
        'Hai solo ${stats.length} ${stats.length == 1 ? 'fonte' : 'fonti'} attiva. '
            'Diversifica per ridurre il rischio finanziario.',
      );
    } else if (stats.length <= 4) {
      insights.add(
        'Hai ${stats.length} fonti attive. Buon punto di partenza, '
            'ma puoi esplorare altre opportunità.',
      );
    } else {
      insights.add(
        'Eccellente! Hai ${stats.length} fonti di reddito diverse, '
            'il che riduce significativamente il rischio.',
      );
    }

    if (score < 40) {
      insights.add(
        'Score di diversificazione basso ($score/100). '
            'Focus prioritario: sviluppare nuove fonti di reddito.',
      );
    } else if (score < 70) {
      insights.add(
        'Score moderato ($score/100). '
            'Sei sulla strada giusta, continua a diversificare.',
      );
    }

    final hasPassiveIncome = stats.keys.any(
          (source) => source == IncomeSource.investments || source == IncomeSource.rental,
    );

    if (!hasPassiveIncome) {
      insights.add(
        'Considera di sviluppare fonti di reddito passive '
            'come investimenti o affitti per aumentare la stabilità.',
      );
    }

    return insights;
  }

  Future<int> _calculateDiversificationScore(BuildContext context) async {
    final bloc = context.read<IncomeBloc>();
    bloc.add(LoadDiversificationScoreEvent(userId: userId));

    await Future.delayed(const Duration(milliseconds: 100));

    return Future.value(50);
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? AppColors.errorDark : AppColors.error,
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            'Errore nel caricamento',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.errorDark : AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            message,
            style: IncomeTheme.getLabelTextStyle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xLarge),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 80,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xLarge),
          Text(
            'Nessuna entrata registrata',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxLarge),
            child: Text(
              'Aggiungi le tue entrate per visualizzare '
                  'le statistiche sulle fonti di reddito',
              style: IncomeTheme.getLabelTextStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}