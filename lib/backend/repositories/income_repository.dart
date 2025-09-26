import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/income_model.dart';
import '../models/category_model.dart';
import '../models/recurrence_model.dart';
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
    required CategoryModel category,
    required DateTime incomeDate,
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
        category: category,
        createdAt: now,
        incomeDate: incomeDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
        userId: userId,
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
  }) async {
    try {
      final existingIncome = await getIncomeById(userId, incomeId);
      if (existingIncome == null) {
        throw Exception('Entrata non trovata');
      }

      final updatedIncome = existingIncome.copyWith(
        amount: amount ?? existingIncome.amount,
        description: description ?? existingIncome.description,
        category: category ?? existingIncome.category,
        incomeDate: incomeDate ?? existingIncome.incomeDate,
        isRecurring: isRecurring ?? existingIncome.isRecurring,
        recurrenceSettings: recurrenceSettings ?? existingIncome.recurrenceSettings,
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

  // QUERY SPECIFICHE

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

  // STATISTICHE E ANALYTICS

  /// Calcola il totale delle entrate per un periodo
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

      return incomes.fold<double>(0.0, (total, income) => total + income.amount);
    } catch (e) {
      throw Exception('Errore nel calcolo del totale entrate: $e');
    }
  }

  /// Ottieni statistiche entrate per categoria
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

      final stats = <String, double>{};

      for (final income in incomes) {
        final categoryId = income.category.id;
        stats[categoryId] = (stats[categoryId] ?? 0.0) + income.amount;
      }

      return stats;
    } catch (e) {
      throw Exception('Errore nel calcolo statistiche per categoria: $e');
    }
  }

  /// Ottieni la media delle entrate mensili
  Future<double> getMonthlyIncomeAverage(String userId, {int monthsCount = 12}) async {
    try {
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - monthsCount, endDate.day);

      final totalIncome = await getTotalIncomeForPeriod(userId, startDate: startDate, endDate: endDate);

      return totalIncome / monthsCount;
    } catch (e) {
      throw Exception('Errore nel calcolo della media mensile: $e');
    }
  }

  // GESTIONE RICORRENZE

  /// Genera le prossime entrate ricorrenti
  Future<List<IncomeModel>> generateRecurringIncomes(String userId) async {
    try {
      final recurringIncomes = await getActiveRecurringIncomes(userId);
      final newIncomes = <IncomeModel>[];

      for (final income in recurringIncomes) {
        final nextIncome = income.createNextRecurrence();
        if (nextIncome != null) {
          // Verifica se esiste già un'entrata per quella data
          final existingIncome = await _checkIfRecurrenceExists(userId, income.id, nextIncome.incomeDate);

          if (!existingIncome) {
            await _getUserIncomesRef(userId)
                .doc(nextIncome.id)
                .set(nextIncome.toJson());
            newIncomes.add(nextIncome);
          }
        }
      }

      return newIncomes;
    } catch (e) {
      throw Exception('Errore nella generazione entrate ricorrenti: $e');
    }
  }

  /// Verifica se esiste già un'entrata ricorrente per una data specifica
  Future<bool> _checkIfRecurrenceExists(String userId, String originalIncomeId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final query = await _getUserIncomesRef(userId)
          .where('income_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('income_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('is_recurring', isEqualTo: true)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // STREAM E REAL-TIME UPDATES

  /// Stream delle entrate dell'utente
  Stream<List<IncomeModel>> getUserIncomesStream(String userId, {
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