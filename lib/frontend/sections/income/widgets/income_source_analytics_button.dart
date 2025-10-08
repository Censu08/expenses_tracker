import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/providers/bloc_providers.dart';
import '../../../themes/app_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        elevation: AppElevations.card,
        shadowColor: (isDark ? AppColors.secondaryDark : AppColors.secondary).withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
        ),
        child: InkWell(
          onTap: () => _showAnalyticsDialog(context),
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark ? AppColors.secondaryDark : AppColors.secondary).withOpacity(0.05),
                  (isDark ? AppColors.accentDark : AppColors.accent).withOpacity(0.05),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: AppSpacing.small),
        Flexible(
          child: Text(
            'Caricamento...',
            style: IncomeTheme.getLabelTextStyle(context),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accent;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor.withOpacity(0.2),
                accentColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          ),
          child: Icon(
            Icons.analytics,
            color: secondaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Analisi Fonti',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (_cachedStats != null)
                Text(
                  '${_cachedStats!.length} fonte${_cachedStats!.length != 1 ? 'i' : ''}',
                  style: IncomeTheme.getLabelTextStyle(context).copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (_cachedScore != null) ...[
          const SizedBox(width: AppSpacing.small),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.small,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getScoreColor(_cachedScore!, context).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(
                color: _getScoreColor(_cachedScore!, context).withOpacity(0.5),
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
                    color: _getScoreColor(_cachedScore!, context),
                    height: 1,
                  ),
                ),
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 8,
                    color: _getScoreColor(_cachedScore!, context).withOpacity(0.8),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.small),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? AppColors.textSecondaryDark.withOpacity(0.4) : AppColors.textSecondary.withOpacity(0.4),
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

  Color _getScoreColor(int score, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (score >= 70) return isDark ? AppColors.successDark : AppColors.success;
    if (score >= 50) return isDark ? AppColors.successDark.withOpacity(0.8) : AppColors.success.withOpacity(0.8);
    if (score >= 30) return isDark ? AppColors.warningDark : AppColors.warning;
    return isDark ? AppColors.errorDark : AppColors.error;
  }
}