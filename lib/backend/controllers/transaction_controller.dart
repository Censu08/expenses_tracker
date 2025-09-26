import 'package:flutter/foundation.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/income_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../../core/errors/app_exceptions.dart';

class TransactionController {
  final TransactionRepository _transactionRepository;
  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;

  TransactionController({
    TransactionRepository? transactionRepository,
    IncomeRepository? incomeRepository,
    ExpenseRepository? expenseRepository,
    CategoryRepository? categoryRepository,
  }) : _transactionRepository = transactionRepository ?? TransactionRepository(),
        _incomeRepository = incomeRepository ?? IncomeRepository(),
        _expenseRepository = expenseRepository ?? ExpenseRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository();

  // ==============================================================================
  // OPERAZIONI COMBINATE ENTRATE/SPESE
  // ==============================================================================

  /// Ottieni tutte le transazioni (entrate + spese) per un periodo
  Future<List<dynamic>> getAllTransactions(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
        int? limit,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final transactions = await _transactionRepository.getAllTransactions(
        userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      debugPrint('Recuperate ${transactions.length} transazioni per utente: $userId');
      return transactions;
    } catch (e) {
      debugPrint('Errore nel recupero di tutte le transazioni: $e');
      rethrow;
    }
  }

  /// Ottieni il bilancio netto per un periodo (entrate - spese)
  Future<Map<String, double>> getNetBalanceForPeriod(
      String userId, {
        required DateTime startDate,
        required DateTime endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final balance = await _transactionRepository.getNetBalanceForPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Bilancio netto periodo: €${balance['net_balance']?.toStringAsFixed(2)}');
      return balance;
    } catch (e) {
      debugPrint('Errore nel calcolo bilancio netto: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche complete per categoria
  Future<Map<String, Map<String, double>>> getCategoryStatsComplete(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final stats = await _transactionRepository.getCategoryStatsComplete(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Statistiche complete per ${stats.length} categorie');
      return stats;
    } catch (e) {
      debugPrint('Errore nel calcolo statistiche complete: $e');
      rethrow;
    }
  }

  /// Ottieni riepilogo finanziario completo del mese corrente
  Future<Map<String, dynamic>> getCurrentMonthSummary(String userId) async {
    try {
      _validateUserId(userId);

      final summary = await _transactionRepository.getCurrentMonthSummary(userId);

      debugPrint('Riepilogo finanziario mensile generato');
      return summary;
    } catch (e) {
      debugPrint('Errore nel recupero riepilogo mensile: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // DASHBOARD E ANALISI FINANZIARIE
  // ==============================================================================

  /// Ottieni dati completi per la dashboard
  Future<Map<String, dynamic>> getDashboardData(String userId, {double? monthlyBudget}) async {
    try {
      _validateUserId(userId);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      final startOfYear = DateTime(now.year, 1, 1);

      // Dati del mese corrente
      final monthlyBalance = await getNetBalanceForPeriod(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      // Dati dell'anno corrente
      final yearlyBalance = await getNetBalanceForPeriod(
        userId,
        startDate: startOfYear,
        endDate: now,
      );

      // Transazioni recenti
      final recentTransactions = await getAllTransactions(
        userId,
        startDate: startOfMonth,
        endDate: now,
        limit: 10,
      );

      // Statistiche per categoria del mese corrente
      final categoryStats = await getCategoryStatsComplete(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      // Budget status se fornito
      Map<String, double>? budgetStatus;
      if (monthlyBudget != null && monthlyBudget > 0) {
        budgetStatus = await _expenseRepository.getCurrentMonthBudgetStatus(userId, monthlyBudget);
      }

      // Trend degli ultimi 6 mesi
      final monthlyTrends = await _getMonthlyTrends(userId, 6);

      final dashboardData = {
        'user_id': userId,
        'generated_at': DateTime.now().toIso8601String(),
        'current_period': {
          'monthly_balance': monthlyBalance,
          'yearly_balance': yearlyBalance,
          'budget_status': budgetStatus,
        },
        'recent_transactions': recentTransactions.take(10).map((t) => _formatTransactionForDashboard(t)).toList(),
        'category_analysis': categoryStats,
        'trends': monthlyTrends,
        'summary_cards': {
          'total_income_month': monthlyBalance['incomes'],
          'total_expense_month': monthlyBalance['expenses'],
          'net_balance_month': monthlyBalance['net_balance'],
          'total_income_year': yearlyBalance['incomes'],
          'total_expense_year': yearlyBalance['expenses'],
          'net_balance_year': yearlyBalance['net_balance'],
          'transactions_count_month': recentTransactions.length,
          'budget_percentage': budgetStatus?['percentage'] ?? 0,
        },
      };

      debugPrint('Dati dashboard generati per utente: $userId');
      return dashboardData;
    } catch (e) {
      debugPrint('Errore nella generazione dati dashboard: $e');
      rethrow;
    }
  }

  /// Ottieni analisi dei trend mensili
  Future<List<Map<String, dynamic>>> getMonthlyTrends(String userId, {int monthsCount = 12}) async {
    try {
      _validateUserId(userId);
      _validateMonthsCount(monthsCount);

      final trends = await _getMonthlyTrends(userId, monthsCount);

      debugPrint('Trend mensili generati per ${monthsCount} mesi');
      return trends;
    } catch (e) {
      debugPrint('Errore nella generazione trend mensili: $e');
      rethrow;
    }
  }

  /// Ottieni analisi comparative per categoria
  Future<Map<String, dynamic>> getCategoryComparison(
      String userId, {
        required DateTime period1Start,
        required DateTime period1End,
        required DateTime period2Start,
        required DateTime period2End,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(period1Start, period1End);
      _validateDateRange(period2Start, period2End);

      final period1Stats = await getCategoryStatsComplete(
        userId,
        startDate: period1Start,
        endDate: period1End,
      );

      final period2Stats = await getCategoryStatsComplete(
        userId,
        startDate: period2Start,
        endDate: period2End,
      );

      final comparison = <String, Map<String, dynamic>>{};

      // Combina tutte le categorie dai due periodi
      final allCategories = <String>{...period1Stats.keys, ...period2Stats.keys};

      for (final categoryId in allCategories) {
        final period1Data = period1Stats[categoryId] ?? {'incomes': 0.0, 'expenses': 0.0, 'net': 0.0};
        final period2Data = period2Stats[categoryId] ?? {'incomes': 0.0, 'expenses': 0.0, 'net': 0.0};

        comparison[categoryId] = {
          'period1': period1Data,
          'period2': period2Data,
          'changes': {
            'incomes': (period2Data['incomes']! - period1Data['incomes']!),
            'expenses': (period2Data['expenses']! - period1Data['expenses']!),
            'net': (period2Data['net']! - period1Data['net']!),
          },
          'percentage_changes': {
            'incomes': period1Data['incomes']! > 0
                ? ((period2Data['incomes']! - period1Data['incomes']!) / period1Data['incomes']!) * 100
                : 0.0,
            'expenses': period1Data['expenses']! > 0
                ? ((period2Data['expenses']! - period1Data['expenses']!) / period1Data['expenses']!) * 100
                : 0.0,
            'net': period1Data['net']! != 0
                ? ((period2Data['net']! - period1Data['net']!) / period1Data['net']!.abs()) * 100
                : 0.0,
          },
        };
      }

      debugPrint('Analisi comparativa generata per ${allCategories.length} categorie');
      return {
        'categories': comparison,
        'period1_total': _calculatePeriodTotals(period1Stats),
        'period2_total': _calculatePeriodTotals(period2Stats),
      };
    } catch (e) {
      debugPrint('Errore nell\'analisi comparativa: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // OPERAZIONI BATCH E TRASFERIMENTI
  // ==============================================================================

  /// Trasferisci denaro (crea entrata e spesa contemporaneamente)
  Future<Map<String, dynamic>> createTransfer({
    required String userId,
    required double amount,
    required String description,
    required String fromCategoryId,
    required String toCategoryId,
    required DateTime date,
  }) async {
    try {
      _validateUserId(userId);
      _validateAmount(amount);
      _validateDescription(description);
      _validateDate(date);

      // Recupera le categorie
      final fromCategory = await _categoryRepository.getCategoryById(userId, fromCategoryId, isIncome: false);
      final toCategory = await _categoryRepository.getCategoryById(userId, toCategoryId, isIncome: true);

      if (fromCategory == null || toCategory == null) {
        throw const ValidationException('Una o entrambe le categorie non sono state trovate');
      }

      final transfer = await _transactionRepository.createTransfer(
        userId: userId,
        amount: amount,
        description: description,
        fromCategory: fromCategory,
        toCategory: toCategory,
        date: date,
      );

      debugPrint('Trasferimento creato: €${amount.toStringAsFixed(2)}');
      return transfer;
    } catch (e) {
      debugPrint('Errore nella creazione trasferimento: $e');
      rethrow;
    }
  }

  /// Elimina tutti i dati finanziari dell'utente
  Future<void> deleteAllUserFinancialData(String userId) async {
    try {
      _validateUserId(userId);

      await _transactionRepository.deleteAllUserFinancialData(userId);
      debugPrint('Tutti i dati finanziari eliminati per utente: $userId');
    } catch (e) {
      debugPrint('Errore nell\'eliminazione dati finanziari: $e');
      rethrow;
    }
  }

  /// Export completo di tutti i dati utente
  Future<Map<String, dynamic>> exportAllUserData(String userId) async {
    try {
      _validateUserId(userId);

      final exportData = await _transactionRepository.exportAllUserData(userId);
      debugPrint('Export dati completato per utente: $userId');
      return exportData;
    } catch (e) {
      debugPrint('Errore nell\'export dati utente: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STREAM COMBINATI E REAL-TIME
  // ==============================================================================

  /// Stream di tutte le transazioni del mese corrente
  Stream<List<dynamic>> getCurrentMonthTransactionsStream(String userId) {
    try {
      _validateUserId(userId);

      debugPrint('Avviato stream transazioni mese corrente per utente: $userId');
      return _transactionRepository.getCurrentMonthTransactionsStream(userId);
    } catch (e) {
      debugPrint('Errore nell\'avvio stream transazioni: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // UTILITY E STATISTICHE AVANZATE
  // ==============================================================================

  /// Ottieni previsioni basate sui dati storici
  Future<Map<String, dynamic>> getFinancialForecast(String userId, {int forecastMonths = 3}) async {
    try {
      _validateUserId(userId);
      _validateMonthsCount(forecastMonths);

      // Analizza gli ultimi 12 mesi per fare previsioni
      final historicalTrends = await _getMonthlyTrends(userId, 12);

      if (historicalTrends.length < 3) {
        throw const ValidationException('Dati insufficienti per generare previsioni (minimo 3 mesi)');
      }

      // Calcola medie e trend
      final avgIncome = historicalTrends.map((m) => m['incomes'] as double).reduce((a, b) => a + b) / historicalTrends.length;
      final avgExpense = historicalTrends.map((m) => m['expenses'] as double).reduce((a, b) => a + b) / historicalTrends.length;

      // Calcola il trend (semplificato - media degli ultimi 3 vs primi 3 mesi)
      final recentMonths = historicalTrends.take(3).toList();
      final olderMonths = historicalTrends.skip(historicalTrends.length - 3).toList();

      final recentAvgIncome = recentMonths.map((m) => m['incomes'] as double).reduce((a, b) => a + b) / 3;
      final olderAvgIncome = olderMonths.map((m) => m['incomes'] as double).reduce((a, b) => a + b) / 3;
      final incomeTrend = recentAvgIncome - olderAvgIncome;

      final recentAvgExpense = recentMonths.map((m) => m['expenses'] as double).reduce((a, b) => a + b) / 3;
      final olderAvgExpense = olderMonths.map((m) => m['expenses'] as double).reduce((a, b) => a + b) / 3;
      final expenseTrend = recentAvgExpense - olderAvgExpense;

      // Genera previsioni per i prossimi mesi
      final forecasts = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (int i = 1; i <= forecastMonths; i++) {
        final forecastMonth = DateTime(now.year, now.month + i, 1);
        final projectedIncome = (avgIncome + (incomeTrend * i)).clamp(0.0, double.infinity);
        final projectedExpense = (avgExpense + (expenseTrend * i)).clamp(0.0, double.infinity);

        forecasts.add({
          'month': forecastMonth.month,
          'year': forecastMonth.year,
          'projected_income': projectedIncome,
          'projected_expense': projectedExpense,
          'projected_net': projectedIncome - projectedExpense,
        });
      }

      final forecast = {
        'user_id': userId,
        'generated_at': DateTime.now().toIso8601String(),
        'forecast_period': forecastMonths,
        'historical_data_months': historicalTrends.length,
        'averages': {
          'monthly_income': avgIncome,
          'monthly_expense': avgExpense,
          'monthly_net': avgIncome - avgExpense,
        },
        'trends': {
          'income_trend': incomeTrend,
          'expense_trend': expenseTrend,
        },
        'forecasts': forecasts,
        'summary': {
          'total_projected_income': forecasts.map((f) => f['projected_income'] as double).reduce((a, b) => a + b),
          'total_projected_expense': forecasts.map((f) => f['projected_expense'] as double).reduce((a, b) => a + b),
          'total_projected_net': forecasts.map((f) => f['projected_net'] as double).reduce((a, b) => a + b),
        },
      };

      debugPrint('Previsioni finanziarie generate per ${forecastMonths} mesi');
      return forecast;
    } catch (e) {
      debugPrint('Errore nella generazione previsioni: $e');
      rethrow;
    }
  }

  /// Ottieni alert e notifiche finanziarie
  Future<List<Map<String, dynamic>>> getFinancialAlerts(String userId, {double? monthlyBudget}) async {
    try {
      _validateUserId(userId);

      final alerts = <Map<String, dynamic>>[];
      final now = DateTime.now();

      // Alert budget superato
      if (monthlyBudget != null && monthlyBudget > 0) {
        final budgetStatus = await _expenseRepository.getCurrentMonthBudgetStatus(userId, monthlyBudget);
        final percentage = budgetStatus['percentage'] ?? 0.0;

        if (percentage > 100) {
          alerts.add({
            'type': 'budget_exceeded',
            'severity': 'high',
            'message': 'Budget mensile superato del ${(percentage - 100).toStringAsFixed(1)}%',
            'value': percentage,
          });
        } else if (percentage > 80) {
          alerts.add({
            'type': 'budget_warning',
            'severity': 'medium',
            'message': 'Budget mensile utilizzato al ${percentage.toStringAsFixed(1)}%',
            'value': percentage,
          });
        }
      }

      // Alert spese ricorrenti in scadenza
      final recurringExpenses = await _expenseRepository.getActiveRecurringExpenses(userId);
      for (final expense in recurringExpenses) {
        if (expense.nextOccurrence != null) {
          final daysUntilNext = expense.nextOccurrence!.difference(now).inDays;
          if (daysUntilNext <= 3 && daysUntilNext >= 0) {
            alerts.add({
              'type': 'recurring_expense_due',
              'severity': 'low',
              'message': 'Spesa ricorrente "${expense.description}" in scadenza tra $daysUntilNext giorni',
              'value': expense.amount,
              'expense_id': expense.id,
            });
          }
        }
      }

      // Alert transazioni anomale (spese molto superiori alla media)
      final monthlyExpenses = await _expenseRepository.getCurrentMonthExpenses(userId);
      if (monthlyExpenses.isNotEmpty) {
        final avgAmount = monthlyExpenses.map((e) => e.amount).reduce((a, b) => a + b) / monthlyExpenses.length;
        final unusualExpenses = monthlyExpenses.where((e) => e.amount > avgAmount * 3).toList();

        for (final expense in unusualExpenses.take(3)) {
          alerts.add({
            'type': 'unusual_expense',
            'severity': 'medium',
            'message': 'Spesa insolita: "${expense.description}" di ${expense.formattedAmount}',
            'value': expense.amount,
            'expense_id': expense.id,
          });
        }
      }

      alerts.sort((a, b) {
        final severityOrder = {'high': 0, 'medium': 1, 'low': 2};
        return severityOrder[a['severity']]!.compareTo(severityOrder[b['severity']]!);
      });

      debugPrint('Generati ${alerts.length} alert finanziari');
      return alerts;
    } catch (e) {
      debugPrint('Errore nella generazione alert: $e');
      return [];
    }
  }

  // ==============================================================================
  // METODI HELPER PRIVATI
  // ==============================================================================

  Future<List<Map<String, dynamic>>> _getMonthlyTrends(String userId, int monthsCount) async {
    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < monthsCount; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final balance = await getNetBalanceForPeriod(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      trends.add({
        'month': month.month,
        'year': month.year,
        'date': startOfMonth,
        'incomes': balance['incomes'],
        'expenses': balance['expenses'],
        'net_balance': balance['net_balance'],
      });
    }

    return trends.reversed.toList(); // Ordine cronologico
  }

  Map<String, dynamic> _formatTransactionForDashboard(dynamic transaction) {
    if (transaction is IncomeModel) {
      return {
        'id': transaction.id,
        'type': 'income',
        'amount': transaction.amount,
        'description': transaction.description,
        'category': transaction.category.description,
        'date': transaction.incomeDate,
        'is_recurring': transaction.isRecurring,
      };
    } else if (transaction is ExpenseModel) {
      return {
        'id': transaction.id,
        'type': 'expense',
        'amount': transaction.amount,
        'description': transaction.description,
        'category': transaction.category.description,
        'date': transaction.expenseDate,
        'is_recurring': transaction.isRecurring,
        'is_high_priority': transaction.isHighPriority,
      };
    }
    return {};
  }

  Map<String, double> _calculatePeriodTotals(Map<String, Map<String, double>> stats) {
    double totalIncomes = 0;
    double totalExpenses = 0;

    for (final categoryStats in stats.values) {
      totalIncomes += categoryStats['incomes'] ?? 0.0;
      totalExpenses += categoryStats['expenses'] ?? 0.0;
    }

    return {
      'incomes': totalIncomes,
      'expenses': totalExpenses,
      'net': totalIncomes - totalExpenses,
    };
  }

  // ==============================================================================
  // VALIDAZIONI PRIVATE
  // ==============================================================================

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw const ValidationException('User ID richiesto');
    }
  }

  void _validateAmount(double amount) {
    if (amount <= 0) {
      throw const ValidationException('Importo deve essere maggiore di zero');
    }
    if (amount > 999999999.99) {
      throw const ValidationException('Importo troppo elevato');
    }
  }

  void _validateDescription(String description) {
    if (description.trim().isEmpty) {
      throw const ValidationException('Descrizione richiesta');
    }
    if (description.length > 200) {
      throw const ValidationException('Descrizione troppo lunga (max 200 caratteri)');
    }
  }

  void _validateDate(DateTime date) {
    final now = DateTime.now();
    final tenYearsAgo = now.subtract(const Duration(days: 365 * 10));
    final tenYearsFromNow = now.add(const Duration(days: 365 * 10));

    if (date.isBefore(tenYearsAgo) || date.isAfter(tenYearsFromNow)) {
      throw const ValidationException('Data non valida (range: 10 anni nel passato/futuro)');
    }
  }

  void _validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw const ValidationException('Data inizio deve essere precedente alla data fine');
      }

      final daysDifference = endDate.difference(startDate).inDays;
      if (daysDifference > 365 * 2) {
        throw const ValidationException('Range di date troppo ampio (max 2 anni)');
      }
    }
  }

  void _validateMonthsCount(int monthsCount) {
    if (monthsCount <= 0 || monthsCount > 60) {
      throw const ValidationException('Numero di mesi non valido (1-60)');
    }
  }
}