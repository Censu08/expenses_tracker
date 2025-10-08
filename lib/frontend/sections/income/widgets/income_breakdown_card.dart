import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/blocs.dart';
import '../../../../backend/models/models.dart';
import '../../../themes/app_theme.dart';
import '../pages/income_page.dart';

class IncomeBreakdownCard extends StatelessWidget {
  final IncomePageState pageState;

  const IncomeBreakdownCard({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppElevations.card,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      child: Container(
        decoration: IncomeTheme.getBreakdownCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.large,
                AppSpacing.large,
                AppSpacing.large,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    child: Icon(
                      Icons.pie_chart_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Text(
                      'Suddivisione Categorie',
                      style: IncomeTheme.getCardTitleStyle(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: pageState.cachedStats.isEmpty
                  ? _buildEmptyState(context)
                  : Builder(
                builder: (context) {
                  final stats = Map<String, double>.from(pageState.cachedStats);

                  if (pageState.selectedSource != null) {
                    final sourceName = pageState.selectedSource!.displayName;
                    stats.removeWhere((key, value) => key != sourceName);
                  }

                  if (stats.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final totalAmount = stats.values.fold(0.0, (sum, amount) => sum + amount);

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      0,
                      AppSpacing.large,
                      AppSpacing.large,
                    ),
                    itemCount: stats.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.small),
                    itemBuilder: (context, index) {
                      final entry = stats.entries.elementAt(index);
                      final percentage = totalAmount > 0
                          ? (entry.value / totalAmount) * 100
                          : 0.0;

                      return _CategoryBreakdownItem(
                        category: entry.key,
                        amount: entry.value,
                        percentage: percentage,
                        index: index,
                      );
                    },
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
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                size: 40,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Nessuna entrata',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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

class _CategoryBreakdownItem extends StatefulWidget {
  final String category;
  final double amount;
  final double percentage;
  final int index;

  const _CategoryBreakdownItem({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.index,
  });

  @override
  State<_CategoryBreakdownItem> createState() =>
      _CategoryBreakdownItemState();
}

class _CategoryBreakdownItemState extends State<_CategoryBreakdownItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 100 + (widget.index * 50)), () {
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

  Color _getCategoryColor(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark
        ? [
      AppColors.secondaryDark,
      AppColors.accentDark,
      AppColors.warningDark,
      AppColors.primaryDark,
      AppColors.errorDark,
      AppColors.secondaryDark.withOpacity(0.8),
      AppColors.warningDark.withOpacity(0.8),
      AppColors.primaryDark.withOpacity(0.8),
    ]
        : [
      AppColors.secondary,
      AppColors.accent,
      AppColors.warning,
      AppColors.primary,
      AppColors.error,
      AppColors.secondary.withOpacity(0.8),
      AppColors.warning.withOpacity(0.8),
      AppColors.primary.withOpacity(0.8),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(widget.index);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: IncomeTheme.getIncomeListTileDecoration(
            context,
            categoryColor,
            isHovered: _isHovered,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.5),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Flexible(
                          child: Text(
                            widget.category,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.small),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Text(
                        '${_progressAnimation.value.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value / 100,
                      backgroundColor: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                      minHeight: 6,
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '€ ${widget.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark.withOpacity(0.8) : AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}