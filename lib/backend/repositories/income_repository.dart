import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/income/income_model.dart';
import '../models/income/income_source_enum.dart';
import '../models/recurrence_model.dart'; // ⬅️ NUOVO IMPORT
import '../../core/utils/id_generator.dart';

class IncomeRepository {
  final FirebaseFirestore _firestore;

  IncomeRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Riferimento alla subcollection delle entrate dell'utente
  CollectionReference _getUserIncomesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes');
  }

  // OPERAZIONI CRUD

  /// Crea una nuova entrata
  Future<IncomeModel> createIncome({
    required String userId,
    required double amount,
    required String description,
    required DateTime incomeDate,
    required IncomeSource source, // ⬅️ NUOVO PARAMETRO
    bool isRecurring = false,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      final incomeId = IdGenerator.generateIncomeId();
      final now = DateTime.now();

      final income = IncomeModel(
        id: incomeId,
        amount: amount,
        description: description,
        createdAt: now,
        incomeDate: incomeDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
        userId: userId,
        source: source, // ⬅️ NUOVO CAMPO
      );

      await _getUserIncomesRef(userId)
          .doc(incomeId)
          .set(income.toJson());

      return income;
    } catch (e) {
      throw Exception('Errore nella creazione dell\'entrata: $e');
    }
  }

  /// Ottieni un'entrata per ID
  Future<IncomeModel?> getIncomeById(String userId, String incomeId) async {
    try {
      final doc = await _getUserIncomesRef(userId)
          .doc(incomeId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return IncomeModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nel recupero dell\'entrata: $e');
    }
  }

  /// Ottieni tutte le entrate dell'utente
  Future<List<IncomeModel>> getUserIncomes(String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    bool? isRecurring,
  }) async {
    try {
      Query query = _getUserIncomesRef(userId);

      // Filtro per data di inizio
      if (startDate != null) {
        query = query.where('income_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      // Filtro per data di fine
      if (endDate != null) {
        query = query.where('income_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      // Filtro per categoria
      if (categoryId != null) {
        query = query.where('category.id', isEqualTo: categoryId);
      }

      // Filtro per ricorrenza
      if (isRecurring != null) {
        query = query.where('is_recurring', isEqualTo: isRecurring);
      }

      // Ordinamento per data (più recenti prima)
      query = query.orderBy('income_date', descending: true);

      // Limite risultati
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => IncomeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel recupero delle entrate: $e');
    }
  }

  /// Aggiorna un'entrata esistente
  Future<IncomeModel> updateIncome({
    required String userId,
    required String incomeId,
    double? amount,
    String? description,
    CategoryModel? category,
    DateTime? incomeDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
    IncomeSource? source, // ⬅️ NUOVO PARAMETRO
  }) async {
    try {
      final existingIncome = await getIncomeById(userId, incomeId);
      if (existingIncome == null) {
        throw Exception('Entrata non trovata');
      }

      final updatedIncome = existingIncome.copyWith(
        amount: amount ?? existingIncome.amount,
        description: description ?? existingIncome.description,
        incomeDate: incomeDate ?? existingIncome.incomeDate,
        isRecurring: isRecurring ?? existingIncome.isRecurring,
        recurrenceSettings: recurrenceSettings ?? existingIncome.recurrenceSettings,
        source: source ?? existingIncome.source, // ⬅️ NUOVO CAMPO
      );

      await _getUserIncomesRef(userId)
          .doc(incomeId)
          .update(updatedIncome.toJson());

      return updatedIncome;
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento dell\'entrata: $e');
    }
  }

  /// Elimina un'entrata
  Future<void> deleteIncome(String userId, String incomeId) async {
    try {
      final income = await getIncomeById(userId, incomeId);
      if (income == null) {
        throw Exception('Entrata non trovata');
      }

      await _getUserIncomesRef(userId)
          .doc(incomeId)
          .delete();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione dell\'entrata: $e');
    }
  }

  // ⬅️ NUOVE QUERY PER SOURCE

  /// Ottieni entrate filtrate per fonte
  Future<List<IncomeModel>> getIncomesBySource(
      String userId,
      IncomeSource source, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      Query query = _getUserIncomesRef(userId)
          .where('source', isEqualTo: source.toJson());

      if (startDate != null) {
        query = query.where('income_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('income_date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('income_date', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => IncomeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel recupero entrate per fonte: $e');
    }
  }

  /// Ottieni statistiche aggregate per fonte
  Future<Map<IncomeSource, double>> getIncomeStatsBySource(
      String userId, {
        DateTime? startDate,
        DateTime? endDate,
      }) async {
    try {
      // Recupera tutte le entrate per il periodo
      final incomes = await getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Aggrega per fonte
      final Map<IncomeSource, double> stats = {};

      for (final income in incomes) {
        stats[income.source] = (stats[income.source] ?? 0.0) + income.amount;
      }

      return stats;
    } catch (e) {
      throw Exception('Errore nel calcolo statistiche per fonte: $e');
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
      final incomes = await getIncomesBySource(
        userId,
        source,
        startDate: startDate,
        endDate: endDate,
      );

      return incomes.fold<double>(0.0, (sum, income) => sum + income.amount);
    } catch (e) {
      throw Exception('Errore nel calcolo totale per fonte: $e');
    }
  }

  // QUERY SPECIFICHE (ESISTENTI - mantenute invariate)

  /// Ottieni entrate del mese corrente
  Future<List<IncomeModel>> getCurrentMonthIncomes(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getUserIncomes(
      userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Ottieni entrate della settimana corrente
  Future<List<IncomeModel>> getCurrentWeekIncomes(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return getUserIncomes(
      userId,
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  /// Ottieni entrate ricorrenti attive
  Future<List<IncomeModel>> getActiveRecurringIncomes(String userId) async {
    try {
      final recurringIncomes = await getUserIncomes(userId, isRecurring: true);

      // Filtra solo quelle ancora attive
      return recurringIncomes.where((income) => !income.isExpired).toList();
    } catch (e) {
      throw Exception('Errore nel recupero delle entrate ricorrenti: $e');
    }
  }

  /// Ottieni entrate per categoria
  Future<List<IncomeModel>> getIncomesByCategory(String userId, String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return getUserIncomes(
      userId,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // STATISTICHE

  /// Ottieni totale entrate per un periodo
  Future<double> getTotalIncomeForPeriod(String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final incomes = await getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      return incomes.fold<double>(0.0, (sum, income) => sum + income.amount);
    } catch (e) {
      throw Exception('Errore nel calcolo del totale: $e');
    }
  }

  /// Ottieni statistiche per categoria
  Future<Map<String, double>> getIncomeStatsByCategory(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final incomes = await getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<String, double> stats = {};

      return stats;
    } catch (e) {
      throw Exception('Errore nel calcolo statistiche per categoria: $e');
    }
  }

  /// Ottieni media mensile delle entrate
  Future<double> getMonthlyIncomeAverage(String userId, {int monthsCount = 12}) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - monthsCount, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final total = await getTotalIncomeForPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      return total / monthsCount;
    } catch (e) {
      throw Exception('Errore nel calcolo della media mensile: $e');
    }
  }

  // RICORRENZE

  /// Genera le prossime istanze delle entrate ricorrenti
  Future<List<IncomeModel>> generateRecurringIncomes(String userId) async {
    try {
      final activeRecurring = await getActiveRecurringIncomes(userId);
      final List<IncomeModel> newIncomes = [];

      for (final recurringIncome in activeRecurring) {
        final nextDate = recurringIncome.nextOccurrence;

        if (nextDate != null && nextDate.isBefore(DateTime.now().add(const Duration(days: 30)))) {
          // Crea nuova istanza
          final newIncome = await createIncome(
            userId: userId,
            amount: recurringIncome.amount,
            description: recurringIncome.description,
            incomeDate: nextDate,
            source: recurringIncome.source, // ⬅️ Preserva source
            isRecurring: false, // La nuova istanza non è ricorrente
          );

          newIncomes.add(newIncome);
        }
      }

      return newIncomes;
    } catch (e) {
      throw Exception('Errore nella generazione entrate ricorrenti: $e');
    }
  }

  // DUPLICAZIONE

  /// Duplica un'entrata esistente
  Future<IncomeModel> duplicateIncome(
      String userId,
      String incomeId, {
        DateTime? newDate,
        double? newAmount,
      }) async {
    try {
      final originalIncome = await getIncomeById(userId, incomeId);
      if (originalIncome == null) {
        throw Exception('Entrata originale non trovata');
      }

      return await createIncome(
        userId: userId,
        amount: newAmount ?? originalIncome.amount,
        description: originalIncome.description,
        incomeDate: newDate ?? DateTime.now(),
        source: originalIncome.source, // ⬅️ Preserva source
        isRecurring: false,
      );
    } catch (e) {
      throw Exception('Errore nella duplicazione dell\'entrata: $e');
    }
  }

  // STREAMS

  /// Stream delle entrate dell'utente
  Stream<List<IncomeModel>> getUserIncomesStream(
      String userId, {
        int? limit,
        DateTime? startDate,
        DateTime? endDate,
      }) {
    Query query = _getUserIncomesRef(userId);

    if (startDate != null) {
      query = query.where('income_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('income_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    query = query.orderBy('income_date', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => IncomeModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Stream delle entrate del mese corrente
  Stream<List<IncomeModel>> getCurrentMonthIncomesStream(String userId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getUserIncomesStream(userId, startDate: startOfMonth, endDate: endOfMonth);
  }

  // BATCH OPERATIONS

  /// Elimina tutte le entrate dell'utente (per cleanup)
  Future<void> deleteAllUserIncomes(String userId) async {
    try {
      final batch = _firestore.batch();
      final incomes = await _getUserIncomesRef(userId).get();

      for (final doc in incomes.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione di tutte le entrate: $e');
    }
  }

  /// Backup delle entrate dell'utente
  Future<List<Map<String, dynamic>>> exportUserIncomes(String userId) async {
    try {
      final incomes = await getUserIncomes(userId);
      return incomes.map((income) => income.toJson()).toList();
    } catch (e) {
      throw Exception('Errore nell\'export delle entrate: $e');
    }
  }
}