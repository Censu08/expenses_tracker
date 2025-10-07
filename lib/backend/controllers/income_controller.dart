import 'package:flutter/foundation.dart';
import '../../core/utils/income_export_helper.dart';
import '../models/income/income_model.dart';
import '../models/income/income_source_enum.dart';
import '../repositories/income_repository.dart';
import '../repositories/category_repository.dart';
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
    required IncomeSource source, // ⬅️ NUOVO PARAMETRO
    bool isRecurring = false,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      // Validazioni
      _validateUserId(userId);
      _validateAmount(amount);
      _validateDescription(description);
      _validateDate(incomeDate);
      _validateSource(source); // ⬅️ NUOVA VALIDAZIONE
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
        incomeDate: incomeDate,
        source: source, // ⬅️ NUOVO CAMPO
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
      );

      debugPrint('Entrata creata con successo: ${income.id} (source: ${income.source.displayName})');
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
    IncomeSource? source, // ⬅️ NUOVO PARAMETRO
  }) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      if (amount != null) _validateAmount(amount);
      if (description != null) _validateDescription(description);
      if (incomeDate != null) _validateDate(incomeDate);
      if (source != null) _validateSource(source); // ⬅️ NUOVA VALIDAZIONE
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
        source: source, // ⬅️ NUOVO CAMPO
      );

      debugPrint('Entrata aggiornata: ${updatedIncome.id}');
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

  /// Duplica un'entrata esistente
  Future<IncomeModel> duplicateIncome(
      String userId,
      String incomeId, {
        DateTime? newDate,
        double? newAmount,
      }) async {
    try {
      _validateUserId(userId);
      _validateIncomeId(incomeId);

      if (newAmount != null) _validateAmount(newAmount);
      if (newDate != null) _validateDate(newDate);

      final duplicatedIncome = await _incomeRepository.duplicateIncome(
        userId,
        incomeId,
        newDate: newDate,
        newAmount: newAmount,
      );

      debugPrint('Entrata duplicata: ${duplicatedIncome.id}');
      return duplicatedIncome;
    } catch (e) {
      debugPrint('Errore nella duplicazione entrata: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // ⬅️ NUOVE OPERAZIONI PER SOURCE
  // ==============================================================================

  /// Ottieni entrate filtrate per fonte
  Future<List<IncomeModel>> getIncomesBySource(
      String userId,
      IncomeSource source, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateSource(source);
      _validateDateRange(startDate, endDate);

      final incomes = await _incomeRepository.getIncomesBySource(
        userId,
        source,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Recuperate ${incomes.length} entrate con fonte: ${source.displayName}');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate per fonte: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche aggregate per fonte
  Future<Map<IncomeSource, double>> getIncomeStatsBySource(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateDateRange(startDate, endDate);

      final stats = await _incomeRepository.getIncomeStatsBySource(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Statistiche per fonte calcolate: ${stats.length} fonti trovate');
      return stats;
    } catch (e) {
      debugPrint('Errore nel calcolo statistiche per fonte: $e');
      rethrow;
    }
  }

  /// Ottieni totale entrate per una specifica fonte
  Future<double> getTotalIncomeBySource(
      String userId,
      IncomeSource source, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      _validateUserId(userId);
      _validateSource(source);
      _validateDateRange(startDate, endDate);

      final total = await _incomeRepository.getTotalIncomeBySource(
        userId,
        source,
        startDate: startDate,
        endDate: endDate,
      );

      debugPrint('Totale per fonte ${source.displayName}: €$total');
      return total;
    } catch (e) {
      debugPrint('Errore nel calcolo totale per fonte: $e');
      rethrow;
    }
  }

  /// Calcola diversification score (0-100)
  /// Score alto = entrate diversificate tra più fonti
  Future<int> calculateDiversificationScore(String userId) async {
    try {
      _validateUserId(userId);

      final stats = await getIncomeStatsBySource(userId);
      final score = IncomeSourceHelper.calculateDiversificationScore(stats);

      debugPrint('Diversification score: $score/100');
      return score;
    } catch (e) {
      debugPrint('Errore nel calcolo diversification score: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // QUERY SPECIFICHE
  // ==============================================================================

  /// Ottieni entrate del mese corrente
  Future<List<IncomeModel>> getCurrentMonthIncomes(String userId) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getCurrentMonthIncomes(userId);
      debugPrint('Entrate mese corrente: ${incomes.length}');
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
      debugPrint('Entrate settimana corrente: ${incomes.length}');
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
      debugPrint('Entrate ricorrenti attive: ${incomes.length}');
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

      debugPrint('Entrate per categoria $categoryId: ${incomes.length}');
      return incomes;
    } catch (e) {
      debugPrint('Errore nel recupero entrate per categoria: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STATISTICHE
  // ==============================================================================

  /// Ottieni totale entrate per periodo
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

      debugPrint('Totale entrate periodo: €$total');
      return total;
    } catch (e) {
      debugPrint('Errore nel calcolo totale periodo: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche per categoria
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

      debugPrint('Statistiche per categoria calcolate: ${stats.length} categorie');
      return stats;
    } catch (e) {
      debugPrint('Errore nel calcolo statistiche per categoria: $e');
      rethrow;
    }
  }

  /// Ottieni media mensile entrate
  Future<double> getMonthlyIncomeAverage(
      String userId, {
        int monthsCount = 12,
      }) async {
    try {
      _validateUserId(userId);

      if (monthsCount <= 0) {
        throw const ValidationException('Il numero di mesi deve essere maggiore di zero');
      }

      final average = await _incomeRepository.getMonthlyIncomeAverage(
        userId,
        monthsCount: monthsCount,
      );

      debugPrint('Media mensile ($monthsCount mesi): €$average');
      return average;
    } catch (e) {
      debugPrint('Errore nel calcolo media mensile: $e');
      rethrow;
    }
  }

  /// Genera riepilogo completo mese corrente
  Future<Map<String, dynamic>> getCurrentMonthSummary(String userId) async {
    try {
      _validateUserId(userId);

      final incomes = await getCurrentMonthIncomes(userId);
      final total = incomes.fold(0.0, (sum, income) => sum + income.amount);
      final average = await getMonthlyIncomeAverage(userId);
      final stats = await getIncomeStatsByCategory(userId);

      // ⬅️ NUOVO: Aggiungi stats per fonte
      final sourceStats = await getIncomeStatsBySource(userId);
      final diversificationScore = IncomeSourceHelper.calculateDiversificationScore(sourceStats);

      final summary = {
        'total': total,
        'count': incomes.length,
        'average': incomes.isNotEmpty ? total / incomes.length : 0.0,
        'monthly_average': average,
        'category_breakdown': stats,
        'source_breakdown': sourceStats.map((key, value) => MapEntry(key.displayName, value)), // ⬅️ NUOVO
        'diversification_score': diversificationScore, // ⬅️ NUOVO
        'recent_incomes': incomes.take(5).map((income) => {
          'id': income.id,
          'amount': income.amount,
          'description': income.description,
          'source': income.source.displayName, // ⬅️ NUOVO
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

      return _incomeRepository.getUserIncomesStream(
        userId,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Errore nell\'apertura stream entrate: $e');
      rethrow;
    }
  }

  /// Stream delle entrate del mese corrente
  Stream<List<IncomeModel>> getCurrentMonthIncomesStream(String userId) {
    try {
      _validateUserId(userId);
      return _incomeRepository.getCurrentMonthIncomesStream(userId);
    } catch (e) {
      debugPrint('Errore nell\'apertura stream mese corrente: $e');
      rethrow;
    }
  }

  Future<String> exportIncomesToCSV({
    required String userId,
    bool groupBySource = false,
    DateTime? startDate,
    DateTime? endDate,
    IncomeSource? filterSource,
  }) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final filteredIncomes = filterSource != null
          ? incomes.where((i) => i.source == filterSource).toList()
          : incomes;

      debugPrint('Exporting ${filteredIncomes.length} incomes to CSV');

      return IncomeExportHelper.exportToCSV(
        incomes: filteredIncomes,
        groupBySource: groupBySource,
      );
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      rethrow;
    }
  }

  Future<String> exportIncomesToJSON({
    required String userId,
    bool groupBySource = false,
    DateTime? startDate,
    DateTime? endDate,
    IncomeSource? filterSource,
  }) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final filteredIncomes = filterSource != null
          ? incomes.where((i) => i.source == filterSource).toList()
          : incomes;

      debugPrint('Exporting ${filteredIncomes.length} incomes to JSON');

      return IncomeExportHelper.exportToJSON(
        incomes: filteredIncomes,
        groupBySource: groupBySource,
      );
    } catch (e) {
      debugPrint('Error exporting to JSON: $e');
      rethrow;
    }
  }

  Future<String> generateSourceAnalyticsReport({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _validateUserId(userId);

      final sourceStats = await _incomeRepository.getIncomeStatsBySource(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final score = IncomeSourceHelper.calculateDiversificationScore(sourceStats);

      debugPrint('Generating analytics report for ${sourceStats.length} sources');

      return IncomeExportHelper.generateSourceReport(
        sourceStats: sourceStats,
        diversificationScore: score,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      debugPrint('Error generating report: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExportMetadata({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _validateUserId(userId);

      final incomes = await _incomeRepository.getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final sourceStats = await _incomeRepository.getIncomeStatsBySource(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final totalAmount = incomes.fold(0.0, (sum, i) => sum + i.amount);

      return {
        'total_incomes': incomes.length,
        'total_amount': totalAmount,
        'sources_count': sourceStats.length,
        'date_range': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
        'export_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting export metadata: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // VALIDAZIONI PRIVATE
  // ==============================================================================

  void _validateUserId(String userId) {
    if (userId.isEmpty) {
      throw const ValidationException('User ID non può essere vuoto');
    }
  }

  void _validateIncomeId(String incomeId) {
    if (incomeId.isEmpty) {
      throw const ValidationException('Income ID non può essere vuoto');
    }
  }

  void _validateAmount(double amount) {
    if (amount <= 0) {
      throw const ValidationException('L\'importo deve essere maggiore di zero');
    }
    if (amount > 1000000000) {
      throw const ValidationException('L\'importo è troppo elevato');
    }
  }

  void _validateDescription(String description) {
    if (description.trim().isEmpty) {
      throw const ValidationException('La descrizione non può essere vuota');
    }
    if (description.trim().length < 3) {
      throw const ValidationException('La descrizione deve contenere almeno 3 caratteri');
    }
    if (description.length > 100) {
      throw const ValidationException('La descrizione non può superare 100 caratteri');
    }
  }

  void _validateDate(DateTime date) {
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365 * 5)); // 5 anni nel futuro

    if (date.isAfter(maxFutureDate)) {
      throw const ValidationException('La data non può essere così lontana nel futuro');
    }
  }

  // ⬅️ NUOVA VALIDAZIONE
  void _validateSource(IncomeSource source) {
    // Il source è un enum, quindi è sempre valido
    // Ma possiamo aggiungere logiche future se necessario
    debugPrint('Source validato: ${source.displayName}');
  }

  void _validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        throw const ValidationException('La data di inizio deve essere precedente alla data di fine');
      }
    }
  }

  void _validateRecurrenceData(bool isRecurring, RecurrenceSettings? settings) {
    if (isRecurring && settings == null) {
      throw const ValidationException(
          'Le impostazioni di ricorrenza sono obbligatorie quando l\'entrata è ricorrente'
      );
    }

    if (!isRecurring && settings != null) {
      throw const ValidationException(
          'Non è possibile specificare impostazioni di ricorrenza per un\'entrata non ricorrente'
      );
    }
  }

  // ==============================================================================
  // HELPER PRIVATI
  // ==============================================================================

  Future<CategoryModel?> _getCategoryForUser(
      String userId,
      String categoryId, {
        required bool isIncome,
      }) async {
    try {
      // Prima cerca nelle categorie default
      final defaultCategories = isIncome
          ? CategoryModel.getDefaultIncomeCategories()
          : CategoryModel.getDefaultExpenseCategories();

      for (final category in defaultCategories) {
        if (category.id == categoryId) {
          return category;
        }
      }

      // Poi cerca nelle categorie custom dell'utente
      // ⬅️ FIX: Usa getUserCustomCategoryById invece di getCustomCategoryById
      final customCategory = await _categoryRepository.getUserCustomCategoryById(
        userId,
        categoryId,
      );

      return customCategory;
    } catch (e) {
      debugPrint('Errore nel recupero categoria: $e');
      return null;
    }
  }
}

class IncomeSourceHelper {
  static int calculateDiversificationScore(Map<IncomeSource, double> sourceStats) {
    if (sourceStats.isEmpty) return 0;
    if (sourceStats.length == 1) return 20;

    final totalAmount = sourceStats.values.fold(0.0, (sum, amount) => sum + amount);
    if (totalAmount == 0) return 0;

    double herfindahlIndex = 0;
    for (var amount in sourceStats.values) {
      final share = amount / totalAmount;
      herfindahlIndex += share * share;
    }

    final normalizedHHI = (herfindahlIndex - (1 / sourceStats.length)) /
        (1 - (1 / sourceStats.length));

    final diversificationScore = ((1 - normalizedHHI) * 100).round();

    final sourceBonus = (sourceStats.length - 1) * 5;
    final finalScore = (diversificationScore + sourceBonus).clamp(0, 100);

    return finalScore;
  }
}