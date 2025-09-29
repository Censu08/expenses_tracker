import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';  // ✅ AGGIUNGI QUESTO IMPORT
import 'core/cache/global_cache_manager.dart';
import 'firebase_options.dart';
import 'frontend/pages/auth_page.dart';
import 'frontend/layouts/main_layout.dart';
import 'frontend/pages/complete_birthdate_page.dart';
import 'frontend/themes/app_theme.dart';
import 'backend/blocs/blocs.dart';
import 'core/providers/bloc_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(const ExpensesTrackerApp());
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
        ],
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

            // Se l'utente richiede il completamento della data di nascita
            if (state is UserRequiresBirthdateState) {
              return CompleteBirthdatePage(user: state.user);
            }

            // Se l'utente è autenticato, mostra il layout principale
            if (state is UserAuthenticated) {
              return const AppHome();
            }

            // Altrimenti mostra la pagina di autenticazione
            return const AuthPage();
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
  late final _globalCache = GlobalCacheManager();

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
    if (userId == null) return;

    debugPrint('🚀 Inizializzazione app per utente: $userId');
    _globalCache.onUserChanged(userId);

    // 1. Carica solo le categorie (sempre necessarie)
    context.categoryBloc.add(LoadAllUserCategoriesEvent(
      userId: userId,
      isIncome: true,
    ));

    // 2. ✅ CARICA DATI DASHBOARD SOLO SE NECESSARIO
    // La dashboard stessa controllerà la cache e deciderà se caricare
    if (_globalCache.dashboard.shouldReloadData(userId)) {
      debugPrint('📥 [App] Richiesta caricamento iniziale dashboard');
      // NON caricare qui - lascia che la dashboard decida quando
      // context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));
      // context.transactionBloc.add(LoadFinancialAlertsEvent(userId: userId));
    } else {
      debugPrint('✅ [App] Dati dashboard già in cache');
    }

    // 3. ✅ Avvia lo stream SOLO UNA VOLTA per il mese corrente
    debugPrint('🔄 [App] Avvio stream transazioni mese corrente');
    context.transactionBloc.add(StartCurrentMonthTransactionsStreamEvent(userId: userId));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener per invalidare cache dopo operazioni su entrate
        BlocListener<IncomeBloc, IncomeState>(
          listener: (context, state) {
            if (state is IncomeCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Entrata di €${state.income.amount.toStringAsFixed(2)} creata'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _invalidateFinancialCachesAndReload();
            } else if (state is IncomeUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entrata aggiornata'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _invalidateFinancialCachesAndReload();
            } else if (state is IncomeDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entrata eliminata'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _invalidateFinancialCachesAndReload();
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

        // Listener per invalidare cache dopo operazioni su spese
        BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Spesa di €${state.expense.amount.toStringAsFixed(2)} creata'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _invalidateFinancialCachesAndReload();
            } else if (state is ExpenseUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spesa aggiornata'),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _invalidateFinancialCachesAndReload();
            } else if (state is ExpenseDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spesa eliminata'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              _invalidateFinancialCachesAndReload();
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
              _invalidateFinancialCachesAndReload();
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

  /// Invalida le cache finanziarie e ricarica i dati
  void _invalidateFinancialCachesAndReload() {
    final userId = context.currentUserId;
    if (userId == null) return;

    debugPrint('🔄 Operazione finanziaria completata - invalidazione cache');

    // Invalida tutte le cache correlate alle finanze
    _globalCache.invalidateFinancialCaches();

    // Ricarica i dati dashboard
    context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));
    context.transactionBloc.add(LoadFinancialAlertsEvent(userId: userId));
  }

  @override
  void dispose() {
    // Pulisci tutte le cache al logout
    _globalCache.clearAllCaches();
    super.dispose();
  }
}