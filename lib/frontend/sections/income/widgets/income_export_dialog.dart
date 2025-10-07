import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/controllers/income_controller.dart';
import '../../../../backend/models/income/income_source_enum.dart';

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
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormatSection(),
                    const SizedBox(height: 24),
                    _buildOptionsSection(),
                    const SizedBox(height: 24),
                    _buildDateRangeSection(),
                    const SizedBox(height: 24),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.file_download,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Esporta Dati Entrate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configura le opzioni di export',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Formato Export',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFormatChip(
              format: ExportFormat.csv,
              icon: Icons.table_chart,
              label: 'CSV',
              description: 'Excel, Fogli',
            ),
            _buildFormatChip(
              format: ExportFormat.json,
              icon: Icons.code,
              label: 'JSON',
              description: 'Dati strutturati',
            ),
            _buildFormatChip(
              format: ExportFormat.report,
              icon: Icons.article,
              label: 'Report',
              description: 'Analisi testuale',
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
  }) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    if (_selectedFormat == ExportFormat.report) {
      return const SizedBox.shrink();
    }

    return CheckboxListTile(
      title: const Text('Raggruppa per Fonte'),
      subtitle: const Text('Organizza i dati separando ogni fonte'),
      value: _groupBySource,
      onChanged: (value) => setState(() => _groupBySource = value ?? true),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periodo (Opzionale)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Da',
                date: _startDate,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'A',
                date: _endDate,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
        if (_startDate != null || _endDate != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() {
              _startDate = null;
              _endDate = null;
            }),
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Cancella date'),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    date != null ? _formatDate(date) : 'Non selezionato',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildSourceFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filtra per Fonte (Opzionale)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<IncomeSource?>(
          value: _filterSource,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    Icon(source.icon, size: 16, color: source.color),
                    const SizedBox(width: 8),
                    Text(source.displayName),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) => setState(() => _filterSource = value),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_exportedData != null) ...[
            Expanded(
              child: Text(
                'Export completato! Copia negli appunti.',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copia'),
            ),
            const SizedBox(width: 8),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _handleExport,
            icon: _isExporting
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Esportando...' : 'Esporta'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
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
    return '${date.day}/${date.month}/${date.year}';
  }
}