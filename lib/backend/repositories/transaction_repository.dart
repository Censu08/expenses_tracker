import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import 'income_repository.dart';
import 'expense_repository.dart';
import 'category_repository.dart';

/// Repository per operazioni combinate che coinvolgono più entity
class TransactionRepository {
  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;
  final FirebaseFirestore _firestore;

  TransactionRepository({
    IncomeRepository? incomeRepository,
    ExpenseRepository? expenseRepository,
    CategoryRepository? categoryRepository,
    FirebaseFirestore? firestore,
  }) : _incomeRepository = incomeRepository ?? IncomeRepository(),
        _expenseRepository = expenseRepository ?? ExpenseRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  // OPERAZIONI COMBINATE ENTRATE/SPESE

  /// Ottieni tutte le transazioni (entrate + spese) per un periodo
  Future<List<dynamic>> getAllTransactions(String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final incomes = await _incomeRepository.getUserIncomes(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final expenses = await _expenseRepository.getUserExpenses(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Combina e ordina per data
      final allTransactions = <dynamic>[...incomes, ...expenses];
      allTransactions.sort((a, b) {
        final dateA = a is IncomeModel ? a.incomeDate : (a as ExpenseModel).expenseDate;
        final dateB = b is IncomeModel ? b.incomeDate : (b as ExpenseModel).expenseDate;
        return dateB.compareTo(dateA); // Più recenti prima
      });

      if (limit != null && allTransactions.length > limit) {
        return allTransactions.take(limit).toList();
      }

      return allTransactions;
    } catch (e) {
      throw Exception('Errore nel recupero di tutte le transazioni: $e');
    }
  }

  /// Ottieni il bilancio netto per un periodo (entrate - spese)
  Future<Map<String, double>> getNetBalanceForPeriod(String userId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final totalIncomes = await _incomeRepository.getTotalIncomeForPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final totalExpenses = await _expenseRepository.getTotalExpenseForPeriod(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final netBalance = totalIncomes - totalExpenses;

      return {
        'incomes': totalIncomes,
        'expenses': totalExpenses,
        'net_balance': netBalance,
      };
    } catch (e) {
      throw Exception('Errore nel calcolo bilancio netto: $e');
    }
  }

  /// Ottieni statistiche complete per categoria
  Future<Map<String, Map<String, double>>> getCategoryStatsComplete(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final incomeStats = await _incomeRepository.getIncomeStatsByCategory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final expenseStats = await _expenseRepository.getExpenseStatsByCategory(
        userId,
        startDate: startDate,
        endDate: endDate,
      );

      final combinedStats = <String, Map<String, double>>{};

      // Aggiungi statistiche entrate
      for (final entry in incomeStats.entries) {
        combinedStats[entry.key] = {
          'incomes': entry.value,
          'expenses': expenseStats[entry.key] ?? 0.0,
        };
      }

      // Aggiungi categorie che hanno solo spese
      for (final entry in expenseStats.entries) {
        if (!combinedStats.containsKey(entry.key)) {
          combinedStats[entry.key] = {
            'incomes': 0.0,
            'expenses': entry.value,
          };
        } else {
          combinedStats[entry.key]!['expenses'] = entry.value;
        }
      }

      // Calcola il netto per ogni categoria
      for (final entry in combinedStats.entries) {
        final incomes = entry.value['incomes'] ?? 0.0;
        final expenses = entry.value['expenses'] ?? 0.0;
        entry.value['net'] = incomes - expenses;
      }

      return combinedStats;
    } catch (e) {
      throw Exception('Errore nel calcolo statistiche complete per categoria: $e');
    }
  }

  /// Ottieni un riepilogo finanziario completo del mese corrente
  Future<Map<String, dynamic>> getCurrentMonthSummary(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final balanceData = await getNetBalanceForPeriod(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final categoryStats = await getCategoryStatsComplete(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final recentTransactions = await getAllTransactions(
        userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
        limit: 10,
      );

      return {
        'period': {
          'start': startOfMonth,
          'end': endOfMonth,
          'month': now.month,
          'year': now.year,
        },
        'balance': balanceData,
        'category_stats': categoryStats,
        'recent_transactions': recentTransactions.map((t) => {
          'id': t is IncomeModel ? t.id : (t as ExpenseModel).id,
          'type': t is IncomeModel ? 'income' : 'expense',
          'amount': t is IncomeModel ? t.amount : (t as ExpenseModel).amount,
          'description': t is IncomeModel ? t.description : (t as ExpenseModel).description,
          'category': t is IncomeModel ? t.category.description : (t as ExpenseModel).category.description,
          'date': t is IncomeModel ? t.incomeDate : (t as ExpenseModel).expenseDate,
        }).toList(),
      };
    } catch (e) {
      throw Exception('Errore nel recupero riepilogo mensile: $e');
    }
  }

  // OPERAZIONI BATCH E TRANSAZIONI ATOMICHE

  /// Trasferisci denaro (crea entrata e spesa contemporaneamente)
  Future<Map<String, dynamic>> createTransfer({
    required String userId,
    required double amount,
    required String description,
    required CategoryModel fromCategory, // Categoria spesa
    required CategoryModel toCategory,   // Categoria entrata
    required DateTime date,
  }) async {
    try {
      final batch = _firestore.batch();

      // Crea la spesa
      final expense = await _expenseRepository.createExpense(
        userId: userId,
        amount: amount,
        description: 'Trasferimento: $description',
        category: fromCategory,
        expenseDate: date,
      );

      // Crea l'entrata
      final income = await _incomeRepository.createIncome(
        userId: userId,
        amount: amount,
        description: 'Trasferimento: $description',
        category: toCategory,
        incomeDate: date,
      );

      return {
        'expense': expense,
        'income': income,
        'transfer_amount': amount,
        'date': date,
      };
    } catch (e) {
      throw Exception('Errore nella creazione trasferimento: $e');
    }
  }

  /// Elimina tutti i dati finanziari dell'utente
  Future<void> deleteAllUserFinancialData(String userId) async {
    try {
      final batch = _firestore.batch();

      // Elimina tutte le entrate
      final incomesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('incomes');
      final incomeDocs = await incomesRef.get();
      for (final doc in incomeDocs.docs) {
        batch.delete(doc.reference);
      }

      // Elimina tutte le spese
      final expensesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses');
      final expenseDocs = await expensesRef.get();
      for (final doc in expenseDocs.docs) {
        batch.delete(doc.reference);
      }

      // Elimina tutte le categorie custom
      final categoriesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('customCategories');
      final categoryDocs = await categoriesRef.get();
      for (final doc in categoryDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione dati finanziari: $e');
    }
  }

  /// Export completo dati utente
  Future<Map<String, dynamic>> exportAllUserData(String userId) async {
    try {
      final incomes = await _incomeRepository.exportUserIncomes(userId);
      final expenses = await _expenseRepository.exportUserExpenses(userId);
      final customCategories = await _categoryRepository.getUserCustomCategories(userId);

      return {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': userId,
        'data': {
          'incomes': incomes,
          'expenses': expenses,
          'custom_categories': customCategories.map((c) => c.toJson()).toList(),
        },
        'summary': {
          'total_incomes': incomes.length,
          'total_expenses': expenses.length,
          'total_custom_categories': customCategories.length,
        },
      };
    } catch (e) {
      throw Exception('Errore nell\'export completo dati: $e');
    }
  }

  // STREAM COMBINATI

  /// Stream di tutte le transazioni del mese corrente
  Stream<List<dynamic>> getCurrentMonthTransactionsStream(String userId) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Combina i due stream
    return _combineTransactionStreams(
      _incomeRepository.getUserIncomesStream(userId, startDate: startOfMonth, endDate: endOfMonth),
      _expenseRepository.getUserExpensesStream(userId, startDate: startOfMonth, endDate: endOfMonth),
    );
  }

  /// Helper per combinare stream di entrate e spese
  Stream<List<dynamic>> _combineTransactionStreams(
      Stream<List<IncomeModel>> incomesStream,
      Stream<List<ExpenseModel>> expensesStream,
      ) async* {
    await for (final incomes in incomesStream) {
      await for (final expenses in expensesStream) {
        final allTransactions = <dynamic>[...incomes, ...expenses];
        allTransactions.sort((a, b) {
          final dateA = a is IncomeModel ? a.incomeDate : (a as ExpenseModel).expenseDate;
          final dateB = b is IncomeModel ? b.incomeDate : (b as ExpenseModel).expenseDate;
          return dateB.compareTo(dateA);
        });
        yield allTransactions;
        break; // Evita loop infinito
      }
    }
  }
}