import 'package:flutter/material.dart';
import '../../../../backend/models/models.dart';
import '../../../themes/app_theme.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';

class RecentIncomeCard extends StatelessWidget {
  final IncomePageState pageState;

  const RecentIncomeCard({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedSource = pageState.selectedSource;
    var filteredIncomes = List.from(pageState.cachedIncomes);

    if (selectedSource != null) {
      filteredIncomes = filteredIncomes
          .where((income) => income.source == selectedSource)
          .toList();
    }

    filteredIncomes.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));
    final displayIncomes = filteredIncomes.take(10).toList();

    return Card(
      elevation: AppElevations.card,
      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      child: Container(
        decoration: IncomeTheme.getRecentIncomeCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xLarge,
                AppSpacing.xLarge,
                AppSpacing.xLarge,
                AppSpacing.large,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.small),
                    decoration: IncomeTheme.getIconContainerDecoration(
                      Theme.of(context).colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  Expanded(
                    child: Text(
                      'Entrate Recenti',
                      style: IncomeTheme.getCardTitleStyle(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppBorderRadius.circle),
                    ),
                    child: Text(
                      '${filteredIncomes.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.1),
            ),
            Expanded(
              child: displayIncomes.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.medium,
                ),
                itemCount: displayIncomes.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.small),
                itemBuilder: (context, index) {
                  final income = displayIncomes[index];
                  return _ModernIncomeListTile(
                    income: income,
                    index: index,
                    onTap: () {
                      IncomePageFunctions.showIncomeDetails(
                        context,
                        pageState,
                        income,
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
        padding: const EdgeInsets.all(AppSpacing.xxxLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xLarge),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xLarge),
            Text(
              'Nessuna entrata trovata',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              'Le tue entrate appariranno qui',
              style: IncomeTheme.getLabelTextStyle(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernIncomeListTile extends StatefulWidget {
  final IncomeModel income;
  final int index;
  final VoidCallback onTap;

  const _ModernIncomeListTile({
    required this.income,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ModernIncomeListTile> createState() => _ModernIncomeListTileState();
}

class _ModernIncomeListTileState extends State<_ModernIncomeListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.index * 30), () {
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(_isHovered ? 4 : 0, 0, 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.large),
                decoration: IncomeTheme.getIncomeListTileDecoration(
                  context,
                  widget.income.source.color,
                  isHovered: _isHovered,
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'income_icon_${widget.income.id}',
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.medium),
                        decoration: IncomeTheme.getIconContainerDecoration(
                          widget.income.source.color,
                        ),
                        child: Icon(
                          widget.income.source.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.large),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.income.description,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.small,
                                  vertical: 3,
                                ),
                                decoration: IncomeTheme.getSourceBadgeDecoration(
                                  widget.income.source.color,
                                ),
                                child: Text(
                                  widget.income.source.displayName,
                                  style: TextStyle(
                                    color: widget.income.source.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.small),
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                _formatDate(widget.income.incomeDate),
                                style: IncomeTheme.getLabelTextStyle(context).copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '€ ${widget.income.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.successDark : AppColors.success,
                          ),
                        ),
                        if (widget.income.isRecurring)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 12,
                                  color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Ricorrente',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}