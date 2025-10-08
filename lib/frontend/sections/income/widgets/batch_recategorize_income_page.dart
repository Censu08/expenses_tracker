import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

class BatchRecategorizeIncomePage extends StatefulWidget {
  const BatchRecategorizeIncomePage({Key? key}) : super(key: key);

  @override
  State<BatchRecategorizeIncomePage> createState() =>
      _BatchRecategorizeIncomePageState();
}

class _BatchRecategorizeIncomePageState
    extends State<BatchRecategorizeIncomePage> {
  List<IncomeModel> _allIncomes = [];
  final Set<String> _selectedIds = {};
  IncomeSource? _filterSource;
  IncomeSource? _targetSource;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  void _loadIncomes() {
    final userId = context.currentUserId;
    if (userId == null) return;

    context.read<IncomeBloc>().add(LoadUserIncomesEvent(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.warning.withOpacity(0.02),
              isDark ? AppColors.backgroundDark : AppColors.background,
            ],
          ),
        ),
        child: BlocListener<IncomeBloc, IncomeState>(
          listener: (context, state) {
            if (state is UserIncomesLoaded) {
              setState(() {
                _allIncomes = state.incomes;
                _isLoading = false;
              });
            }
            if (state is IncomeUpdated) {
              if (_isUpdating) {
                return;
              }
              _loadIncomes();
            }
            if (state is IncomeError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Errore: ${state.message}'),
                  backgroundColor: isDark ? AppColors.errorDark : AppColors.error,
                ),
              );
            }
          },
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ),
      bottomNavigationBar: _selectedIds.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: const Text('Re-categorizzazione Batch'),
      actions: [
        if (_selectedIds.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => setState(() => _selectedIds.clear()),
            tooltip: 'Deseleziona tutto',
          ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildFilters(),
        _buildStats(),
        Expanded(child: _buildIncomesList()),
      ],
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? AppColors.surfaceDark : AppColors.surface,
            isDark ? AppColors.backgroundDark : Colors.white,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: isDark ? AppColors.warningDark : AppColors.warning,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Filtra per fonte attuale',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Tutte',
                  isSelected: _filterSource == null,
                  onTap: () => setState(() {
                    _filterSource = null;
                    _selectedIds.clear();
                  }),
                  color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.small),
                ...IncomeSource.values.map((source) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.small),
                    child: _buildFilterChip(
                      label: source.displayName,
                      icon: source.icon,
                      isSelected: _filterSource == source,
                      onTap: () => setState(() {
                        _filterSource = source;
                        _selectedIds.clear();
                      }),
                      color: source.color,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.circle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: AppSpacing.small),
        decoration: IncomeTheme.getFilterChipDecoration(color, isSelected: isSelected),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.check_circle, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredIncomes = _getFilteredIncomes();
    final selectedCount = _selectedIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.medium),
      decoration: BoxDecoration(
        color: _selectedIds.isNotEmpty
            ? AppColors.secondary.withOpacity(0.08)
            : (isDark ? AppColors.backgroundDark : Colors.white),
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${filteredIncomes.length} ${filteredIncomes.length == 1 ? 'entrata' : 'entrate'}${_filterSource != null ? ' (${_filterSource!.displayName})' : ''}',
              style: IncomeTheme.getLabelTextStyle(context),
            ),
          ),
          if (selectedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? AppColors.secondaryDark : AppColors.secondary,
                    (isDark ? AppColors.secondaryDark : AppColors.secondary).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppBorderRadius.circle),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$selectedCount ${selectedCount == 1 ? 'selezionata' : 'selezionate'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncomesList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredIncomes = _getFilteredIncomes();

    if (filteredIncomes.isEmpty) {
      return Center(
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
                Icons.check_circle_outline,
                size: 64,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xLarge),
            Text(
              _filterSource != null
                  ? 'Nessuna entrata con fonte "${_filterSource!.displayName}"'
                  : 'Nessuna entrata trovata',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.large),
      itemCount: filteredIncomes.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.medium),
      itemBuilder: (context, index) {
        final income = filteredIncomes[index];
        final isSelected = _selectedIds.contains(income.id);

        return _buildIncomeCard(income, isSelected);
      },
    );
  }

  Widget _buildIncomeCard(IncomeModel income, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isSelected ? AppElevations.cardHover : AppElevations.card,
      shadowColor: isSelected
          ? AppColors.secondary.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        side: BorderSide(
          color: isSelected ? (isDark ? AppColors.secondaryDark : AppColors.secondary) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSelection(income.id),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            gradient: isSelected
                ? LinearGradient(
              colors: [
                AppColors.secondary.withOpacity(0.08),
                AppColors.secondary.withOpacity(0.04),
              ],
            )
                : null,
          ),
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(income.id),
                  activeColor: isDark ? AppColors.secondaryDark : AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Container(
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: IncomeTheme.getIconContainerDecoration(income.source.color),
                child: Icon(
                  income.source.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      income.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.small,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: IncomeTheme.getSourceBadgeDecoration(income.source.color),
                          child: Text(
                            income.source.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: income.source.color,
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
                        const SizedBox(width: 4),
                        Text(
                          '${income.incomeDate.day}/${income.incomeDate.month}/${income.incomeDate.year}',
                          style: IncomeTheme.getLabelTextStyle(context).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '€${income.amount.toStringAsFixed(2)}',
                style: IncomeTheme.getAmountTextStyle(context).copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: isDark ? AppColors.warningDark : AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Seleziona nuova fonte',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                border: Border.all(
                  color: _targetSource != null
                      ? _targetSource!.color.withOpacity(0.3)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: DropdownButtonFormField<IncomeSource>(
                value: _targetSource,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                    vertical: AppSpacing.medium,
                  ),
                ),
                hint: const Text('Scegli fonte'),
                items: IncomeSource.values.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Row(
                      children: [
                        Icon(source.icon, size: 20, color: source.color),
                        const SizedBox(width: AppSpacing.medium),
                        Text(
                          source.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _targetSource = value),
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _targetSource != null && !_isUpdating
                    ? _applyChanges
                    : null,
                icon: _isUpdating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.check, size: 20),
                label: Text(
                  _isUpdating
                      ? 'Aggiornamento...'
                      : 'Applica a ${_selectedIds.length} ${_selectedIds.length == 1 ? 'entrata' : 'entrate'}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
                  backgroundColor: isDark ? AppColors.warningDark : AppColors.warning,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                  ),
                  elevation: AppElevations.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<IncomeModel> _getFilteredIncomes() {
    if (_filterSource == null) return _allIncomes;
    return _allIncomes.where((i) => i.source == _filterSource).toList();
  }

  void _toggleSelection(String incomeId) {
    setState(() {
      if (_selectedIds.contains(incomeId)) {
        _selectedIds.remove(incomeId);
      } else {
        _selectedIds.add(incomeId);
      }
    });
  }

  Future<void> _applyChanges() async {
    if (_targetSource == null) return;

    setState(() => _isUpdating = true);

    try {
      final userId = context.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      for (final incomeId in _selectedIds) {
        final income = _allIncomes.firstWhere((i) => i.id == incomeId);

        context.read<IncomeBloc>().add(UpdateIncomeEvent(
          userId: userId,
          incomeId: incomeId,
          amount: income.amount,
          description: income.description,
          categoryId: '',
          incomeDate: income.incomeDate,
          source: _targetSource!,
          isRecurring: income.isRecurring,
          recurrenceSettings: income.recurrenceSettings,
        ));

        await Future.delayed(const Duration(milliseconds: 100));
      }

      setState(() {
        _selectedIds.clear();
        _targetSource = null;
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_selectedIds.length} ${_selectedIds.length == 1 ? 'entrata aggiornata' : 'entrate aggiornate'}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      _loadIncomes();
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}