import 'package:flutter/foundation.dart';
import '../repositories/income_repository.dart';
import '../repositories/category_repository.dart';
import '../models/income_model.dart';
import '../models/category_model.dart';
import '../models/recurrence_model.dart';
import '../../core/errors/app_exceptions.dart';

class IncomeController {
  final IncomeRepository _incomeRepository;
  final CategoryRepository _categoryRepository;

  IncomeController({
    IncomeRepository? incomeRepository,
    CategoryRepository? categoryRepository,
  }) : _incomeRepository = incomeRepository ?? IncomeRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository();

  // ==============================================================================
  // OPERAZIONI CRUD BASE
  // ==============================================================================

  /// Crea una nuova entrata
  Future<IncomeModel> createIncome({
    required String userId,
    required double amount,
    required String description,
    required String categoryId,
    required DateTime incomeDate,
    bool isRecurring = false,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      // Validazioni
      _validateUserId(userId);
      _validateAmount(amount);
      _validateDescription(description);
      _validateDate(incomeDate);
      _validateRecurrenceData(isRecurring, recurrenceSettings);

      // Recupera la categoria
      final category = await _getCategoryForUser(userId, categoryId, isIncome: true);
      if (category == null) {
        throw const ValidationException('Categoria non trovata');
      }

      final income = await _incomeRepository.createIncome(
        userId: userId,
        amount: amount,
        description: description.trim(),
        category: category,
        incomeDate: incomeDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Entrata creata con successo: ${income.id}');
      return income;
    } catch (e) {
      debugPrint('Errore nella creazione entrata: $e');
      rethrow;
    }
  }

  /// Ottieni un'entrata per ID
  Future<IncomeModel?> getIncomeById(String userId, String incomeId) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      final income = await _incomeRepository.getIncomeById(userId, incomeId);
      if (income != null) {
        debugPrint('Entrata trovata: ${income.description}');
      } else {
        debugPrint('Entrata non trovata: $incomeId');
      }
      return income;
    } catch (e) {
      debugPrint('Errore nel recupero entrata: $e');
      rethrow;
    }
  }

  /// Ottieni tutte le entrate dell'utente con filtri
  Future<List<IncomeModel>> getUserIncomes(
      String userId, {
        int? limit,
        DateTime? startDate,
        DateTime? endDate,
        String? categoryId,
        bool? isRecurring,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final incomes = await _incomeRepository.getUserIncomes(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        isRecurring: isRecurring,
      );

      debugPrint('Recuperate ${incomes.length} entrate per utente: $userId');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate utente: $e');
      rethrow;
    }
  }

  /// Aggiorna un'entrata esistente
  Future<IncomeModel> updateIncome({
    required String userId,
    required String incomeId,
    double? amount,
    String? description,
    String? categoryId,
    DateTime? incomeDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      if (amount != null) _validateAmount(amount);
      if (description != null) _validateDescription(description);
      if (incomeDate != null) _validateDate(incomeDate);
      if (isRecurring != null) _validateRecurrenceData(isRecurring, recurrenceSettings);

      // Recupera la categoria se specificata
      CategoryModel? category;
      if (categoryId != null) {
        category = await _getCategoryForUser(userId, categoryId, isIncome: true);
        if (category == null) {
          throw const ValidationException('Categoria non trovata');
        }
      }

      final updatedIncome = await _incomeRepository.updateIncome(
        userId: userId,
        incomeId: incomeId,
        amount: amount,
        description: description?.trim(),
        category: category,
        incomeDate: incomeDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Entrata aggiornata: $incomeId');
      return updatedIncome;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento entrata: $e');
      rethrow;
    }
  }

  /// Elimina un'entrata
  Future<void> deleteIncome(String userId, String incomeId) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      await _incomeRepository.deleteIncome(userId, incomeId);
      debugPrint('Entrata eliminata: $incomeId');
    } catch (e) {
      debugPrint('Errore nell\'eliminazione entrata: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // QUERY SPECIALIZZATE
  // ==============================================================================

  /// Ottieni entrate del mese corrente
  Future<List<IncomeModel>> getCurrentMonthIncomes(String userId) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getCurrentMonthIncomes(userId);
      debugPrint('Recuperate ${incomes.length} entrate del mese corrente');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate mese corrente: $e');
      rethrow;
    }
  }

  /// Ottieni entrate della settimana corrente
  Future<List<IncomeModel>> getCurrentWeekIncomes(String userId) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getCurrentWeekIncomes(userId);
      debugPrint('Recuperate ${incomes.length} entrate della settimana corrente');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate settimana corrente: $e');
      rethrow;
    }
  }

  /// Ottieni entrate ricorrenti attive
  Future<List<IncomeModel>> getActiveRecurringIncomes(String userId) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getActiveRecurringIncomes(userId);
      debugPrint('Recuperate ${incomes.length} entrate ricorrenti attive');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate ricorrenti: $e');
      rethrow;
    }
  }

  /// Ottieni entrate per categoria
  Future<List<IncomeModel>> getIncomesByCategory(
      String userId,
      String categoryId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final incomes = await _incomeRepository.getIncomesByCategory(
        userId,
        categoryId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Recuperate ${incomes.length} entrate per categoria: $categoryId');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate per categoria: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STATISTICHE E ANALYTICS
  // ==============================================================================

  /// Calcola il totale delle entrate per un periodo
  Future<double> getTotalIncomeForPeriod(
      String userId, {
        required DateTime startDate,
        required DateTime endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final total = await _incomeRepository.getTotalIncomeForPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Totale entrate periodo: €${total.toStringAsFixed(2)}');
      return total;
    } catch (e) {
      debugPrint('Errore nel calcolo totale entrate: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche entrate per categoria
  Future<Map<String, double>> getIncomeStatsByCategory(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final stats = await _incomeRepository.getIncomeStatsByCategory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Statistiche entrate per categoria: ${stats.length} categorie');
      return stats;
    } catch (e) {
      debugPrint('Errore nel calcolo statistiche per categoria: $e');
      rethrow;
    }
  }

  /// Ottieni la media delle entrate mensili
  Future<double> getMonthlyIncomeAverage(String userId, {int monthsCount = 12}) async {
    try {
      _validateUserId(userId);
      _validateMonthsCount(monthsCount);

      final average = await _incomeRepository.getMonthlyIncomeAverage(
        userId,
        monthsCount: monthsCount,
      );

      debugPrint('Media mensile entrate (${monthsCount} mesi): €${average.toStringAsFixed(2)}');
      return average;
    } catch (e) {
      debugPrint('Errore nel calcolo media mensile: $e');
      rethrow;
    }
  }

  /// Ottieni riepilogo entrate del mese corrente
  Future<Map<String, dynamic>> getCurrentMonthSummary(String userId) async {
    try {
      _validateUserId(userId);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final incomes = await getCurrentMonthIncomes(userId);
      final total = await getTotalIncomeForPeriod(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final stats = await getIncomeStatsByCategory(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
      final average = await getMonthlyIncomeAverage(userId, monthsCount: 6);

      final summary = {
        'period': {
          'month': now.month,
          'year': now.year,
          'start_date': startOfMonth,
          'end_date': endOfMonth,
        },
        'totals': {
          'current_month': total,
          'transaction_count': incomes.length,
          'average_per_transaction': incomes.isNotEmpty ? total / incomes.length : 0.0,
          'monthly_average': average,
        },
        'category_breakdown': stats,
        'recent_incomes': incomes.take(5).map((income) => {
          'id': income.id,
          'amount': income.amount,
          'description': income.description,
          'category': income.category.description,
          'date': income.incomeDate,
        }).toList(),
      };

      debugPrint('Riepilogo entrate mese corrente generato');
      return summary;
    } catch (e) {
      debugPrint('Errore nella generazione riepilogo mensile: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // GESTIONE RICORRENZE
  // ==============================================================================

  /// Genera le prossime entrate ricorrenti
  Future<List<IncomeModel>> generateRecurringIncomes(String userId) async {
    try {
      _validateUserId(userId);

      final newIncomes = await _incomeRepository.generateRecurringIncomes(userId);
      debugPrint('Generate ${newIncomes.length} nuove entrate ricorrenti');
      return newIncomes;
    } catch (e) {
      debugPrint('Errore nella generazione entrate ricorrenti: $e');
      rethrow;
    }
  }

  /// Aggiorna impostazioni ricorrenza per un'entrata esistente
  Future<IncomeModel> updateRecurrenceSettings({
    required String userId,
    required String incomeId,
    required bool isRecurring,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);
      _validateRecurrenceData(isRecurring, recurrenceSettings);

      final updatedIncome = await _incomeRepository.updateIncome(
        userId: userId,
        incomeId: incomeId,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Impostazioni ricorrenza aggiornate per entrata: $incomeId');
      return updatedIncome;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento ricorrenza: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STREAM E REAL-TIME
  // ==============================================================================

  /// Stream delle entrate dell'utente
  Stream<List<IncomeModel>> getUserIncomesStream(
      String userId, {
        int? limit,
        DateTime? startDate,
        DateTime? endDate,
      }) {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      debugPrint('Avviato stream entrate per utente: $userId');
      return _incomeRepository.getUserIncomesStream(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Errore nell\'avvio stream entrate: $e');
      rethrow;
    }
  }

  /// Stream delle entrate del mese corrente
  Stream<List<IncomeModel>> getCurrentMonthIncomesStream(String userId) {
    try {
      _validateUserId(userId);

      debugPrint('Avviato stream entrate mese corrente per utente: $userId');
      return _incomeRepository.getCurrentMonthIncomesStream(userId);
    } catch (e) {
      debugPrint('Errore nell\'avvio stream entrate mese corrente: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // UTILITY E HELPER METHODS
  // ==============================================================================

  /// Duplica un'entrata esistente
  Future<IncomeModel> duplicateIncome(String userId, String incomeId, {
    DateTime? newDate,
    double? newAmount,
  }) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      final originalIncome = await getIncomeById(userId, incomeId);
      if (originalIncome == null) {
        throw const ValidationException('Entrata originale non trovata');
      }

      final duplicatedIncome = await createIncome(
        userId: userId,
        amount: newAmount ?? originalIncome.amount,
        description: '${originalIncome.description} (copia)',
        categoryId: originalIncome.category.id,
        incomeDate: newDate ?? DateTime.now(),
        isRecurring: false, // Le copie non sono mai ricorrenti
        recurrenceSettings: null,
      );

      debugPrint('Entrata duplicata: ${duplicatedIncome.id}');
      return duplicatedIncome;
    } catch (e) {
      debugPrint('Errore nella duplicazione entrata: $e');
      rethrow;
    }
  }

  /// Verifica se un'entrata può essere eliminata (non ha dipendenze)
  Future<bool> canDeleteIncome(String userId, String incomeId) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      final income = await getIncomeById(userId, incomeId);
      if (income == null) return false;

      // Per ora non ci sono dipendenze da controllare
      // In futuro si potranno aggiungere controlli per budget, progetti, etc.
      return true;
    } catch (e) {
      debugPrint('Errore nella verifica eliminazione entrata: $e');
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

  void _validateIncomeId(String incomeId) {
    if (incomeId.trim().isEmpty) {
      throw const ValidationException('Income ID richiesto');
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
        throw const ValidationException('Impostazioni ricorrenza richieste per entrate ricorrenti');
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

  Future<CategoryModel?> _getCategoryForUser(String userId, String categoryId, {required bool isIncome}) async {
    return await _categoryRepository.getCategoryById(userId, categoryId, isIncome: isIncome);
  }
}