import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/providers/bloc_providers.dart';
import '../pages/income_page.dart';
import 'income_source_analytics_dialog.dart';

/// Bottone che apre il dialog con l'analisi completa delle fonti di reddito
class IncomeSourceAnalyticsButton extends StatefulWidget {
  final IncomePageState pageState;

  const IncomeSourceAnalyticsButton({
    Key? key,
    required this.pageState,
  }) : super(key: key);

  @override
  State<IncomeSourceAnalyticsButton> createState() =>
      _IncomeSourceAnalyticsButtonState();
}

class _IncomeSourceAnalyticsButtonState
    extends State<IncomeSourceAnalyticsButton> {
  Map<IncomeSource, double>? _cachedStats;
  int? _cachedScore;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreviewData();
  }

  void _loadPreviewData() {
    final userId = context.currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    // Carica solo lo score per preview
    context.read<IncomeBloc>().add(LoadDiversificationScoreEvent(
      userId: userId,
    ));

    // Carica stats per conteggio fonti
    context.read<IncomeBloc>().add(LoadIncomeStatsBySourceEvent(
      userId: userId,
      startDate: _getStartDate(),
      endDate: _getEndDate(),
    ));
  }

  DateTime? _getStartDate() {
    final period = widget.pageState.selectedPeriod;
    final now = DateTime.now();

    switch (period) {
      case 'Questa Settimana':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'Questo Mese':
        return DateTime(now.year, now.month, 1);
      case 'Ultimi 3 Mesi':
        return DateTime(now.year, now.month - 3, 1);
      case 'Quest\'Anno':
        return DateTime(now.year, 1, 1);
      default:
        return null;
    }
  }

  DateTime? _getEndDate() {
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is IncomeStatsBySourceLoaded) {
          setState(() {
            _cachedStats = state.stats;
            _isLoading = false;
          });
        }
        if (state is DiversificationScoreLoaded) {
          setState(() {
            _cachedScore = state.score;
          });
        }
        // Ricarica dopo operazioni CRUD
        if (state is IncomeCreated ||
            state is IncomeUpdated ||
            state is IncomeDeleted) {
          _loadPreviewData();
        }
      },
      child: Card(
        child: InkWell(
          onTap: () => _showAnalyticsDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _isLoading
                ? _buildLoadingState()
                : _buildButtonContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          'Caricamento analisi...',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    return Row(
      children: [
        // Icona + Badge
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.purple.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.analytics,
            color: Colors.blue,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),

        // Testo e Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Analisi Fonti di Reddito',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (_cachedStats != null) ...[
                    Icon(
                      Icons.source,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_cachedStats!.length} ${_cachedStats!.length == 1 ? 'fonte attiva' : 'fonti attive'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else
                    Text(
                      'Tocca per visualizzare',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Score Badge (se disponibile)
        if (_cachedScore != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _getScoreColor(_cachedScore!).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getScoreColor(_cachedScore!).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: _getScoreColor(_cachedScore!),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_cachedScore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(_cachedScore!),
                  ),
                ),
                Text(
                  'su 100',
                  style: TextStyle(
                    fontSize: 9,
                    color: _getScoreColor(_cachedScore!).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Arrow
        const SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_ios,
          size: 20,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    if (_cachedStats == null || _cachedScore == null) {
      // Mostra snackbar se dati non pronti
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caricamento dati in corso...'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => IncomeSourceAnalyticsDialog(
        sourceStats: _cachedStats!,
        score: _cachedScore!,
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        period: widget.pageState.selectedPeriod,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.lightGreen;
    if (score >= 30) return Colors.orange;
    return Colors.red;
  }
}