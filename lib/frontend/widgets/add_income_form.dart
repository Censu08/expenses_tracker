import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/models/models.dart';
import '../../backend/blocs/blocs.dart';
import '../../core/providers/bloc_providers.dart';
import '../../core/utils/responsive_utils.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCategories();
    _initializeForm();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.initialIncome != null) {
      final income = widget.initialIncome!;
      _amountController.text = income.amount.toStringAsFixed(2);
      _descriptionController.text = income.description;
      _selectedCategory = income.category;
      _selectedDate = income.incomeDate;
      _isRecurring = income.isRecurring;

      if (income.recurrenceSettings != null) {
        _recurrenceType = income.recurrenceSettings!.type;
        _necessityLevel = income.recurrenceSettings!.necessityLevel;
        _endDate = income.recurrenceSettings!.endDate;
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: BlocListener<IncomeBloc, IncomeState>(
                listener: (context, state) {
                  if (state is IncomeCreated || state is IncomeUpdated) {
                    widget.onIncomeAdded();
                  } else if (state is IncomeError) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAmountField(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        _buildCategorySelector(),
                        const SizedBox(height: 16),
                        _buildDateSelector(),
                        const SizedBox(height: 16),
                        _buildRecurrenceSection(),
                      ],
                    ),
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
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AllUserCategoriesLoaded) {
          _categories = state.categories;
        }

        return DropdownButtonFormField<CategoryModel>(
          decoration: InputDecoration(
            labelText: 'Categoria',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          value: _selectedCategory,
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Row(
                children: [
                  Icon(category.icon, color: category.color, size: 20),
                  const SizedBox(width: 8),
                  Text(category.description),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategory = value);
          },
          validator: (value) {
            if (value == null) {
              return 'Seleziona una categoria';
            }
            return null;
          },
        );
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
                      color: _endDate != null
                          ? null
                          : Theme.of(context).hintColor,
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
        return Icons.low_priority;
      case NecessityLevel.medium:
        return Icons.priority_high;
      case NecessityLevel.high:
        return Icons.warning;
      case NecessityLevel.critical:
        return Icons.error;
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
        return Colors.red[900]!;
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate.add(const Duration(days: 365)),
      firstDate: _selectedDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _endDate = pickedDate);
    }
  }

  void _saveIncome() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = context.read<UserBloc>().state is UserAuthenticated
        ? (context.read<UserBloc>().state as UserAuthenticated).user.id
        : null;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore: utente non autenticato'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

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
      context.read<IncomeBloc>().add(CreateIncomeEvent(
        userId: userId,
        amount: amount,
        description: description,
        categoryId: _selectedCategory!.id,
        incomeDate: _selectedDate,
        isRecurring: _isRecurring,
        recurrenceSettings: recurrenceSettings,
      ));
    } else {
      // Aggiorna entrata esistente
      context.read<IncomeBloc>().add(UpdateIncomeEvent(
        userId: userId,
        incomeId: widget.initialIncome!.id,
        amount: amount,
        description: description,
        categoryId: _selectedCategory!.id,
        incomeDate: _selectedDate,
        isRecurring: _isRecurring,
        recurrenceSettings: recurrenceSettings,
      ));
    }
  }
}