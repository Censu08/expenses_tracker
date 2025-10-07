import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/providers/bloc_providers.dart';
import '../pages/income_page.dart';
import 'income_source_analytics_dialog.dart';

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

    context.read<IncomeBloc>().add(LoadDiversificationScoreEvent(
      userId: userId,
    ));

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
        if (state is IncomeCreated ||
            state is IncomeUpdated ||
            state is IncomeDeleted) {
          _loadPreviewData();
        }
      },
      child: Card(
        elevation: 3,
        shadowColor: Colors.blue.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _showAnalyticsDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withOpacity(0.05),
                  Colors.purple.withOpacity(0.05),
                ],
              ),
            ),
            child: _isLoading ? _buildLoadingState() : _buildButtonContent(context),
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
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'Caricamento...',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
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
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Analisi Fonti',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (_cachedStats != null)
                Text(
                  '${_cachedStats!.length} fonte${_cachedStats!.length != 1 ? 'i' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (_cachedScore != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(_cachedScore!).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getScoreColor(_cachedScore!).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_cachedScore',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(_cachedScore!),
                    height: 1,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 8,
                    color: _getScoreColor(_cachedScore!).withOpacity(0.8),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ],
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    if (_cachedStats == null || _cachedScore == null) {
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