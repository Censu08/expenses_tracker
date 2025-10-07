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

  List<CategoryModel> _getUniqueCategoriesById(List<CategoryModel> categories) {
    final Map<String, CategoryModel> uniqueMap = {};
    for (final category in categories) {
      uniqueMap[category.id] = category;
    }
    return uniqueMap.values.toList();
  }

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
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 650,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
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
                      const SizedBox(height: 18),
                      _buildDescriptionField(),
                      const SizedBox(height: 18),
                      _buildSourceSelector(),
                      const SizedBox(height: 18),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withOpacity(0.15),
            Colors.green.withOpacity(0.08),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              widget.initialIncome == null ? Icons.add_circle : Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              widget.initialIncome == null ? 'Nuova Entrata' : 'Modifica Entrata',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.grey[900],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _amountController,
        decoration: InputDecoration(
          labelText: 'Importo',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.euro, color: Colors.white, size: 20),
          ),
          suffixText: '€',
          suffixStyle: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.green.withOpacity(0.3), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.green.withOpacity(0.3), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade700,
        ),
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
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descrizione',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.description, color: Colors.blue, size: 20),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      maxLength: 100,
      style: const TextStyle(fontWeight: FontWeight.w500),
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

  Widget _buildSourceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonte di Reddito',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        CompactIncomeSourceSelector(
          selectedSource: _selectedSource,
          onChanged: (source) => setState(() => _selectedSource = source),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.purple.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.05),
            Colors.blue.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecurring ? Colors.blue.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
          width: _isRecurring ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isRecurring ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.repeat,
                  color: _isRecurring ? Colors.blue : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Entrata Ricorrente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isRecurring ? Colors.blue.shade700 : Colors.grey[700],
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.1,
                child: Switch(
                  value: _isRecurring,
                  onChanged: (value) => setState(() => _isRecurring = value),
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 20),
            DropdownButtonFormField<RecurrenceType>(
              decoration: InputDecoration(
                labelText: 'Frequenza',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _recurrenceType,
              items: RecurrenceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
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
                filled: true,
                fillColor: Colors.white,
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
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data fine (opzionale)',
                  filled: true,
                  fillColor: Colors.white,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _endDate != null ? Colors.grey[800] : Colors.grey[500],
                    fontWeight: _endDate != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Annulla'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitForm,
              icon: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.check, size: 18),
              label: Text(_isLoading ? 'Salvataggio...' : 'Salva'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate.add(const Duration(days: 30)),
      firstDate: _selectedDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una fonte di reddito')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = context.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

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
        context.incomeBloc.add(CreateIncomeEvent(
          userId: userId,
          amount: amount,
          description: description,
          categoryId: _selectedCategory?.id ?? '',
          incomeDate: _selectedDate,
          source: _selectedSource!,
          isRecurring: _isRecurring,
          recurrenceSettings: recurrenceSettings,
        ));
      } else {
        context.incomeBloc.add(UpdateIncomeEvent(
          userId: userId,
          incomeId: widget.initialIncome!.id,
          amount: amount,
          description: description,
          categoryId: _selectedCategory?.id ?? '',
          incomeDate: _selectedDate,
          source: _selectedSource!,
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