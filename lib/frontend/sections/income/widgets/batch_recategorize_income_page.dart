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
      appBar: AppBar(
        title: const Text('Re-categorizzazione Batch'),
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => setState(() => _selectedIds.clear()),
              tooltip: 'Deseleziona tutto',
            ),
        ],
      ),
      body: BlocListener<IncomeBloc, IncomeState>(
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
      bottomNavigationBar: _selectedIds.isNotEmpty
          ? _buildBottomBar()
          : null,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtra per fonte attuale',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Solo "Altro"',
                  isSelected: _filterSource == IncomeSource.other,
                  onTap: () => setState(() {
                    _filterSource = IncomeSource.other;
                    _selectedIds.clear();
                  }),
                  color: IncomeSource.other.color,
                ),
                const SizedBox(width: 8),
                ...IncomeSource.values
                    .where((s) => s != IncomeSource.other)
                    .map((source) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
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
    Color? color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: color?.withOpacity(0.1),
      selectedColor: color ?? Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color ?? Colors.black,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Widget _buildStats() {
    final filteredIncomes = _getFilteredIncomes();
    final selectedCount = _selectedIds.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _selectedIds.isNotEmpty ? Colors.blue[50] : null,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${filteredIncomes.length} ${filteredIncomes.length == 1 ? 'entrata' : 'entrate'}${_filterSource != null ? ' (${_filterSource!.displayName})' : ''}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (selectedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _filterSource != null
                  ? 'Nessuna entrata con fonte "${_filterSource!.displayName}"'
                  : 'Nessuna entrata trovata',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredIncomes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final income = filteredIncomes[index];
        final isSelected = _selectedIds.contains(income.id);

        return _buildIncomeCard(income, isSelected);
      },
    );
  }

  Widget _buildIncomeCard(IncomeModel income, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue[50] : null,
      child: InkWell(
        onTap: () => _toggleSelection(income.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(income.id),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: income.source.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  income.source.icon,
                  color: income.source.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      income.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: income.source.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
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
                        const SizedBox(width: 8),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
                const Text(
                  'Nuova fonte:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<IncomeSource>(
                    value: _targetSource,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    hint: const Text('Seleziona fonte'),
                    items: IncomeSource.values.map((source) {
                      return DropdownMenuItem(
                        value: source,
                        child: Row(
                          children: [
                            Icon(source.icon, size: 18, color: source.color),
                            const SizedBox(width: 8),
                            Text(source.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _targetSource = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _targetSource == null || _isUpdating
                    ? null
                    : _handleBatchUpdate,
                icon: _isUpdating
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.check),
                label: Text(
                  _isUpdating
                      ? 'Aggiornamento...'
                      : 'Aggiorna ${_selectedIds.length} ${_selectedIds.length == 1 ? 'entrata' : 'entrate'}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _handleBatchUpdate() async {
    if (_targetSource == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Aggiornamento'),
        content: Text(
          'Vuoi aggiornare ${_selectedIds.length} ${_selectedIds.length == 1 ? 'entrata' : 'entrate'} '
              'a "${_targetSource!.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUpdating = true);

    try {
      final userId = context.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      int updated = 0;
      for (final incomeId in _selectedIds) {
        final income = _allIncomes.firstWhere((i) => i.id == incomeId);
        final updatedIncome = income.copyWith(source: _targetSource);

        context.read<IncomeBloc>().add(UpdateIncomeEvent(
          userId: userId,
          incomeId: incomeId,
        ));

        updated++;
        await Future.delayed(const Duration(milliseconds: 50));
      }

      setState(() {
        _selectedIds.clear();
        _targetSource = null;
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$updated ${updated == 1 ? 'entrata aggiornata' : 'entrate aggiornate'}!'),
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