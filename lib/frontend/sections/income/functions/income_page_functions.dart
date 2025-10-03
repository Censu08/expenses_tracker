import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import '../../../../backend/blocs/category_bloc.dart';
import '../../../../backend/blocs/income_bloc.dart';
import '../../../../backend/models/income_model.dart';
import '../pages/income_page.dart';
import '../widgets/add_income_form.dart';
import '../widgets/income_details_dialog.dart';

class IncomePageFunctions {

  /// Carica i dati delle entrate
  static void loadIncomeData(BuildContext context, IncomePageState pageState) {
    final userId = context.currentUserId;

    if (userId == null) {
      debugPrint('❌ [IncomePage] userId is NULL! Cannot load incomes.');
      return;
    }

    debugPrint('🔍 [IncomePage] Loading data for userId: $userId');
    final (startDate, endDate) = getDateRangeForPeriod(pageState.selectedPeriod);
    debugPrint('🔍 [IncomePage] Date range: $startDate to $endDate');

    // Carica categorie entrate
    context.categoryBloc.add(LoadAllUserCategoriesEvent(
      userId: userId,
      isIncome: true,
    ));

    // Carica le entrate
    context.incomeBloc.add(LoadUserIncomesEvent(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    ));
  }

  /// Ottieni il range di date per il periodo selezionato
  static (DateTime?, DateTime?) getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Questa Settimana':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return (
        DateTime(weekStart.year, weekStart.month, weekStart.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59)
        );
      case 'Questo Mese':
        return (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
      case 'Ultimi 3 Mesi':
        return (
        DateTime(now.year, now.month - 3, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
      case 'Quest\'Anno':
        return (
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59)
        );
      case 'Tutto':
        return (null, null);
      default:
        return (
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59)
        );
    }
  }

  /// Calcola statistiche localmente
  static Map<String, double> calculateStats(List<IncomeModel> incomes) {
    final stats = <String, double>{};
    for (final income in incomes) {
      final categoryId = income.category.id;
      stats[categoryId] = (stats[categoryId] ?? 0.0) + income.amount;
    }
    return stats;
  }

  /// Formatta la data
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Mostra dialog per aggiungere entrata
  static void showAddIncomeDialog(BuildContext context, IncomePageState pageState) {
    showDialog(
      context: context,
      builder: (context) => AddIncomeForm(
        onIncomeAdded: () {
          Navigator.pop(context);
          loadIncomeData(context, pageState);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrata aggiunta con successo!')),
          );
        },
      ),
    );
  }

  /// Mostra dettagli entrata
  static void showIncomeDetails(
      BuildContext context,
      IncomePageState pageState,
      IncomeModel income,
      ) {
    showDialog(
      context: context,
      builder: (context) => IncomeDetailsDialog(
        income: income,
        onUpdated: () => loadIncomeData(context, pageState),
      ),
    );
  }

  /// Gestisce azioni su entrata (edit/delete)
  static void handleIncomeAction(
      BuildContext context,
      IncomePageState pageState,
      String action,
      IncomeModel income,
      ) {
    final userId = context.currentUserId;
    if (userId == null) return;

    switch (action) {
      case 'edit':
        showEditIncomeDialog(context, pageState, income);
        break;
      case 'delete':
        showDeleteConfirmation(context, pageState, income);
        break;
    }
  }

  /// Mostra dialog per modificare entrata
  static void showEditIncomeDialog(
      BuildContext context,
      IncomePageState pageState,
      IncomeModel income,
      ) {
    showDialog(
      context: context,
      builder: (context) => AddIncomeForm(
        initialIncome: income,
        onIncomeAdded: () {
          Navigator.pop(context);
          loadIncomeData(context, pageState);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrata modificata con successo!')),
          );
        },
      ),
    );
  }

  /// Mostra conferma eliminazione
  static void showDeleteConfirmation(
      BuildContext context,
      IncomePageState pageState,
      IncomeModel income,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Vuoi davvero eliminare l\'entrata "${income.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteIncome(context, pageState, income);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  /// Elimina entrata
  static void deleteIncome(
      BuildContext context,
      IncomePageState pageState,
      IncomeModel income,
      ) {
    final userId = context.currentUserId;
    if (userId == null) return;

    context.incomeBloc.add(DeleteIncomeEvent(
      userId: userId,
      incomeId: income.id,
    ));

    // Rimuovi dalla cache locale
    pageState.setState(() {
      pageState.cachedIncomes.removeWhere((i) => i.id == income.id);
      pageState.cachedStats = calculateStats(pageState.cachedIncomes);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrata eliminata')),
    );
  }
}