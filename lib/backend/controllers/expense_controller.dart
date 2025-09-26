import 'package:flutter/foundation.dart';
import '../repositories/expense_repository.dart';
import '../repositories/category_repository.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/recurrence_model.dart';
import '../../core/errors/app_exceptions.dart';

class ExpenseController {
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;

  ExpenseController({
    ExpenseRepository? expenseRepository,
    CategoryRepository? categoryRepository,
  }) : _expenseRepository = expenseRepository ?? ExpenseRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository();

  // ==============================================================================
  // OPERAZIONI CRUD BASE
  // ==============================================================================

  /// Crea una nuova spesa
  Future<ExpenseModel> createExpense({
    required String userId,
    required double amount,
    required String description,
    required String categoryId,
    required DateTime expenseDate,
    bool isRecurring = false,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      // Validazioni
      _validateUserId(userId);
      _validateAmount(amount);
      _validateDescription(description);
      _validateDate(expenseDate);
      _validateRecurrenceData(isRecurring, recurrenceSettings);

      // Recupera la categoria
      final category = await _getCategoryForUser(userId, categoryId, isIncome: false);
      if (category == null) {
        throw const ValidationException('Categoria non trovata');
      }

      final expense = await _expenseRepository.createExpense(
        userId: userId,
        amount: amount,
        description: description.trim(),
        category: category,
        expenseDate: expenseDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Spesa creata con successo: ${expense.id}');
      return expense;
    } catch (e) {
      debugPrint('Errore nella creazione spesa: $e');
      rethrow;
    }
  }

  /// Ottieni una spesa per ID
  Future<ExpenseModel?> getExpenseById(String userId, String expenseId) async {
    try {
      _validateUserId(userId);
      _validateExpenseId(expenseId);

      final expense = await _expenseRepository.getExpenseById(userId, expenseId);
      if (expense != null) {
        debugPrint('Spesa trovata: ${expense.description}');
      } else {
        debugPrint('Spesa non trovata: $expenseId');
      }
      return expense;
    } catch (e) {
      debugPrint('Errore nel recupero spesa: $e');
      rethrow;
    }
  }

  /// Ottieni tutte le spese dell'utente con filtri
  Future<List<ExpenseModel>> getUserExpenses(
      String userId, {
        int? limit,
        DateTime? startDate,
        DateTime? endDate,
        String? categoryId,
        bool? isRecurring,
        NecessityLevel? minNecessityLevel,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final expenses = await _expenseRepository.getUserExpenses(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        isRecurring: isRecurring,
        minNecessityLevel: minNecessityLevel,
      );

      debugPrint('Recuperate ${expenses.length} spese per utente: $userId');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero spese utente: $e');
      rethrow;
    }
  }

  /// Aggiorna una spesa esistente
  Future<ExpenseModel> updateExpense({
    required String userId,
    required String expenseId,
    double? amount,
    String? description,
    String? categoryId,
    DateTime? expenseDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      _validateUserId(userId);
      _validateExpenseId(expenseId);

      if (amount != null) _validateAmount(amount);
      if (description != null) _validateDescription(description);
      if (expenseDate != null) _validateDate(expenseDate);
      if (isRecurring != null) _validateRecurrenceData(isRecurring, recurrenceSettings);

      // Recupera la categoria se specificata
      CategoryModel? category;
      if (categoryId != null) {
        category = await _getCategoryForUser(userId, categoryId, isIncome: false);
        if (category == null) {
          throw const ValidationException('Categoria non trovata');
        }
      }

      final updatedExpense = await _expenseRepository.updateExpense(
        userId: userId,
        expenseId: expenseId,
        amount: amount,
        description: description?.trim(),
        category: category,
        expenseDate: expenseDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Spesa aggiornata: $expenseId');
      return updatedExpense;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento spesa: $e');
      rethrow;
    }
  }

  /// Elimina una spesa
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      _validateUserId(userId);
      _validateExpenseId(expenseId);

      await _expenseRepository.deleteExpense(userId, expenseId);
      debugPrint('Spesa eliminata: $expenseId');
    } catch (e) {
      debugPrint('Errore nell\'eliminazione spesa: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // QUERY SPECIALIZZATE
  // ==============================================================================

  /// Ottieni spese del mese corrente
  Future<List<ExpenseModel>> getCurrentMonthExpenses(String userId) async {
    try {
      _validateUserId(userId);

      final expenses = await _expenseRepository.getCurrentMonthExpenses(userId);
      debugPrint('Recuperate ${expenses.length} spese del mese corrente');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero spese mese corrente: $e');
      rethrow;
    }
  }

  /// Ottieni spese della settimana corrente
  Future<List<ExpenseModel>> getCurrentWeekExpenses(String userId) async {
    try {
      _validateUserId(userId);

      final expenses = await _expenseRepository.getCurrentWeekExpenses(userId);
      debugPrint('Recuperate ${expenses.length} spese della settimana corrente');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero spese settimana corrente: $e');
      rethrow;
    }
  }

  /// Ottieni spese ricorrenti attive
  Future<List<ExpenseModel>> getActiveRecurringExpenses(String userId) async {
    try {
      _validateUserId(userId);

      final expenses = await _expenseRepository.getActiveRecurringExpenses(userId);
      debugPrint('Recuperate ${expenses.length} spese ricorrenti attive');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero spese ricorrenti: $e');
      rethrow;
    }
  }

  /// Ottieni spese per categoria
  Future<List<ExpenseModel>> getExpensesByCategory(
      String userId,
      String categoryId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final expenses = await _expenseRepository.getExpensesByCategory(
        userId,
        categoryId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Recuperate ${expenses.length} spese per categoria: $categoryId');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero spese per categoria: $e');
      rethrow;
    }
  }

  /// Ottieni spese ad alta priorità
  Future<List<ExpenseModel>> getHighPriorityExpenses(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final expenses = await _expenseRepository.getHighPriorityExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Recuperate ${expenses.length} spese ad alta priorità');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero spese alta priorità: $e');
      rethrow;
    }
  }

  /// Ottieni le spese più costose
  Future<List<ExpenseModel>> getTopExpensesByAmount(
      String userId, {
        required int limit,
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateLimit(limit);
      _validateDateRange(startDate, endDate);

      final expenses = await _expenseRepository.getTopExpensesByAmount(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Recuperate ${expenses.length} spese più costose');
      return expenses;
    } catch (e) {
      debugPrint('Errore nel recupero top spese: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STATISTICHE E ANALYTICS
  // ==============================================================================

  /// Calcola il totale delle spese per un periodo
  Future<double> getTotalExpenseForPeriod(
      String userId, {
        required DateTime startDate,
        required DateTime endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final total = await _expenseRepository.getTotalExpenseForPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Totale spese periodo: €${total.toStringAsFixed(2)}');
      return total;
    } catch (e) {
      debugPrint('Errore nel calcolo totale spese: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche spese per categoria
  Future<Map<String, double>> getExpenseStatsByCategory(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final stats = await _expenseRepository.getExpenseStatsByCategory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Statistiche spese per categoria: ${stats.length} categorie');
      return stats;
    } catch (e) {
      debugPrint('Errore nel calcolo statistiche per categoria: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche per livello di necessità
  Future<Map<NecessityLevel, double>> getExpenseStatsByNecessityLevel(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final stats = await _expenseRepository.getExpenseStatsByNecessityLevel(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Statistiche spese per necessità: ${stats.length} livelli');
      return stats;
    } catch (e) {
      debugPrint('Errore nel calcolo statistiche necessità: $e');
      rethrow;
    }
  }

  /// Ottieni la media delle spese mensili
  Future<double> getMonthlyExpenseAverage(String userId, {int monthsCount = 12}) async {
    try {
      _validateUserId(userId);
      _validateMonthsCount(monthsCount);

      final average = await _expenseRepository.getMonthlyExpenseAverage(
        userId,
        monthsCount: monthsCount,
      );

      debugPrint('Media mensile spese (${monthsCount} mesi): €${average.toStringAsFixed(2)}');
      return average;
    } catch (e) {
      debugPrint('Errore nel calcolo media mensile: $e');
      rethrow;
    }
  }

  /// Calcola lo stato del budget per il mese corrente
  Future<Map<String, double>> getCurrentMonthBudgetStatus(String userId, double monthlyBudget) async {
    try {
      _validateUserId(userId);
      _validateBudget(monthlyBudget);

      final budgetStatus = await _expenseRepository.getCurrentMonthBudgetStatus(userId, monthlyBudget);

      debugPrint('Stato budget mese corrente: ${budgetStatus['percentage']?.toStringAsFixed(1)}% utilizzato');
      return budgetStatus;
    } catch (e) {
      debugPrint('Errore nel calcolo stato budget: $e');
      rethrow;
    }
  }

  /// Ottieni riepilogo spese del mese corrente
  Future<Map<String, dynamic>> getCurrentMonthSummary(String userId, {double? monthlyBudget}) async {
    try {
      _validateUserId(userId);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final expenses = await getCurrentMonthExpenses(userId);
      final total = await getTotalExpenseForPeriod(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final categoryStats = await getExpenseStatsByCategory(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final necessityStats = await getExpenseStatsByNecessityLevel(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final topExpenses = await getTopExpensesByAmount(
        userId,
        limit: 5,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final average = await getMonthlyExpenseAverage(userId, monthsCount: 6);

      Map<String, double>? budgetStatus;
      if (monthlyBudget != null && monthlyBudget > 0) {
        budgetStatus = await getCurrentMonthBudgetStatus(userId, monthlyBudget);
      }

      final summary = {
        'period': {
          'month': now.month,
          'year': now.year,
          'start_date': startOfMonth,
          'end_date': endOfMonth,
        },
        'totals': {
          'current_month': total,
          'transaction_count': expenses.length,
          'average_per_transaction': expenses.isNotEmpty ? total / expenses.length : 0.0,
          'monthly_average': average,
        },
        'budget_status': budgetStatus,
        'category_breakdown': categoryStats,
        'necessity_breakdown': necessityStats.map((key, value) => MapEntry(key.value, value)),
        'top_expenses': topExpenses.map((expense) => {
          'id': expense.id,
          'amount': expense.amount,
          'description': expense.description,
          'category': expense.category.description,
          'date': expense.expenseDate,
        }).toList(),
        'recent_expenses': expenses.take(5).map((expense) => {
          'id': expense.id,
          'amount': expense.amount,
          'description': expense.description,
          'category': expense.category.description,
          'date': expense.expenseDate,
          'is_high_priority': expense.isHighPriority,
        }).toList(),
      };

      debugPrint('Riepilogo spese mese corrente generato');
      return summary;
    } catch (e) {
      debugPrint('Errore nella generazione riepilogo mensile: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // GESTIONE BUDGET E ALLERTE
  // ==============================================================================

  /// Verifica se il budget mensile è superato
  Future<bool> isBudgetExceeded(String userId, double monthlyBudget) async {
    try {
      _validateUserId(userId);
      _validateBudget(monthlyBudget);

      final budgetStatus = await getCurrentMonthBudgetStatus(userId, monthlyBudget);
      final remaining = budgetStatus['remaining'] ?? 0.0;

      final exceeded = remaining < 0;
      debugPrint('Budget ${exceeded ? 'superato' : 'rispettato'}: rimanente €${remaining.toStringAsFixed(2)}');
      return exceeded;
    } catch (e) {
      debugPrint('Errore nella verifica budget: $e');
      rethrow;
    }
  }

  /// Calcola quanto manca al raggiungimento del budget
  Future<double> getRemainingBudget(String userId, double monthlyBudget) async {
    try {
      _validateUserId(userId);
      _validateBudget(monthlyBudget);

      final budgetStatus = await getCurrentMonthBudgetStatus(userId, monthlyBudget);
      final remaining = budgetStatus['remaining'] ?? 0.0;

      debugPrint('Budget rimanente: €${remaining.toStringAsFixed(2)}');
      return remaining;
    } catch (e) {
      debugPrint('Errore nel calcolo budget rimanente: $e');
      rethrow;
    }
  }

  /// Suggerisce il budget ottimale basato sulla storia delle spese
  Future<double> suggestOptimalBudget(String userId, {int monthsToAnalyze = 6}) async {
    try {
      _validateUserId(userId);
      _validateMonthsCount(monthsToAnalyze);

      final average = await getMonthlyExpenseAverage(userId, monthsCount: monthsToAnalyze);

      // Aggiungi un margine del 15% per sicurezza
      final suggestedBudget = average * 1.15;

      debugPrint('Budget suggerito basato su ${monthsToAnalyze} mesi: €${suggestedBudget.toStringAsFixed(2)}');
      return suggestedBudget;
    } catch (e) {
      debugPrint('Errore nel suggerimento budget: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // GESTIONE RICORRENZE
  // ==============================================================================

  /// Genera le prossime spese ricorrenti
  Future<List<ExpenseModel>> generateRecurringExpenses(String userId) async {
    try {
      _validateUserId(userId);

      final newExpenses = await _expenseRepository.generateRecurringExpenses(userId);
      debugPrint('Generate ${newExpenses.length} nuove spese ricorrenti');
      return newExpenses;
    } catch (e) {
      debugPrint('Errore nella generazione spese ricorrenti: $e');
      rethrow;
    }
  }

  /// Aggiorna impostazioni ricorrenza per una spesa esistente
  Future<ExpenseModel> updateRecurrenceSettings({
    required String userId,
    required String expenseId,
    required bool isRecurring,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      _validateUserId(userId);
      _validateExpenseId(expenseId);
      _validateRecurrenceData(isRecurring, recurrenceSettings);

      final updatedExpense = await _expenseRepository.updateExpense(
        userId: userId,
        expenseId: expenseId,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Impostazioni ricorrenza aggiornate per spesa: $expenseId');
      return updatedExpense;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento ricorrenza: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STREAM E REAL-TIME
  // ==============================================================================

  /// Stream delle spese dell'utente
  Stream<List<ExpenseModel>> getUserExpensesStream(
      String userId, {
        int? limit,
        DateTime? startDate,
        DateTime? endDate,
      }) {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      debugPrint('Avviato stream spese per utente: $userId');
      return _expenseRepository.getUserExpensesStream(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Errore nell\'avvio stream spese: $e');
      rethrow;
    }
  }

  /// Stream delle spese del mese corrente
  Stream<List<ExpenseModel>> getCurrentMonthExpensesStream(String userId) {
    try {
      _validateUserId(userId);

      debugPrint('Avviato stream spese mese corrente per utente: $userId');
      return _expenseRepository.getCurrentMonthExpensesStream(userId);
    } catch (e) {
      debugPrint('Errore nell\'avvio stream spese mese corrente: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // UTILITY E HELPER METHODS
  // ==============================================================================

  /// Duplica una spesa esistente
  Future<ExpenseModel> duplicateExpense(String userId, String expenseId, {
    DateTime? newDate,
    double? newAmount,
  }) async {
    try {
      _validateUserId(userId);
      _validateExpenseId(expenseId);

      final originalExpense = await getExpenseById(userId, expenseId);
      if (originalExpense == null) {
        throw const ValidationException('Spesa originale non trovata');
      }

      final duplicatedExpense = await createExpense(
        userId: userId,
        amount: newAmount ?? originalExpense.amount,
        description: '${originalExpense.description} (copia)',
        categoryId: originalExpense.category.id,
        expenseDate: newDate ?? DateTime.now(),
        isRecurring: false, // Le copie non sono mai ricorrenti
        recurrenceSettings: null,
      );

      debugPrint('Spesa duplicata: ${duplicatedExpense.id}');
      return duplicatedExpense;
    } catch (e) {
      debugPrint('Errore nella duplicazione spesa: $e');
      rethrow;
    }
  }

  /// Verifica se una spesa può essere eliminata
  Future<bool> canDeleteExpense(String userId, String expenseId) async {
    try {
      _validateUserId(userId);
      _validateExpenseId(expenseId);

      final expense = await getExpenseById(userId, expenseId);
      if (expense == null) return false;

      // Per ora non ci sono dipendenze da controllare
      return true;
    } catch (e) {
      debugPrint('Errore nella verifica eliminazione spesa: $e');
      return false;
    }
  }

  // ==============================================================================
  // VALIDAZIONI PRIVATE
  // ==============================================================================

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw const ValidationException('User ID richiesto');
    }
  }

  void _validateExpenseId(String expenseId) {
    if (expenseId.trim().isEmpty) {
      throw const ValidationException('Expense ID richiesto');
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

  void _validateRecurrenceData(bool isRecurring, RecurrenceSettings? settings) {
    if (isRecurring) {
      if (settings == null) {
        throw const ValidationException('Impostazioni ricorrenza richieste per spese ricorrenti');
      }

      if (settings.endDate != null && settings.endDate!.isBefore(settings.startDate)) {
        throw const ValidationException('Data fine ricorrenza deve essere successiva alla data inizio');
      }

      if (settings.type == RecurrenceType.custom && (settings.customIntervalDays == null || settings.customIntervalDays! <= 0)) {
        throw const ValidationException('Intervallo personalizzato richiesto per ricorrenza custom');
      }
    }
  }

  void _validateMonthsCount(int monthsCount) {
    if (monthsCount <= 0 || monthsCount > 60) {
      throw const ValidationException('Numero di mesi non valido (1-60)');
    }
  }

  void _validateLimit(int limit) {
    if (limit <= 0 || limit > 100) {
      throw const ValidationException('Limite non valido (1-100)');
    }
  }

  void _validateBudget(double budget) {
    if (budget < 0) {
      throw const ValidationException('Budget deve essere positivo');
    }
    if (budget > 999999999.99) {
      throw const ValidationException('Budget troppo elevato');
    }
  }

  Future<CategoryModel?> _getCategoryForUser(String userId, String categoryId, {required bool isIncome}) async {
    return await _categoryRepository.getCategoryById(userId, categoryId, isIncome: isIncome);
  }
}