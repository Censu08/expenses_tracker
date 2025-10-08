import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../core/providers/bloc_providers.dart';
import '../../../themes/app_theme.dart';
import '../pages/income_page.dart';

class IncomeSourceBreakdownCard extends StatelessWidget {
  final IncomePageState pageState;

  const IncomeSourceBreakdownCard({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    final userId = context.currentUserId;

    if (userId == null) {
      return _buildErrorCard(context, 'Utente non autenticato');
    }

    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        if (state is! IncomeStatsBySourceLoaded) {
          final (startDate, endDate) = _getDateRange();
          context.read<IncomeBloc>().add(
            LoadIncomeStatsBySourceEvent(
              userId: userId,
              startDate: startDate,
              endDate: endDate,
            ),
          );
        }

        if (state is IncomeLoading) {
          return _buildLoadingCard(context);
        }

        if (state is IncomeStatsBySourceLoaded) {
          return _buildBreakdownCard(context, state.stats);
        }

        if (state is IncomeError) {
          return _buildErrorCard(context, state.message);
        }

        return _buildLoadingCard(context);
      },
    );
  }

  (DateTime?, DateTime?) _getDateRange() {
    final now = DateTime.now();
    switch (pageState.selectedPeriod) {
      case 'Questa Settimana':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return (
        DateTime(weekStart.year, weekStart.month, weekStart.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59)
        );
      case 'Questo Mese':
        return (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
      case 'Ultimi 3 Mesi':
        return (
        DateTime(now.year, now.month - 3, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
      case 'Quest\'Anno':
        return (
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59)
        );
      case 'Tutto':
        return (null, null);
      default:
        return (
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59)
        );
    }
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: AppElevations.card,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: AppElevations.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: isDark ? AppColors.errorDark : AppColors.error,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Errore nel caricamento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(
      BuildContext context, Map<IncomeSource, double> stats) {
    var filteredStats = Map<IncomeSource, double>.from(stats);

    if (pageState.selectedSource != null) {
      filteredStats.removeWhere(
              (source, value) => source != pageState.selectedSource);
    }

    final totalAmount = filteredStats.values.fold(0.0, (sum, amount) => sum + amount);
    final sortedEntries = filteredStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: AppElevations.card,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.small),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius:
                          BorderRadius.circular(AppBorderRadius.medium),
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: Text(
                          'Distribuzione per Fonte',
                          style: IncomeTheme.getCardTitleStyle(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Totale Generale',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '€${totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredStats.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  0,
                  AppSpacing.large,
                  AppSpacing.large,
                ),
                itemCount: sortedEntries.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.large),
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  final percentage = totalAmount > 0
                      ? (entry.value / totalAmount) * 100
                      : 0.0;

                  return _SourceBarItem(
                    source: entry.key,
                    amount: entry.value,
                    percentage: percentage,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.large),
              decoration: BoxDecoration(
                color: (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_outlined,
                size: 40,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Nessuna entrata',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'nel periodo selezionato',
              style: IncomeTheme.getLabelTextStyle(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceBarItem extends StatefulWidget {
  final IncomeSource source;
  final double amount;
  final double percentage;
  final int index;

  const _SourceBarItem({
    required this.source,
    required this.amount,
    required this.percentage,
    required this.index,
  });

  @override
  State<_SourceBarItem> createState() => _SourceBarItemState();
}

class _SourceBarItemState extends State<_SourceBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000 + (widget.index * 100)),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage / 100,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(Duration(milliseconds: 100 + (widget.index * 80)), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.source.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppBorderRadius.small),
                    border: Border.all(
                      color: widget.source.color.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.source.icon,
                    color: widget.source.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Text(
                    widget.source.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.source.color,
                            widget.source.color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppBorderRadius.small),
                        boxShadow: [
                          BoxShadow(
                            color: widget.source.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${widget.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.source.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.small),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  child: Container(
                    height: _isHovered ? 32 : 28,
                    decoration: BoxDecoration(
                      color: (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.source.color,
                                  widget.source.color.withOpacity(0.7),
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(AppBorderRadius.medium),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.source.color.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_progressAnimation.value > 0.15)
                          Positioned(
                            left: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                '${widget.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}