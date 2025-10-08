import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/controllers/income_controller.dart';
import '../../../../backend/models/income/income_source_enum.dart';
import '../../../themes/app_theme.dart';

enum ExportFormat { csv, json, report }

class IncomeExportDialog extends StatefulWidget {
  const IncomeExportDialog({Key? key}) : super(key: key);

  @override
  State<IncomeExportDialog> createState() => _IncomeExportDialogState();
}

class _IncomeExportDialogState extends State<IncomeExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _groupBySource = true;
  IncomeSource? _filterSource;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;
  String? _exportedData;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
      ),
      elevation: AppElevations.dialog,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 720),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppBorderRadius.xLarge),
          color: isDark ? AppColors.surfaceDark : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormatSection(),
                    const SizedBox(height: AppSpacing.xLarge),
                    _buildOptionsSection(),
                    const SizedBox(height: AppSpacing.xLarge),
                    _buildDateRangeSection(),
                    const SizedBox(height: AppSpacing.xLarge),
                    _buildSourceFilterSection(),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            secondaryColor.withOpacity(0.15),
            secondaryColor.withOpacity(0.08),
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
            decoration: IncomeTheme.getIconContainerDecoration(secondaryColor),
            child: const Icon(
              Icons.file_download,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Esporta Dati Entrate',
                  style: IncomeTheme.getCardTitleStyle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Configura le opzioni di export',
                  style: IncomeTheme.getLabelTextStyle(context),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.file_present,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.small),
            Text(
              'Formato Export',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Wrap(
          spacing: AppSpacing.medium,
          runSpacing: AppSpacing.medium,
          children: [
            _buildFormatChip(
              format: ExportFormat.csv,
              icon: Icons.table_chart,
              label: 'CSV',
              description: 'Excel, Fogli',
              color: isDark ? AppColors.successDark : AppColors.success,
            ),
            _buildFormatChip(
              format: ExportFormat.json,
              icon: Icons.code,
              label: 'JSON',
              description: 'Dati strutturati',
              color: isDark ? AppColors.warningDark : AppColors.warning,
            ),
            _buildFormatChip(
              format: ExportFormat.report,
              icon: Icons.article,
              label: 'Report',
              description: 'Analisi testuale',
              color: isDark ? AppColors.accentDark : AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatChip({
    required ExportFormat format,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.medium,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.08),
            ],
          )
              : null,
          color: isSelected
              ? null
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.small),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.small),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? color
                        : isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: IncomeTheme.getLabelTextStyle(context).copyWith(fontSize: 11),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.small),
              Icon(Icons.check_circle, color: color, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    if (_selectedFormat == ExportFormat.report) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.secondaryDark : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        border: Border.all(
          color: secondaryColor.withOpacity(0.2),
        ),
      ),
      child: CheckboxListTile(
        title: const Text(
          'Raggruppa per Fonte',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Organizza i dati separando ogni fonte',
          style: TextStyle(fontSize: 12),
        ),
        value: _groupBySource,
        onChanged: (value) => setState(() => _groupBySource = value ?? true),
        contentPadding: EdgeInsets.zero,
        activeColor: secondaryColor,
      ),
    );
  }

  Widget _buildDateRangeSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.date_range,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.small),
            Text(
              'Intervallo Date (Opzionale)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        Row(
          children: [
            Expanded(
              child: _buildDateButton(
                label: 'Data Inizio',
                date: _startDate,
                onTap: () => _selectDate(true),
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: _buildDateButton(
                label: 'Data Fine',
                date: _endDate,
                onTap: () => _selectDate(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.medium),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          border: Border.all(
            color: date != null
                ? accentColor.withOpacity(0.3)
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: IncomeTheme.getLabelTextStyle(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: date != null
                      ? accentColor
                      : isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  date != null ? _formatDate(date) : 'Non selezionato',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                    color: date != null
                        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceFilterSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.filter_list,
              size: 20,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.small),
            Text(
              'Filtra per Fonte (Opzionale)',
              style: TextStyle(
                fontSize: 16,
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
              color: _filterSource != null
                  ? _filterSource!.color.withOpacity(0.3)
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<IncomeSource?>(
            value: _filterSource,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.large,
                vertical: AppSpacing.medium,
              ),
            ),
            hint: const Text('Tutte le fonti'),
            items: [
              const DropdownMenuItem<IncomeSource?>(
                value: null,
                child: Text('Tutte le fonti'),
              ),
              ...IncomeSource.values.map((source) {
                return DropdownMenuItem<IncomeSource?>(
                  value: source,
                  child: Row(
                    children: [
                      Icon(source.icon, size: 18, color: source.color),
                      const SizedBox(width: AppSpacing.small),
                      Text(
                        source.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) => setState(() => _filterSource = value),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryColor = isDark ? AppColors.secondaryDark : AppColors.secondary;
    final successColor = isDark ? AppColors.successDark : AppColors.success;

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
      child: Column(
        children: [
          if (_exportedData != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.medium),
              margin: const EdgeInsets.only(bottom: AppSpacing.large),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.small),
                border: Border.all(
                  color: successColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: successColor, size: 20),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Text(
                      'Export completato! Copia negli appunti.',
                      style: TextStyle(
                        color: successColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copia'),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Annulla'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.large),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isExporting ? null : _handleExport,
                  icon: _isExporting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.download, size: 18),
                  label: Text(_isExporting ? 'Esportando...' : 'Esporta'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
                    backgroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                    ),
                    elevation: AppElevations.button,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);

    try {
      final userId = context.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final controller = IncomeController(
        incomeRepository: context.read(),
      );

      String exportData;

      switch (_selectedFormat) {
        case ExportFormat.csv:
          exportData = await controller.exportIncomesToCSV(
            userId: userId,
            groupBySource: _groupBySource,
            startDate: _startDate,
            endDate: _endDate,
            filterSource: _filterSource,
          );
          break;
        case ExportFormat.json:
          exportData = await controller.exportIncomesToJSON(
            userId: userId,
            groupBySource: _groupBySource,
            startDate: _startDate,
            endDate: _endDate,
            filterSource: _filterSource,
          );
          break;
        case ExportFormat.report:
          exportData = await controller.generateSourceAnalyticsReport(
            userId: userId,
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
      }

      setState(() {
        _exportedData = exportData;
        _isExporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export completato! Puoi copiare il contenuto.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
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

  void _copyToClipboard() {
    if (_exportedData != null) {
      Clipboard.setData(ClipboardData(text: _exportedData!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copiato negli appunti!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}