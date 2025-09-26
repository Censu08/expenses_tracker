import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'frontend/pages/auth_page.dart';
import 'frontend/layouts/main_layout.dart';
import 'frontend/themes/app_theme.dart';
import 'backend/blocs/blocs.dart';
import 'core/providers/bloc_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ExpensesTrackerApp());
}

class ExpensesTrackerApp extends StatelessWidget {
  const ExpensesTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvidersSetup(
      child: MaterialApp(
        title: 'Expenses Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            // Mostra loading durante il controllo dell'autenticazione
            if (state is UserInitial || state is UserLoading) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Caricamento...'),
                    ],
                  ),
                ),
              );
            }

            // Se l'utente è autenticato, mostra il layout principale
            if (state is UserAuthenticated) {
              return const AppHome();
            }

            // Altrimenti mostra la pagina di autenticazione
            return AuthPage();
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Widget home dell'applicazione che gestisce l'inizializzazione dei dati
class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      _hasInitialized = true;
      _initializeAppData();
    }
  }

  void _initializeAppData() {
    final userId = context.currentUserId;
    if (userId != null) {
      // Carica le categorie di default per entrate e spese
      context.categoryBloc.add(LoadAllUserCategoriesEvent(
        userId: userId,
        isIncome: true,
      ));

      // Carica le entrate del mese corrente
      context.incomeBloc.add(LoadCurrentMonthIncomesEvent(userId: userId));

      // Carica le spese del mese corrente
      context.expenseBloc.add(LoadCurrentMonthExpensesEvent(userId: userId));

      // Carica i dati della dashboard
      context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));

      // Avvia lo stream delle transazioni del mese corrente
      context.transactionBloc.add(StartCurrentMonthTransactionsStreamEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener per errori dell'utente
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),

        // Listener per operazioni sulle categorie
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CustomCategoryCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Categoria "${state.category.description}" creata con successo'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CustomCategoryDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categoria eliminata con successo'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is CategoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),

        // Listener per operazioni sulle entrate
        BlocListener<IncomeBloc, IncomeState>(
          listener: (context, state) {
            if (state is IncomeCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Entrata di ${state.income.formattedAmount} aggiunta'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Ricarica i dati della dashboard
              _refreshDashboardData();
            } else if (state is IncomeDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entrata eliminata con successo'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _refreshDashboardData();
            } else if (state is IncomeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),

        // Listener per operazioni sulle spese
        BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Spesa di ${state.expense.formattedAmount} aggiunta'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _refreshDashboardData();
            } else if (state is ExpenseDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spesa eliminata con successo'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _refreshDashboardData();
            } else if (state is ExpenseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),

        // Listener per operazioni sui trasferimenti
        BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransferCreated) {
              final transferAmount = state.transfer['transfer_amount'] as double;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trasferimento di €${transferAmount.toStringAsFixed(2)} completato'),
                  backgroundColor: Colors.purple,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _refreshDashboardData();
            } else if (state is AllUserDataExported) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dati esportati con successo'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is TransactionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: MainLayout(),
    );
  }

  void _refreshDashboardData() {
    final userId = context.currentUserId;
    if (userId != null) {
      // Ricarica i dati della dashboard dopo operazioni che modificano i dati
      context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));
      context.incomeBloc.add(LoadCurrentMonthIncomesEvent(userId: userId));
      context.expenseBloc.add(LoadCurrentMonthExpensesEvent(userId: userId));
    }
  }
}