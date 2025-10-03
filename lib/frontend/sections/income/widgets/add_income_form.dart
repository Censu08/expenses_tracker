import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/category_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/category_model.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../../backend/models/recurrence_model.dart';
import 'income_source_selector.dart';


class AddIncomeForm extends StatefulWidget {
  final IncomeModel? initialIncome;
  final VoidCallback onIncomeAdded;

  const AddIncomeForm({
    super.key,
    this.initialIncome,
    required this.onIncomeAdded,
  });

  @override
  State<AddIncomeForm> createState() => _AddIncomeFormState();
}

class _AddIncomeFormState extends State<AddIncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.monthly;
  NecessityLevel _necessityLevel = NecessityLevel.medium;
  DateTime? _endDate;

  bool _isLoading = false;
  List<CategoryModel> _categories = [];
  bool _hasInitialized = false;
  IncomeSource? _selectedSource;

  @override
  void initState() {
    super.initState();
    if (widget.initialIncome != null) {
      final income = widget.initialIncome!;
      _amountController.text = income.amount.toStringAsFixed(2);
      _descriptionController.text = income.description;
      _selectedDate = income.incomeDate;
      _isRecurring = income.isRecurring;
      _selectedSource = income.source;

      if (income.recurrenceSettings != null) {
        _recurrenceType = income.recurrenceSettings!.type;
        _necessityLevel = income.recurrenceSettings!.necessityLevel;
        _endDate = income.recurrenceSettings!.endDate;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadCategories();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    final userId = context.currentUserId;
    if (userId != null) {
      context.categoryBloc.add(LoadAllUserCategoriesEvent(
        userId: userId,
        isIncome: true,
      ));
    }
  }

  // Rimuove duplicati dalla lista delle categorie usando l'ID come chiave
  List<CategoryModel> _getUniqueCategoriesById(List<CategoryModel> categories) {
    final Map<String, CategoryModel> uniqueMap = {};
    for (final category in categories) {
      uniqueMap[category.id] = category;
    }
    return uniqueMap.values.toList();
  }

  // Trova la categoria corrispondente nella lista usando l'ID
  CategoryModel? _findCategoryById(String categoryId, List<CategoryModel> categories) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildSourceSelector(),
                      const SizedBox(height: 16),
                      _buildDateSelector(),
                      const SizedBox(height: 24),
                      _buildRecurrenceSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.initialIncome == null ? 'Nuova Entrata' : 'Modifica Entrata',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Importo',
        prefixIcon: const Icon(Icons.euro),
        suffixText: '€',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci un importo';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Inserisci un importo valido';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descrizione',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      maxLength: 100,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Inserisci una descrizione';
        }
        if (value.trim().length < 3) {
          return 'La descrizione deve essere di almeno 3 caratteri';
        }
        return null;
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Data',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ricorrenza',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Entrata ricorrente'),
              subtitle: const Text('L\'entrata si ripeterà automaticamente'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() => _isRecurring = value);
              },
            ),
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<RecurrenceType>(
                decoration: InputDecoration(
                  labelText: 'Frequenza',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _recurrenceType,
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getRecurrenceTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _recurrenceType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<NecessityLevel>(
                decoration: InputDecoration(
                  labelText: 'Livello di necessità',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _necessityLevel,
                items: NecessityLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Row(
                      children: [
                        Icon(
                          _getNecessityIcon(level),
                          color: _getNecessityColor(level),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(_getNecessityLabel(level)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _necessityLevel = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectEndDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data fine (opzionale)',
                    prefixIcon: const Icon(Icons.event),
                    suffixIcon: _endDate != null
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'Nessuna data di fine',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _endDate != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceSelector() {
    return IncomeSourceSelector(
      selectedSource: _selectedSource,
      onChanged: (source) {
        setState(() {
          _selectedSource = source;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveIncome,
              child: _isLoading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(widget.initialIncome == null ? 'Crea' : 'Aggiorna'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: _selectedDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una categoria')),
      );
      return;
    }

    // ⬅️ NUOVA VALIDAZIONE SOURCE
    if (_selectedSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una fonte di reddito')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = context.currentUserId;
      if (userId == null) {
        throw Exception('Utente non autenticato');
      }

      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      RecurrenceSettings? recurrenceSettings;
      if (_isRecurring) {
        recurrenceSettings = RecurrenceSettings(
          type: _recurrenceType,
          startDate: _selectedDate,
          endDate: _endDate,
          necessityLevel: _necessityLevel,
        );
      }

      if (widget.initialIncome == null) {
        // Crea nuova entrata
        context.incomeBloc.add(CreateIncomeEvent(
          userId: userId,
          amount: amount,
          description: description,
          categoryId: _selectedCategory!.id,
          incomeDate: _selectedDate,
          source: _selectedSource!, // ⬅️ AGGIUNGERE QUESTO
          isRecurring: _isRecurring,
          recurrenceSettings: recurrenceSettings,
        ));
      } else {
        // Aggiorna entrata esistente
        context.incomeBloc.add(UpdateIncomeEvent(
          userId: userId,
          incomeId: widget.initialIncome!.id,
          amount: amount,
          description: description,
          categoryId: _selectedCategory!.id,
          incomeDate: _selectedDate,
          source: _selectedSource!, // ⬅️ AGGIUNGERE QUESTO
          isRecurring: _isRecurring,
          recurrenceSettings: recurrenceSettings,
        ));
      }

      widget.onIncomeAdded();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: ${e.toString()}')),
        );
      }
    }
  }

  String _getRecurrenceTypeLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Giornaliera';
      case RecurrenceType.weekly:
        return 'Settimanale';
      case RecurrenceType.monthly:
        return 'Mensile';
      case RecurrenceType.yearly:
        return 'Annuale';
      case RecurrenceType.custom:
        return 'Personalizzata';
    }
  }

  String _getNecessityLabel(NecessityLevel level) {
    switch (level) {
      case NecessityLevel.low:
        return 'Bassa';
      case NecessityLevel.medium:
        return 'Media';
      case NecessityLevel.high:
        return 'Alta';
      case NecessityLevel.critical:
        return 'Critica';
    }
  }

  IconData _getNecessityIcon(NecessityLevel level) {
    switch (level) {
      case NecessityLevel.low:
        return Icons.arrow_downward;
      case NecessityLevel.medium:
        return Icons.remove;
      case NecessityLevel.high:
        return Icons.arrow_upward;
      case NecessityLevel.critical:
        return Icons.warning;
    }
  }

  Color _getNecessityColor(NecessityLevel level) {
    switch (level) {
      case NecessityLevel.low:
        return Colors.green;
      case NecessityLevel.medium:
        return Colors.orange;
      case NecessityLevel.high:
        return Colors.red;
      case NecessityLevel.critical:
        return Colors.deepPurple;
    }
  }
}