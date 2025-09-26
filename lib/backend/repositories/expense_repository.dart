import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/recurrence_model.dart';
import '../../core/utils/id_generator.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Riferimento alla subcollection delle spese dell'utente
  CollectionReference _getUserExpensesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses');
  }

  // OPERAZIONI CRUD

  /// Crea una nuova spesa
  Future<ExpenseModel> createExpense({
    required String userId,
    required double amount,
    required String description,
    required CategoryModel category,
    required DateTime expenseDate,
    bool isRecurring = false,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      final expenseId = IdGenerator.generateExpenseId();
      final now = DateTime.now();

      final expense = ExpenseModel(
        id: expenseId,
        amount: amount,
        description: description,
        category: category,
        createdAt: now,
        expenseDate: expenseDate,
        isRecurring: isRecurring,
        recurrenceSettings: recurrenceSettings,
        userId: userId,
      );

      await _getUserExpensesRef(userId)
          .doc(expenseId)
          .set(expense.toJson());

      return expense;
    } catch (e) {
      throw Exception('Errore nella creazione della spesa: $e');
    }
  }

  /// Ottieni una spesa per ID
  Future<ExpenseModel?> getExpenseById(String userId, String expenseId) async {
    try {
      final doc = await _getUserExpensesRef(userId)
          .doc(expenseId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return ExpenseModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nel recupero della spesa: $e');
    }
  }

  /// Ottieni tutte le spese dell'utente
  Future<List<ExpenseModel>> getUserExpenses(String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    bool? isRecurring,
    NecessityLevel? minNecessityLevel,
  }) async {
    try {
      Query query = _getUserExpensesRef(userId);

      // Filtro per data di inizio
      if (startDate != null) {
        query = query.where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      // Filtro per data di fine
      if (endDate != null) {
        query = query.where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
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
      query = query.orderBy('expense_date', descending: true);

      // Limite risultati
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<ExpenseModel> expenses = querySnapshot.docs
          .map((doc) => ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filtro per livello di necessità (fatto in memoria poiché Firestore ha limitazioni)
      if (minNecessityLevel != null) {
        expenses = expenses.where((expense) {
          if (!expense.isRecurring || expense.recurrenceSettings == null) return false;
          return expense.recurrenceSettings!.necessityLevel.priority >= minNecessityLevel.priority;
        }).toList();
      }

      return expenses;
    } catch (e) {
      throw Exception('Errore nel recupero delle spese: $e');
    }
  }

  /// Aggiorna una spesa esistente
  Future<ExpenseModel> updateExpense({
    required String userId,
    required String expenseId,
    double? amount,
    String? description,
    CategoryModel? category,
    DateTime? expenseDate,
    bool? isRecurring,
    RecurrenceSettings? recurrenceSettings,
  }) async {
    try {
      final existingExpense = await getExpenseById(userId, expenseId);
      if (existingExpense == null) {
        throw Exception('Spesa non trovata');
      }

      final updatedExpense = existingExpense.copyWith(
        amount: amount ?? existingExpense.amount,
        description: description ?? existingExpense.description,
        category: category ?? existingExpense.category,
        expenseDate: expenseDate ?? existingExpense.expenseDate,
        isRecurring: isRecurring ?? existingExpense.isRecurring,
        recurrenceSettings: recurrenceSettings ?? existingExpense.recurrenceSettings,
      );

      await _getUserExpensesRef(userId)
          .doc(expenseId)
          .update(updatedExpense.toJson());

      return updatedExpense;
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento della spesa: $e');
    }
  }

  /// Elimina una spesa
  Future<void> deleteExpense(String userId, String expenseId) async {
    try {
      final expense = await getExpenseById(userId, expenseId);
      if (expense == null) {
        throw Exception('Spesa non trovata');
      }

      await _getUserExpensesRef(userId)
          .doc(expenseId)
          .delete();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione della spesa: $e');
    }
  }

  // QUERY SPECIFICHE

  /// Ottieni spese del mese corrente
  Future<List<ExpenseModel>> getCurrentMonthExpenses(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getUserExpenses(
      userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Ottieni spese della settimana corrente
  Future<List<ExpenseModel>> getCurrentWeekExpenses(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return getUserExpenses(
      userId,
      startDate: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      endDate: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  /// Ottieni spese ricorrenti attive
  Future<List<ExpenseModel>> getActiveRecurringExpenses(String userId) async {
    try {
      final recurringExpenses = await getUserExpenses(userId, isRecurring: true);

      // Filtra solo quelle ancora attive
      return recurringExpenses.where((expense) => !expense.isExpired).toList();
    } catch (e) {
      throw Exception('Errore nel recupero delle spese ricorrenti: $e');
    }
  }

  /// Ottieni spese per categoria
  Future<List<ExpenseModel>> getExpensesByCategory(String userId, String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return getUserExpenses(
      userId,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Ottieni spese ad alta priorità
  Future<List<ExpenseModel>> getHighPriorityExpenses(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return getUserExpenses(
      userId,
      startDate: startDate,
      endDate: endDate,
      minNecessityLevel: NecessityLevel.high,
    );
  }

  /// Ottieni le spese più costose
  Future<List<ExpenseModel>> getTopExpensesByAmount(String userId, {
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await getUserExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      expenses.sort((a, b) => b.amount.compareTo(a.amount));
      return expenses.take(limit).toList();
    } catch (e) {
      throw Exception('Errore nel recupero delle spese più costose: $e');
    }
  }

  // STATISTICHE E ANALYTICS

  /// Calcola il totale delle spese per un periodo
  Future<double> getTotalExpenseForPeriod(String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final expenses = await getUserExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      return expenses.fold<double>(0.0, (total, expense) => total + expense.amount);
    } catch (e) {
      throw Exception('Errore nel calcolo del totale spese: $e');
    }
  }

  /// Ottieni statistiche spese per categoria
  Future<Map<String, double>> getExpenseStatsByCategory(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await getUserExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final stats = <String, double>{};

      for (final expense in expenses) {
        final categoryId = expense.category.id;
        stats[categoryId] = (stats[categoryId] ?? 0.0) + expense.amount;
      }

      return stats;
    } catch (e) {
      throw Exception('Errore nel calcolo statistiche per categoria: $e');
    }
  }

  /// Ottieni statistiche spese per livello di necessità
  Future<Map<NecessityLevel, double>> getExpenseStatsByNecessityLevel(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = await getUserExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
        isRecurring: true, // Solo spese ricorrenti hanno livello di necessità
      );

      final stats = <NecessityLevel, double>{};

      for (final expense in expenses) {
        if (expense.recurrenceSettings != null) {
          final level = expense.recurrenceSettings!.necessityLevel;
          stats[level] = (stats[level] ?? 0.0) + expense.amount;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('Errore nel calcolo statistiche per livello necessità: $e');
    }
  }

  /// Ottieni la media delle spese mensili
  Future<double> getMonthlyExpenseAverage(String userId, {int monthsCount = 12}) async {
    try {
      final endDate = DateTime.now();
      final startDate = DateTime(endDate.year, endDate.month - monthsCount, endDate.day);

      final totalExpense = await getTotalExpenseForPeriod(userId, startDate: startDate, endDate: endDate);

      return totalExpense / monthsCount;
    } catch (e) {
      throw Exception('Errore nel calcolo della media mensile: $e');
    }
  }

  /// Calcola il budget rimanente per il mese corrente
  Future<Map<String, double>> getCurrentMonthBudgetStatus(String userId, double monthlyBudget) async {
    try {
      final totalSpent = await getTotalExpenseForPeriod(
        userId,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        endDate: DateTime.now(),
      );

      final remaining = monthlyBudget - totalSpent;
      final percentage = monthlyBudget > 0 ? (totalSpent / monthlyBudget) * 100 : 0;

      return {
        'budget': monthlyBudget,
        'spent': totalSpent,
        'remaining': remaining,
        'percentage': percentage.toDouble(),
      };
    } catch (e) {
      throw Exception('Errore nel calcolo stato budget: $e');
    }
  }

  // GESTIONE RICORRENZE

  /// Genera le prossime spese ricorrenti
  Future<List<ExpenseModel>> generateRecurringExpenses(String userId) async {
    try {
      final recurringExpenses = await getActiveRecurringExpenses(userId);
      final newExpenses = <ExpenseModel>[];

      for (final expense in recurringExpenses) {
        final nextExpense = expense.createNextRecurrence();
        if (nextExpense != null) {
          // Verifica se esiste già una spesa per quella data
          final existingExpense = await _checkIfRecurrenceExists(userId, expense.id, nextExpense.expenseDate);

          if (!existingExpense) {
            await _getUserExpensesRef(userId)
                .doc(nextExpense.id)
                .set(nextExpense.toJson());
            newExpenses.add(nextExpense);
          }
        }
      }

      return newExpenses;
    } catch (e) {
      throw Exception('Errore nella generazione spese ricorrenti: $e');
    }
  }

  /// Verifica se esiste già una spesa ricorrente per una data specifica
  Future<bool> _checkIfRecurrenceExists(String userId, String originalExpenseId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final query = await _getUserExpensesRef(userId)
          .where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('is_recurring', isEqualTo: true)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // STREAM E REAL-TIME UPDATES

  /// Stream delle spese dell'utente
  Stream<List<ExpenseModel>> getUserExpensesStream(String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _getUserExpensesRef(userId);

    if (startDate != null) {
      query = query.where('expense_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('expense_date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    query = query.orderBy('expense_date', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => ExpenseModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Stream delle spese del mese corrente
  Stream<List<ExpenseModel>> getCurrentMonthExpensesStream(String userId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getUserExpensesStream(userId, startDate: startOfMonth, endDate: endOfMonth);
  }

  // BATCH OPERATIONS

  /// Elimina tutte le spese dell'utente (per cleanup)
  Future<void> deleteAllUserExpenses(String userId) async {
    try {
      final batch = _firestore.batch();
      final expenses = await _getUserExpensesRef(userId).get();

      for (final doc in expenses.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione di tutte le spese: $e');
    }
  }

  /// Backup delle spese dell'utente
  Future<List<Map<String, dynamic>>> exportUserExpenses(String userId) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses.map((expense) => expense.toJson()).toList();
    } catch (e) {
      throw Exception('Errore nell\'export delle spese: $e');
    }
  }

  /// Batch update per aggiornare categoria su più spese
  Future<void> updateCategoryOnMultipleExpenses(
      String userId,
      String oldCategoryId,
      CategoryModel newCategory,
      ) async {
    try {
      final batch = _firestore.batch();
      final expenses = await getExpensesByCategory(userId, oldCategoryId);

      for (final expense in expenses) {
        final updatedExpense = expense.copyWith(category: newCategory);
        batch.update(
          _getUserExpensesRef(userId).doc(expense.id),
          updatedExpense.toJson(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento batch categorie: $e');
    }
  }
}