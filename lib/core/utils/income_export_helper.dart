import 'dart:convert';
import '../../backend/models/income/income_model.dart';
import '../../backend/models/income/income_source_enum.dart';

class IncomeExportHelper {
  static String exportToCSV({
    required List<IncomeModel> incomes,
    bool groupBySource = false,
  }) {
    final buffer = StringBuffer();

    if (groupBySource) {
      buffer.writeln('Fonte,Data,Descrizione,Importo,Ricorrente');

      final grouped = _groupBySource(incomes);
      for (var source in IncomeSource.values) {
        final sourceIncomes = grouped[source] ?? [];
        if (sourceIncomes.isEmpty) continue;

        for (var income in sourceIncomes) {
          buffer.writeln(_formatIncomeCSV(income, includeSource: true));
        }
        buffer.writeln('');
      }
    } else {
      buffer.writeln('Fonte,Data,Descrizione,Importo,Ricorrente,ID');
      for (var income in incomes) {
        buffer.writeln(_formatIncomeCSV(income, includeSource: true, includeId: true));
      }
    }

    return buffer.toString();
  }

  static String exportToJSON({
    required List<IncomeModel> incomes,
    bool groupBySource = false,
  }) {
    if (groupBySource) {
      final grouped = _groupBySource(incomes);
      final data = grouped.map((source, incomes) {
        return MapEntry(
          source.name,
          {
            'displayName': source.displayName,
            'total': incomes.fold(0.0, (sum, i) => sum + i.amount),
            'count': incomes.length,
            'incomes': incomes.map((i) => _formatIncomeJSON(i)).toList(),
          },
        );
      });
      return JsonEncoder.withIndent('  ').convert(data);
    } else {
      final data = incomes.map((i) => _formatIncomeJSON(i)).toList();
      return JsonEncoder.withIndent('  ').convert(data);
    }
  }

  static String generateSourceReport({
    required Map<IncomeSource, double> sourceStats,
    required int diversificationScore,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final buffer = StringBuffer();
    final totalAmount = sourceStats.values.fold(0.0, (sum, amount) => sum + amount);

    buffer.writeln('REPORT ANALISI FONTI DI REDDITO');
    buffer.writeln('================================');
    buffer.writeln('');

    if (startDate != null && endDate != null) {
      buffer.writeln('Periodo: ${_formatDate(startDate)} - ${_formatDate(endDate)}');
    } else {
      buffer.writeln('Periodo: Tutti i dati disponibili');
    }
    buffer.writeln('');

    buffer.writeln('RIEPILOGO');
    buffer.writeln('---------');
    buffer.writeln('Score di Diversificazione: $diversificationScore/100');
    buffer.writeln('Fonti Attive: ${sourceStats.length}');
    buffer.writeln('Totale Entrate: €${totalAmount.toStringAsFixed(2)}');
    buffer.writeln('');

    buffer.writeln('DISTRIBUZIONE PER FONTE');
    buffer.writeln('----------------------');

    final sortedSources = sourceStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedSources) {
      final percentage = (entry.value / totalAmount) * 100;
      buffer.writeln('${entry.key.displayName}:');
      buffer.writeln('  Importo: €${entry.value.toStringAsFixed(2)}');
      buffer.writeln('  Percentuale: ${percentage.toStringAsFixed(1)}%');
      buffer.writeln('');
    }

    buffer.writeln('ANALISI');
    buffer.writeln('-------');
    final primarySource = sortedSources.first;
    final primaryPercentage = (primarySource.value / totalAmount) * 100;

    if (primaryPercentage > 70) {
      buffer.writeln('⚠️ ATTENZIONE: Dipendi al ${primaryPercentage.toStringAsFixed(0)}% da ${primarySource.key.displayName}');
      buffer.writeln('   Raccomandazione: Diversifica urgentemente le tue fonti.');
    } else if (primaryPercentage > 50) {
      buffer.writeln('ℹ️ INFO: La fonte principale (${primarySource.key.displayName}) rappresenta ${primaryPercentage.toStringAsFixed(0)}%');
      buffer.writeln('   Raccomandazione: Considera di bilanciare meglio le fonti.');
    } else {
      buffer.writeln('✓ OTTIMO: Nessuna fonte supera il 50% del reddito totale.');
      buffer.writeln('  Hai una buona diversificazione.');
    }
    buffer.writeln('');

    if (sourceStats.length <= 2) {
      buffer.writeln('⚠️ Hai solo ${sourceStats.length} ${sourceStats.length == 1 ? 'fonte' : 'fonti'}.');
      buffer.writeln('   Obiettivo: Sviluppare almeno 3-4 fonti diverse.');
    }

    return buffer.toString();
  }

  static Map<IncomeSource, List<IncomeModel>> _groupBySource(List<IncomeModel> incomes) {
    final grouped = <IncomeSource, List<IncomeModel>>{};
    for (var income in incomes) {
      grouped.putIfAbsent(income.source, () => []).add(income);
    }
    return grouped;
  }

  static String _formatIncomeCSV(IncomeModel income, {bool includeSource = false, bool includeId = false}) {
    final parts = [
      if (includeSource) income.source.displayName,
      _formatDate(income.incomeDate),
      '"${income.description.replaceAll('"', '""')}"',
      income.amount.toStringAsFixed(2),
      income.isRecurring ? 'Sì' : 'No',
      if (includeId) income.id,
    ];
    return parts.join(',');
  }

  static Map<String, dynamic> _formatIncomeJSON(IncomeModel income) {
    return {
      'id': income.id,
      'source': income.source.name,
      'sourceDisplayName': income.source.displayName,
      'date': income.incomeDate.toIso8601String(),
      'description': income.description,
      'amount': income.amount,
      'isRecurring': income.isRecurring,
      if (income.isRecurring && income.recurrenceSettings != null)
        'recurrence': {
          'type': income.recurrenceSettings!.type.name,
          'interval': income.recurrenceSettings!.customIntervalDays,
          if (income.recurrenceSettings!.endDate != null)
            'endDate': income.recurrenceSettings!.endDate!.toIso8601String(),
        },
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}