import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/income/income_source_enum.dart';

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
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.withOpacity(0.02),
              Colors.white,
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
                  backgroundColor: Colors.red,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade100,
            Colors.white,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.filter_list, color: Colors.orange, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Filtra per fonte attuale',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                ...IncomeSource.values.map((source) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
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
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          )
              : null,
          color: isSelected ? null : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
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
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(Icons.check_circle, size: 14, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final filteredIncomes = _getFilteredIncomes();
    final selectedCount = _selectedIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _selectedIds.isNotEmpty
            ? Colors.blue.withOpacity(0.08)
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${filteredIncomes.length} ${filteredIncomes.length == 1 ? 'entrata' : 'entrate'}${_filterSource != null ? ' (${_filterSource!.displayName})' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          if (selectedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
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
    final filteredIncomes = _getFilteredIncomes();

    if (filteredIncomes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _filterSource != null
                  ? 'Nessuna entrata con fonte "${_filterSource!.displayName}"'
                  : 'Nessuna entrata trovata',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: filteredIncomes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final income = filteredIncomes[index];
        final isSelected = _selectedIds.contains(income.id);

        return _buildIncomeCard(income, isSelected);
      },
    );
  }

  Widget _buildIncomeCard(IncomeModel income, bool isSelected) {
    return Card(
      elevation: isSelected ? 6 : 2,
      shadowColor: isSelected
          ? Colors.blue.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleSelection(income.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.08),
                Colors.blue.withOpacity(0.04),
              ],
            )
                : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(income.id),
                  activeColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      income.source.color,
                      income.source.color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: income.source.color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  income.source.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      income.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: income.source.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: income.source.color.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            income.source.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: income.source.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${income.incomeDate.day}/${income.incomeDate.month}/${income.incomeDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '€${income.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                Icon(Icons.edit, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Seleziona nuova fonte',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _targetSource != null
                      ? _targetSource!.color.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: DropdownButtonFormField<IncomeSource>(
                value: _targetSource,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Scegli fonte'),
                items: IncomeSource.values.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Row(
                      children: [
                        Icon(source.icon, size: 20, color: source.color),
                        const SizedBox(width: 12),
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
            const SizedBox(height: 16),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
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
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}