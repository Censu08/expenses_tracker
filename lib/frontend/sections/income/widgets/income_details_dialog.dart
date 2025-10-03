import 'package:expenses_tracker/backend/models/income/income_source_enum.dart';
import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/recurrence_model.dart';
import 'add_income_form.dart';

class IncomeDetailsDialog extends StatelessWidget {
  final IncomeModel income;
  final VoidCallback? onUpdated;

  const IncomeDetailsDialog({
    super.key,
    required this.income,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountSection(context),
                    const SizedBox(height: 24),
                    _buildDetailsSection(context),
                    if (income.isRecurring) ...[
                      const SizedBox(height: 24),
                      _buildRecurrenceSection(context),
                    ],
                    const SizedBox(height: 24),
                    _buildTimestampSection(context),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: income.source.color.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: income.source.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              income.source.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.description,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

  Widget _buildAmountSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '€ ${income.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Entrata',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dettagli',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          'Data',
          '${income.incomeDate.day}/${income.incomeDate.month}/${income.incomeDate.year}',
          Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        _buildSourceDetailRow(context),
        const SizedBox(height: 12),
        _buildDetailRow(
          context,
          'ID Transazione',
          income.id,
          Icons.fingerprint,
        ),
      ],
    );
  }

  Widget _buildRecurrenceSection(BuildContext context) {
    final settings = income.recurrenceSettings!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.repeat,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
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
        _buildDetailRow(
          context,
          'Frequenza',
          _getRecurrenceTypeLabel(settings.type),
          Icons.schedule,
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          context,
          'Livello di necessità',
          _getNecessityLabel(settings.necessityLevel),
          _getNecessityIcon(settings.necessityLevel),
          iconColor: _getNecessityColor(settings.necessityLevel),
        ),
        if (settings.endDate != null) ...[
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            'Data fine',
            '${settings.endDate!.day}/${settings.endDate!.month}/${settings.endDate!.year}',
            Icons.event,
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Questa entrata si ripete automaticamente secondo la frequenza impostata.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informazioni sistema',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          'Creato il',
          '${income.createdAt.day}/${income.createdAt.month}/${income.createdAt.year} alle ${income.createdAt.hour}:${income.createdAt.minute.toString().padLeft(2, '0')}',
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      String label,
      String value,
      IconData icon, {
        Color? iconColor,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceDetailRow(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: income.source.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            income.source.icon,
            size: 20,
            color: income.source.color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fonte di Reddito',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                income.source.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                income.source.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editIncome(context),
              icon: const Icon(Icons.edit),
              label: const Text('Modifica'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _duplicateIncome(context),
              icon: const Icon(Icons.copy),
              label: const Text('Duplica'),
            ),
          ),
        ],
      ),
    );
  }

  void _editIncome(BuildContext context) {
    Navigator.of(context).pop(); // Chiudi dialog corrente

    showDialog(
      context: context,
      builder: (context) => AddIncomeForm(
        initialIncome: income,
        onIncomeAdded: () {
          Navigator.pop(context);
          onUpdated?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrata modificata con successo!')),
          );
        },
      ),
    );
  }

  void _duplicateIncome(BuildContext context) {
    final userId = context.currentUserId;
    if (userId == null) return;

    Navigator.of(context).pop(); // Chiudi dialog

    context.incomeBloc.add(DuplicateIncomeEvent(
      userId: userId,
      incomeId: income.id,
      newDate: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrata duplicata con successo!')),
    );

    onUpdated?.call();
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
}