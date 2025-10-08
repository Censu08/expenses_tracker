import 'package:expenses_tracker/backend/models/income/income_source_enum.dart';
import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income/income_model.dart';
import '../../../../backend/models/recurrence_model.dart';
import '../../../themes/app_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      elevation: AppElevations.dialog,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
          color: isDark ? AppColors.surfaceDark : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xLarge,
                  AppSpacing.large,
                  AppSpacing.xLarge,
                  AppSpacing.xLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountSection(context),
                    const SizedBox(height: AppSpacing.xLarge),
                    _buildDetailsSection(context),
                    if (income.isRecurring) ...[
                      const SizedBox(height: AppSpacing.xLarge),
                      _buildRecurrenceSection(context),
                    ],
                    const SizedBox(height: AppSpacing.xLarge),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            income.source.color.withOpacity(0.15),
            income.source.color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.xLarge),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: IncomeTheme.getIconContainerDecoration(income.source.color),
            child: Icon(
              income.source.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  income.description,
                  style: IncomeTheme.getCardTitleStyle(context).copyWith(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
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
              backgroundColor: (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            successColor.withOpacity(0.08),
            successColor.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        border: Border.all(
          color: successColor.withOpacity(0.3),
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
                    color: successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  income.amount.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: successColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppBorderRadius.circle),
                border: Border.all(
                  color: successColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 18,
                    color: successColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Entrata',
                    style: TextStyle(
                      color: successColor,
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
            const SizedBox(width: AppSpacing.small),
            Text(
              'Dettagli',
              style: IncomeTheme.getCardTitleStyle(context).copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        _buildDetailRow(
          context,
          'Data',
          '${income.incomeDate.day.toString().padLeft(2, '0')}/${income.incomeDate.month.toString().padLeft(2, '0')}/${income.incomeDate.year}',
          Icons.calendar_today,
        ),
        const SizedBox(height: AppSpacing.medium),
        _buildSourceDetailRow(context),
        const SizedBox(height: AppSpacing.medium),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final settings = income.recurrenceSettings!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryColor.withOpacity(0.08),
            secondaryColor.withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: secondaryColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.small),
                ),
                child: Icon(
                  Icons.repeat,
                  size: 18,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Ricorrenza',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          _buildDetailRow(
            context,
            'Tipo',
            _getRecurrenceTypeLabel(settings.type),
            _getRecurrenceIcon(settings.type),
            iconColor: secondaryColor,
          ),
          const SizedBox(height: AppSpacing.small),
          _buildDetailRow(
            context,
            'Necessità',
            _getNecessityLabel(settings.necessityLevel),
            _getNecessityIcon(settings.necessityLevel),
            iconColor: _getNecessityColor(settings.necessityLevel, context),
          ),
          if (settings.endDate != null) ...[
            const SizedBox(height: AppSpacing.small),
            _buildDetailRow(
              context,
              'Data Fine',
              '${settings.endDate!.day}/${settings.endDate!.month}/${settings.endDate!.year}',
              Icons.event_available,
              iconColor: secondaryColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.2),
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
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.small),
              Text(
                'Informazioni sistema',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: IncomeTheme.getLabelTextStyle(context),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceDetailRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: IncomeTheme.getIconContainerDecoration(income.source.color),
          child: Icon(
            income.source.icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fonte di Reddito',
                style: IncomeTheme.getLabelTextStyle(context),
              ),
              const SizedBox(height: 2),
              Text(
                income.source.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              Text(
                income.source.description,
                style: IncomeTheme.getLabelTextStyle(context).copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xLarge),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.05),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppBorderRadius.xLarge),
        ),
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.15),
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _duplicateIncome(context),
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Duplica'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
                elevation: AppElevations.button,
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

  Color _getNecessityColor(NecessityLevel level, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (level) {
      case NecessityLevel.low:
        return isDark ? AppColors.successDark : AppColors.success;
      case NecessityLevel.medium:
        return isDark ? AppColors.warningDark : AppColors.warning;
      case NecessityLevel.high:
        return isDark ? AppColors.errorDark : AppColors.error;
      case NecessityLevel.critical:
        return isDark ? AppColors.errorDark : AppColors.error;
    }
  }
}