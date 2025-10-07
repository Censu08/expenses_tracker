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
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            income.source.color.withOpacity(0.15),
            income.source.color.withOpacity(0.08),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  income.source.color,
                  income.source.color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: income.source.color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              income.source.icon,
              color: Colors.white,
              size: 28,
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
                    letterSpacing: -0.5,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  income.source.displayName,
                  style: TextStyle(
                    fontSize: 13,
                    color: income.source.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

  Widget _buildAmountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.08),
            Colors.green.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '€',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  income.amount.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Entrata',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Dettagli',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          'Data',
          '${income.incomeDate.day.toString().padLeft(2, '0')}/${income.incomeDate.month.toString().padLeft(2, '0')}/${income.incomeDate.year}',
          Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        _buildSourceDetailRow(context),
        const SizedBox(height: 12),
        _buildDetailRow(
          context,
          'ID Transazione',
          income.id.substring(0, 8) + '...',
          Icons.fingerprint,
        ),
      ],
    );
  }

  Widget _buildRecurrenceSection(BuildContext context) {
    final settings = income.recurrenceSettings!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.08),
            Colors.blue.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1.5,
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
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.repeat,
                  size: 18,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Ricorrenza',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            'Tipo',
            _getRecurrenceTypeLabel(settings.type),
            _getRecurrenceIcon(settings.type),
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Necessità',
            _getNecessityLabel(settings.necessityLevel),
            _getNecessityIcon(settings.necessityLevel),
            iconColor: _getNecessityColor(settings.necessityLevel),
          ),
          if (settings.endDate != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'Data Fine',
              '${settings.endDate!.day}/${settings.endDate!.month}/${settings.endDate!.year}',
              Icons.event_available,
              iconColor: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Informazioni sistema',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            'Creato il',
            '${income.createdAt.day}/${income.createdAt.month}/${income.createdAt.year} alle ${income.createdAt.hour}:${income.createdAt.minute.toString().padLeft(2, '0')}',
            Icons.add_circle_outline,
          ),
        ],
      ),
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
          color: iconColor ?? Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
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
            gradient: LinearGradient(
              colors: [
                income.source.color,
                income.source.color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: income.source.color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            income.source.icon,
            size: 20,
            color: Colors.white,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                income.source.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
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
              onPressed: () => _editIncome(context),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Modifica'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _duplicateIncome(context),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Duplica'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editIncome(BuildContext context) {
    Navigator.of(context).pop();

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

    Navigator.of(context).pop();

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

  IconData _getRecurrenceIcon(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return Icons.today;
      case RecurrenceType.weekly:
        return Icons.view_week;
      case RecurrenceType.monthly:
        return Icons.calendar_month;
      case RecurrenceType.yearly:
        return Icons.calendar_today;
      case RecurrenceType.custom:
        return Icons.tune;
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