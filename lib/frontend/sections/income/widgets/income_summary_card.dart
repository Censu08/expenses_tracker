import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/blocs.dart';
import '../../../themes/app_theme.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';

class IncomeSummaryCard extends StatefulWidget {
  final IncomePageState pageState;

  const IncomeSummaryCard({
    super.key,
    required this.pageState,
  });

  @override
  State<IncomeSummaryCard> createState() => _IncomeSummaryCardState();
}

class _IncomeSummaryCardState extends State<IncomeSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is UserIncomesLoaded) {
          widget.pageState.setState(() {
            widget.pageState.cachedIncomes = state.incomes;
            widget.pageState.cachedStats =
                IncomePageFunctions.calculateStats(state.incomes);
          });
          debugPrint('✅ [IncomePage] Cached ${state.incomes.length} incomes');
        }

        if (state is IncomeCreated) {
          debugPrint('✅ [IncomePage] Income created, reloading...');
          IncomePageFunctions.loadIncomeData(context, widget.pageState);
        }

        if (state is IncomeUpdated) {
          debugPrint('✅ [IncomePage] Income updated, reloading...');
          IncomePageFunctions.loadIncomeData(context, widget.pageState);
        }

        if (state is IncomeDuplicated) {
          debugPrint('✅ [IncomePage] Income duplicated, reloading...');
          IncomePageFunctions.loadIncomeData(context, widget.pageState);
        }

        if (state is IncomeError) {
          debugPrint('❌ [IncomePage] Income error: ${state.message}');
        }
      },
      builder: (context, state) {
        if (state is IncomeLoading && widget.pageState.cachedIncomes.isEmpty) {
          return _buildLoadingCard(context);
        }

        if (state is IncomeError && widget.pageState.cachedIncomes.isEmpty) {
          return _buildErrorCard(context, state);
        }

        return _buildSummaryCard(context);
      },
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      elevation: AppElevations.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, IncomeError state) {
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
              state.message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.large),
            ElevatedButton.icon(
              onPressed: () =>
                  IncomePageFunctions.loadIncomeData(context, widget.pageState),
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successColor = isDark ? AppColors.successDark : AppColors.success;
    var filteredIncomes = List.from(widget.pageState.cachedIncomes);

    if (widget.pageState.selectedSource != null) {
      filteredIncomes = filteredIncomes
          .where((income) => income.source == widget.pageState.selectedSource)
          .toList();
    }

    final totalAmount = filteredIncomes.fold(
      0.0,
          (sum, income) => sum + income.amount,
    );
    final incomeCount = filteredIncomes.length;
    final averageAmount = incomeCount > 0 ? totalAmount / incomeCount : 0.0;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: _isHovered ? AppElevations.cardHover : AppElevations.card,
          shadowColor: successColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
          ),
          child: Container(
            decoration: IncomeTheme.getSummaryCardDecoration(
              context,
              isHovered: _isHovered,
            ),
            padding: const EdgeInsets.all(AppSpacing.xLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.small),
                      decoration: IncomeTheme.getIconContainerDecoration(successColor),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.small,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(AppBorderRadius.circle),
                        border: Border.all(
                          color: successColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: successColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Attive',
                            style: TextStyle(
                              color: successColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  'Entrate Totali',
                  style: IncomeTheme.getLabelTextStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '€',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        totalAmount.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: successColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.white).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    border: Border.all(
                      color: successColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Totale Entrate',
                              style: IncomeTheme.getLabelTextStyle(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$incomeCount',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: successColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 35,
                        color: successColor.withOpacity(0.3),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Media',
                              style: IncomeTheme.getLabelTextStyle(context).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '€ ${averageAmount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: successColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}