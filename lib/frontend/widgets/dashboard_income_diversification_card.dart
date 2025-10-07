import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/blocs/income_bloc.dart';
import '../../backend/models/income/income_source_enum.dart';
import '../../core/utils/responsive_utils.dart';
import '../sections/income/widgets/income_source_analytics_dialog.dart';

class DashboardIncomeDiversificationCard extends StatefulWidget {
  const DashboardIncomeDiversificationCard({Key? key}) : super(key: key);

  @override
  State<DashboardIncomeDiversificationCard> createState() =>
      _DashboardIncomeDiversificationCardState();
}

class _DashboardIncomeDiversificationCardState
    extends State<DashboardIncomeDiversificationCard> {
  Map<IncomeSource, double>? _sourceStats;
  int? _score;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final userId = context.currentUserId;
    if (userId == null) return;

    context.read<IncomeBloc>().add(LoadDiversificationScoreEvent(userId: userId));
    context.read<IncomeBloc>().add(LoadIncomeStatsBySourceEvent(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return BlocListener<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is DiversificationScoreLoaded) {
          setState(() {
            _score = state.score;
            _isLoading = false;
          });
        }
        if (state is IncomeStatsBySourceLoaded) {
          setState(() {
            _sourceStats = state.stats;
          });
        }
        if (state is IncomeCreated || state is IncomeUpdated || state is IncomeDeleted) {
          _loadData();
        }
      },
      child: Card(
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: _isLoading ? _buildLoadingState() : _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          'Caricamento...',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final score = _score ?? 0;
    final sourceCount = _sourceStats?.length ?? 0;
    final scoreColor = _getScoreColor(score);
    final scoreLabel = _getScoreLabel(score);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scoreColor.withOpacity(0.2),
                      scoreColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: scoreColor,
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
                      'Diversificazione Entrate',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sourceCount ${sourceCount == 1 ? 'fonte' : 'fonti'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scoreColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: scoreColor),
                    const SizedBox(width: 4),
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScoreBar(score, scoreColor),
              ),
              const SizedBox(width: 8),
              Text(
                scoreLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          if (score < 50) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Diversifica le tue fonti di reddito',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scoreColor.withOpacity(0.2),
                  scoreColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 9,
                      color: scoreColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Diversificazione',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$sourceCount ${sourceCount == 1 ? 'fonte attiva' : 'fonti attive'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                _buildScoreBar(score, scoreColor),
                const SizedBox(height: 4),
                Text(
                  scoreLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      );
    }
  }

  Widget _buildScoreBar(int score, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: LinearProgressIndicator(
          value: score / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  void _handleTap() {
    if (_sourceStats == null || _score == null) {
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
        sourceStats: _sourceStats!,
        score: _score!,
        period: 'Quest\'Anno',
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