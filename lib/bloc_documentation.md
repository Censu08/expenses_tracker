# 📊 Expenses Tracker - Sistema BLoC Completo

## 🏗️ Architettura del Sistema

Il progetto implementa un'architettura a 3 livelli seguendo il pattern **BLoC (Business Logic Component)**:

```
UI Layer (Widgets) 
    ↕️
BLoC Layer (State Management)
    ↕️  
Controller Layer (Business Logic)
    ↕️
Repository Layer (Data Access)
    ↕️
Firebase Firestore (Database)
```

## 📁 Struttura del Progetto

```
lib/
├── backend/
│   ├── models/                 # Modelli dati
│   │   ├── user_model.dart
│   │   ├── category_model.dart
│   │   ├── income_model.dart
│   │   ├── expense_model.dart
│   │   ├── recurrence_model.dart
│   │   └── models.dart
│   │
│   ├── repositories/           # Accesso ai dati
│   │   ├── user_repository.dart
│   │   ├── category_repository.dart
│   │   ├── income_repository.dart
│   │   ├── expense_repository.dart
│   │   ├── transaction_repository.dart
│   │   ├── repository_constants.dart
│   │   └── repositories.dart
│   │
│   ├── controllers/            # Logica di business
│   │   ├── user_controller.dart
│   │   ├── category_controller.dart
│   │   ├── income_controller.dart
│   │   ├── expense_controller.dart
│   │   ├── transaction_controller.dart
│   │   └── controllers.dart
│   │
│   └── blocs/                  # State Management
│       ├── user_bloc.dart
│       ├── category_bloc.dart
│       ├── income_bloc.dart
│       ├── expense_bloc.dart
│       ├── transaction_bloc.dart
│       └── blocs.dart
│
├── frontend/
│   ├── widgets/
│   │   ├── bloc_state_widgets.dart
│   │   └── ...
│   └── pages/
│       ├── dashboard_page.dart
│       └── ...
│
└── core/
    ├── providers/
    │   └── bloc_providers.dart
    ├── utils/
    │   └── id_generator.dart
    └── errors/
        └── app_exceptions.dart
```

## 🗄️ Struttura Database Firebase

```
users/{userId}                          # Documento utente
├── incomes/{incomeId}                  # Subcollection entrate
├── expenses/{expenseId}                # Subcollection spese  
└── customCategories/{categoryId}       # Subcollection categorie custom
```

## 🔧 BLoC Implementati

### 1. **CategoryBloc** - Gestione Categorie
```dart
// Eventi principali
LoadDefaultCategoriesEvent(isIncome: true)
LoadAllUserCategoriesEvent(userId: userId, isIncome: true)
CreateCustomCategoryEvent(userId: userId, description: "Nome", icon: Icons.star, color: Colors.blue)
UpdateCustomCategoryEvent(userId: userId, categoryId: categoryId)
DeleteCustomCategoryEvent(userId: userId, categoryId: categoryId)

// Stati principali  
DefaultCategoriesLoaded(categories: [])
AllUserCategoriesLoaded(categories: [])
CustomCategoryCreated(category: CategoryModel)
CategoryError(message: "Errore")
```

### 2. **IncomeBloc** - Gestione Entrate
```dart
// Eventi principali
CreateIncomeEvent(userId: userId, amount: 100.0, description: "Stipendio", categoryId: "salary", incomeDate: DateTime.now())
LoadUserIncomesEvent(userId: userId)
LoadCurrentMonthIncomesEvent(userId: userId)
UpdateIncomeEvent(userId: userId, incomeId: incomeId)
DeleteIncomeEvent(userId: userId, incomeId: incomeId)

// Stati principali
UserIncomesLoaded(incomes: [])
CurrentMonthIncomesLoaded(incomes: [])
IncomeCreated(income: IncomeModel)
IncomeError(message: "Errore")
```

### 3. **ExpenseBloc** - Gestione Spese
```dart
// Eventi principali
CreateExpenseEvent(userId: userId, amount: 50.0, description: "Spesa supermercato", categoryId: "groceries", expenseDate: DateTime.now())
LoadUserExpensesEvent(userId: userId)
LoadCurrentMonthExpensesEvent(userId: userId)
LoadCurrentMonthBudgetStatusEvent(userId: userId, monthlyBudget: 1000.0)
CheckBudgetExceededEvent(userId: userId, monthlyBudget: 1000.0)

// Stati principali
UserExpensesLoaded(expenses: [])
CurrentMonthExpensesLoaded(expenses: [])
ExpenseCreated(expense: ExpenseModel) 
CurrentMonthBudgetStatusLoaded(budgetStatus: {})
BudgetExceededChecked(isExceeded: true)
```

### 4. **TransactionBloc** - Operazioni Combinate
```dart
// Eventi principali
LoadDashboardDataEvent(userId: userId, monthlyBudget: 1000.0)
LoadAllTransactionsEvent(userId: userId)
LoadNetBalanceForPeriodEvent(userId: userId, startDate: start, endDate: end)
LoadFinancialAlertsEvent(userId: userId, monthlyBudget: 1000.0)
CreateTransferEvent(userId: userId, amount: 100.0, description: "Trasferimento", fromCategoryId: "cash", toCategoryId: "bank")

// Stati principali
DashboardDataLoaded(dashboardData: {})
AllTransactionsLoaded(transactions: [])
NetBalanceForPeriodLoaded(balance: {"incomes": 1000, "expenses": 600, "net_balance": 400})
FinancialAlertsLoaded(alerts: [])
TransferCreated(transfer: {})
```

## 🚀 Utilizzo dei BLoC

### Setup nell'App
```dart
// main.dart
class ExpensesTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvidersSetup(  // 👈 Setup automatico di tutti i BLoC
      child: MaterialApp(
        home: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserAuthenticated) {
              return const AppHome();
            }
            return AuthPage();
          },
        ),
      ),
    );
  }
}
```

### Utilizzo nei Widget
```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is DashboardDataLoaded) {
          return DashboardContent(data: state.dashboardData);
        }
        return const LoadingWidget();
      },
    );
  }
  
  void _loadData() {
    final userId = context.currentUserId;  // 👈 Extension helper
    context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));
  }
}
```

### Widget di Utilità
```dart
// Widget per gestire stati comuni
TransactionStateWidget(
  builder: (context, transactions) => TransactionsList(transactions),
  emptyTitle: "Nessuna transazione",
  emptyAction: ElevatedButton(onPressed: () => _addTransaction(), child: Text("Aggiungi")),
)

// Widget per loading overlay
LoadingOverlay(
  isLoading: context.isAnyBlocLoading,  // 👈 Extension helper
  child: YourContent(),
)

// Widget per refresh
RefreshableWidget(
  onRefresh: () async => _loadData(),
  child: YourScrollableContent(),
)
```

## 💡 Esempi Pratici

### 1. Aggiungere una Nuova Entrata
```dart
void addIncome() {
  final userId = context.currentUserId!;
  
  context.incomeBloc.add(CreateIncomeEvent(
    userId: userId,
    amount: 2500.0,
    description: "Stipendio Dicembre",
    categoryId: "salary",
    incomeDate: DateTime.now(),
    isRecurring: true,
    recurrenceSettings: RecurrenceSettings(
      type: RecurrenceType.monthly,
      startDate: DateTime.now(),
      necessityLevel: NecessityLevel.high,
    ),
  ));
}
```

### 2. Verificare il Budget
```dart
void checkBudget() {
  final userId = context.currentUserId!;
  
  context.expenseBloc.add(LoadCurrentMonthBudgetStatusEvent(
    userId: userId,
    monthlyBudget: 1000.0,
  ));
}

// Nei listener
BlocListener<ExpenseBloc, ExpenseState>(
  listener: (context, state) {
    if (state is CurrentMonthBudgetStatusLoaded) {
      final percentage = state.budgetStatus['percentage'];
      if (percentage > 80) {
        showBudgetWarning();
      }
    }
  },
  child: YourWidget(),
)
```

### 3. Dashboard Real-time
```dart
@override
void initState() {
  super.initState();
  final userId = context.currentUserId!;
  
  // Carica dati dashboard
  context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));
  
  // Avvia stream transazioni real-time
  context.transactionBloc.add(StartCurrentMonthTransactionsStreamEvent(userId: userId));
  
  // Carica alert finanziari
  context.transactionBloc.add(LoadFinancialAlertsEvent(userId: userId, monthlyBudget: 1000.0));
}
```

## 🎯 Funzionalità Avanzate

### Ricorrenze Automatiche
- ✅ Spese/Entrate ricorrenti (giornaliere, settimanali, mensili, annuali, personalizzate)
- ✅ Generazione automatica delle prossime istanze
- ✅ Gestione date fine ricorrenza
- ✅ Livelli di necessità (bassa, media, alta, critica)

### Analytics e Statistiche
- ✅ Bilancio netto per periodo
- ✅ Statistiche per categoria
- ✅ Trend mensili
- ✅ Confronti tra periodi
- ✅ Previsioni finanziarie
- ✅ Medie mensili

### Budget Management
- ✅ Controllo budget mensile
- ✅ Alert per budget superato
- ✅ Suggerimenti budget ottimale
- ✅ Calcolo budget rimanente

### Alert System
- ✅ Budget superato/in esaurimento
- ✅ Spese ricorrenti in scadenza
- ✅ Transazioni anomale
- ✅ Notifiche real-time

## 🔐 Sicurezza Implementata

### Firestore Rules
- ✅ Isolamento completo dati per utente
- ✅ Validazione struttura documenti
- ✅ Controlli su importi e date
- ✅ Protezione subcollection

### Validazioni Controller
- ✅ Validazione input (importi, descrizioni, date)
- ✅ Controllo esistenza categorie
- ✅ Verifiche autorizzazioni utente
- ✅ Gestione errori robusta

## 📈 Performance

### Ottimizzazioni Implementate
- ✅ Query ottimizzate con indici Firestore
- ✅ Paginazione per liste lunghe
- ✅ Cache locale tramite BLoC state
- ✅ Stream real-time solo quando necessario
- ✅ Lazy loading componenti

### Stream Management
- ✅ Stream automatico per dashboard
- ✅ Controllo lifecycle stream
- ✅ Unsubscribe automatico
- ✅ Error handling stream

## 🚦 Prossimi Passi

### Phase 1: Core Implementation ✅
- [x] Modelli base
- [x] Repository layer
- [x] Controller layer
- [x] BLoC layer
- [x] Firestore rules
- [x] Widget utilities

### Phase 2: UI Integration 🔄
- [ ] Form per aggiungere entrate/spese
- [ ] Pagina gestione categorie
- [ ] Dettagli transazioni
- [ ] Impostazioni budget
- [ ] Grafici e charts

### Phase 3: Advanced Features 📋
- [ ] Export/Import dati
- [ ] Backup automatico
- [ ] Sincronizzazione multi-device
- [ ] Notifiche push
- [ ] Integrazione banche (PSD2)

## 🤝 Contributing

Per contribuire al progetto:
1. Segui l'architettura BLoC esistente
2. Implementa test per nuove funzionalità
3. Mantieni validazioni sui controller
4. Aggiorna Firestore rules se necessario
5. Documenta nuove API

## 📋 Checklist Integrazione

- [ ] Aggiorna `main.dart` con `BlocProvidersSetup`
- [ ] Aggiorna `pubspec.yaml` con nuove dependencies se necessarie
- [ ] Configura Firestore rules
- [ ] Testa autenticazione e flow principale
- [ ] Verifica performance query Firestore
- [ ] Implementa gestione errori
- [ ] Testa su diversi dispositivi/schermi

---

**🎉 Il sistema BLoC è completo e pronto per l'integrazione!**

Tutti i layer sono implementati con:
- ✅ State management robusto
- ✅ Gestione errori completa
- ✅ Real-time updates
- ✅ Validazioni security
- ✅ Performance ottimizzate
- ✅ Architettura scalabile