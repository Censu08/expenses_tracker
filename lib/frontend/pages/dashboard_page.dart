import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/bloc_state_widgets.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/providers/bloc_providers.dart';
import '../../core/cache/cache.dart';
import '../../backend/blocs/blocs.dart';
import '../../backend/models/income_model.dart';
import '../../backend/models/expense_model.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final _cacheManager = GlobalCacheManager().dashboard;
  bool _hasInitialized = false;
  String? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasInitialized) {
      _hasInitialized = true;
      _userId = context.currentUserId;
      _initializeDashboard();
    }
  }

  void _initializeDashboard() {
    if (_userId == null) return;

    debugPrint('🎯 Inizializzazione dashboard per utente: $_userId');

    if (_cacheManager.shouldReloadData(_userId!)) {
      debugPrint('📥 Caricamento dati dal database...');
      _cacheManager.setLoading();
      _loadDashboardData();
    } else {
      debugPrint('✅ Utilizzo dati dalla cache');
      _cacheManager.setLoaded();
    }
  }

  void _loadDashboardData() {
    if (_userId == null) return;
    context.transactionBloc.add(LoadDashboardDataEvent(userId: _userId!));
    context.transactionBloc.add(LoadFinancialAlertsEvent(userId: _userId!));
  }

  Future<void> _refreshDashboardData() async {
    if (_userId == null) return;

    _cacheManager.setRefreshing();
    debugPrint('🔄 Refresh manuale dati dashboard');

    _cacheManager.invalidateCache();
    _loadDashboardData();

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (_userId == null) return;

            if (state is DashboardDataLoaded) {
              _cacheManager.updateDashboardData(state.dashboardData, userId: _userId!);
            } else if (state is FinancialAlertsLoaded) {
              _cacheManager.updateFinancialAlerts(state.alerts);
            } else if (state is CurrentMonthTransactionsStreamActive) {
              // ✅ Converti SEMPRE i model in Map per la cache
              final transactionsMap = state.transactions
                  .map((t) => _convertTransactionToMap(t))
                  .toList();
              _cacheManager.updateRecentTransactions(transactionsMap);
            } else if (state is TransactionError) {
              _cacheManager.setError(state.message);
            }
          },
        ),
      ],
      child: RefreshableWidget(
        onRefresh: _refreshDashboardData,
        child: _buildResponsiveBody(),
      ),
    );
  }

  /// ✅ Converte QUALSIASI formato in Map standardizzato e SERIALIZZABILE
  Map<String, dynamic> _convertTransactionToMap(dynamic transaction) {
    // Se è già una Map, verifica il formato
    if (transaction is Map<String, dynamic>) {
      // Se ha già 'type', assumiamo sia già nel formato corretto
      if (transaction.containsKey('type')) {
        return transaction;
      }
    }

    // Se è un IncomeModel
    if (transaction is IncomeModel) {
      return {
        'id': transaction.id,
        'type': 'income',
        'amount': transaction.amount,
        'description': transaction.description,
        'category': transaction.category.description, // ✅ Solo description (String)
        'category_id': transaction.category.id,        // ✅ ID separato
        'category_icon': transaction.category.id,      // ✅ Usa l'ID come identificatore icona
        'date': transaction.incomeDate,
        'is_recurring': transaction.isRecurring,
        'user_id': transaction.userId,
      };
    }

    // Se è un ExpenseModel
    if (transaction is ExpenseModel) {
      return {
        'id': transaction.id,
        'type': 'expense',
        'amount': transaction.amount,
        'description': transaction.description,
        'category': transaction.category.description, // ✅ Solo description (String)
        'category_id': transaction.category.id,        // ✅ ID separato
        'category_icon': transaction.category.id,      // ✅ Usa l'ID come identificatore icona
        'date': transaction.expenseDate,
        'is_recurring': transaction.isRecurring,
        'user_id': transaction.userId,
      };
    }

    // Fallback: prova a convertire comunque
    debugPrint('⚠️ Tipo di transazione sconosciuto: ${transaction.runtimeType}');
    return {
      'id': 'unknown',
      'type': 'expense',
      'amount': 0.0,
      'description': 'Transazione sconosciuta',
      'category': 'Altro',
      'category_icon': 'other',
      'date': DateTime.now(),
      'is_recurring': false,
    };
  }

  Widget _buildResponsiveBody() {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileLayout();
    } else if (ResponsiveUtils.isTablet(context)) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialAlerts(),
          _buildSummaryCard(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          QuickActionsGrid(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialAlerts(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildSummaryCard()),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(flex: 1, child: QuickActionsGrid()),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialAlerts(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryCard(),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        QuickActionsGrid(),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Transazioni Recenti'),
                      const SizedBox(height: 16),
                      Expanded(child: _buildRecentTransactions()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_cacheManager.hasCachedData && _cacheManager.cachedData != null) {
      return EnhancedExpenseSummaryCard(
        dashboardData: _cacheManager.cachedData!,
      );
    }

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is DashboardDataLoaded) {
          return EnhancedExpenseSummaryCard(
            dashboardData: state.dashboardData,
          );
        }

        if (_cacheManager.isLoading || state is TransactionLoading) {
          return _buildLoadingCard();
        }

        if (_cacheManager.hasError || state is TransactionError) {
          final errorMessage = _cacheManager.errorMessage ??
              (state is TransactionError ? state.message : 'Errore nel caricamento');
          return _buildErrorCard(errorMessage);
        }

        return _buildLoadingCard();
      },
    );
  }

  /// ✅ Widget transazioni con gestione corretta dei dati
  Widget _buildRecentTransactions() {
    // Usa sempre cache + BlocBuilder per avere dati real-time
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        List<Map<String, dynamic>> transactions = [];

        // Prendi dati dallo stato o dalla cache
        if (state is CurrentMonthTransactionsStreamActive) {
          transactions = state.transactions
              .map((t) => _convertTransactionToMap(t))
              .toList();
        } else if (_cacheManager.recentTransactions != null) {
          // ✅ Assicurati che le transazioni in cache siano in formato Map
          transactions = _cacheManager.recentTransactions!
              .map((t) => _convertTransactionToMap(t))
              .toList();
        }

        if (transactions.isEmpty) {
          return _buildEmptyTransactions();
        }

        // ✅ SingleChildScrollView per evitare overflow
        return SingleChildScrollView(
          child: EnhancedRecentTransactionsList(
            transactions: transactions,
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 40.0 : 60.0),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Caricamento dati...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Errore nel caricamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refreshDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nessuna transazione',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inizia aggiungendo la tua prima entrata o spesa',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showQuickAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Transazione'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.isMobile(context) ? 20 : 24,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshDashboardData,
          tooltip: 'Aggiorna dati',
        ),
      ],
    );
  }

  Widget _buildFinancialAlerts() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final alerts = (state is FinancialAlertsLoaded)
            ? state.alerts
            : _cacheManager.financialAlerts;

        if (alerts != null && alerts.isNotEmpty) {
          return Column(
            children: [
              _buildAlertsCard(alerts),
              SizedBox(height: ResponsiveUtils.getSpacing(context)),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAlertsCard(List<Map<String, dynamic>> alerts) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.warning_outlined, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  'Avvisi Finanziari',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...alerts.take(3).map((alert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getAlertIcon(alert['type']),
                    size: 16,
                    color: _getAlertColor(alert['severity']),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert['message'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getAlertColor(alert['severity']),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (alerts.length > 3)
              TextButton(
                onPressed: () => _showAllAlerts(alerts),
                child: Text('Vedi tutti (${alerts.length})'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'budget_exceeded':
      case 'budget_warning':
        return Icons.account_balance_wallet_outlined;
      case 'recurring_expense_due':
        return Icons.repeat;
      case 'unusual_expense':
        return Icons.trending_up;
      default:
        return Icons.info_outline;
    }
  }

  Color _getAlertColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showAllAlerts(List<Map<String, dynamic>> alerts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tutti gli Avvisi'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return ListTile(
                leading: Icon(
                  _getAlertIcon(alert['type']),
                  color: _getAlertColor(alert['severity']),
                ),
                title: Text(alert['message']),
                subtitle: Text('Livello: ${alert['severity']}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Transazione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Aggiungi Entrata'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add income page
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_down, color: Colors.red),
              title: const Text('Aggiungi Spesa'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to add expense page
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Widget per lista transazioni con gestione corretta formato dati
class EnhancedRecentTransactionsList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const EnhancedRecentTransactionsList({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transazioni del Mese',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
                Text(
                  '${transactions.length} totali',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ✅ ListView con shrinkWrap per evitare overflow
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionTile(context, transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, Map<String, dynamic> transaction) {
    final isMobile = ResponsiveUtils.isMobile(context);

    // ✅ Gestione sicura dei dati con fallback
    final type = transaction['type'] as String? ?? 'expense';
    final description = transaction['description'] as String? ?? 'Senza descrizione';
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;

    // ✅ Gestisci ENTRAMBI i formati di category
    String category;
    String categoryIcon;

    final categoryData = transaction['category'];
    if (categoryData is Map) {
      // Formato dal controller: category è un oggetto Map
      category = categoryData['description'] as String? ?? 'Altro';
      categoryIcon = categoryData['icon'] as String? ?? 'other';
    } else if (categoryData is String) {
      // Formato dal repository: category è già una String
      category = categoryData;
      categoryIcon = transaction['category_icon'] as String? ?? 'other';
    } else {
      // Fallback sicuro
      category = 'Altro';
      categoryIcon = 'other';
    }

    // Gestione data
    dynamic dateValue = transaction['date'];
    DateTime date;
    if (dateValue is DateTime) {
      date = dateValue;
    } else if (dateValue != null && dateValue.toString().isNotEmpty) {
      try {
        date = DateTime.parse(dateValue.toString());
      } catch (e) {
        date = DateTime.now();
      }
    } else {
      date = DateTime.now();
    }

    final isIncome = type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final icon = _getCategoryIcon(categoryIcon);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 8 : 12,
      ),
      leading: Container(
        width: isMobile ? 40 : 48,
        height: isMobile ? 40 : 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: isMobile ? 20 : 24),
      ),
      title: Text(
        description,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 14 : 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$category • ${_formatDate(date)}',
        style: TextStyle(
          fontSize: isMobile ? 11 : 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        '$sign€${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 16 : 18,
          color: color,
        ),
      ),
      onTap: () {
        // TODO: Mostra dettagli transazione
      },
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'shopping_cart': Icons.shopping_cart,
      'local_gas_station': Icons.local_gas_station,
      'restaurant': Icons.restaurant,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'directions_car': Icons.directions_car,
      'bolt': Icons.bolt,
      'movie': Icons.movie,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'work': Icons.work,
      'attach_money': Icons.attach_money,
      'business': Icons.business,
      'account_balance': Icons.account_balance,
      'trending_up': Icons.trending_up,
      'other': Icons.more_horiz,
    };
    return iconMap[iconName] ?? Icons.more_horiz;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Oggi ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (transactionDate == yesterday) {
      return 'Ieri ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(transactionDate).inDays < 7) {
      final weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
      return '${weekdays[date.weekday - 1]} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Enhanced version of ExpenseSummaryCard (invariata)
class EnhancedExpenseSummaryCard extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  const EnhancedExpenseSummaryCard({
    Key? key,
    required this.dashboardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryCards = dashboardData['summary_cards'] ?? {};
    final currentPeriod = dashboardData['current_period'] ?? {};
    final budgetStatus = currentPeriod['budget_status'];

    final totalIncome = (summaryCards['total_income_month'] as num?)?.toDouble() ?? 0.0;
    final totalExpense = (summaryCards['total_expense_month'] as num?)?.toDouble() ?? 0.0;
    final netBalance = (summaryCards['net_balance_month'] as num?)?.toDouble() ?? 0.0;
    final budgetPercentage = (summaryCards['budget_percentage'] as num?)?.toDouble() ?? 0.0;

    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Riepilogo Mensile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCurrentMonthYear(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            isMobile
                ? _buildMobileSummaryItems(context, totalIncome, totalExpense, netBalance)
                : _buildDesktopSummaryItems(context, totalIncome, totalExpense, netBalance),
            if (budgetStatus != null) ...[
              SizedBox(height: isMobile ? 12 : 16),
              _buildBudgetProgress(context, budgetPercentage, budgetStatus),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSummaryItems(BuildContext context, double income, double expense, double netBalance) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSummaryItem(context, 'Entrate', '€ ${income.toStringAsFixed(2)}', Icons.trending_up, Colors.green),
        const SizedBox(height: 12),
        _buildSummaryItem(context, 'Spese', '€ ${expense.toStringAsFixed(2)}', Icons.trending_down, Colors.red),
        const SizedBox(height: 12),
        _buildSummaryItem(context, 'Bilancio', '€ ${netBalance.toStringAsFixed(2)}',
            Icons.account_balance, netBalance >= 0 ? Colors.green : Colors.red),
      ],
    );
  }

  Widget _buildDesktopSummaryItems(BuildContext context, double income, double expense, double netBalance) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryItem(context, 'Entrate', '€ ${income.toStringAsFixed(2)}', Icons.trending_up, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildSummaryItem(context, 'Spese', '€ ${expense.toStringAsFixed(2)}', Icons.trending_down, Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        _buildSummaryItem(context, 'Bilancio Netto', '€ ${netBalance.toStringAsFixed(2)}',
            Icons.account_balance, netBalance >= 0 ? Colors.green : Colors.red),
      ],
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String amount, IconData icon, Color color) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 14 : 16),
              SizedBox(width: isMobile ? 3 : 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 3 : 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(BuildContext context, double percentage, Map<String, dynamic> budgetStatus) {
    final remaining = (budgetStatus['remaining'] as num?)?.toDouble() ?? 0.0;
    final budget = (budgetStatus['budget'] as num?)?.toDouble() ?? 0.0;
    final progress = (percentage / 100).clamp(0.0, 1.0);
    final isOverBudget = percentage > 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Mensile',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverBudget ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOverBudget ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isOverBudget
              ? 'Budget superato di €${(-remaining).toStringAsFixed(2)}'
              : 'Rimanente: €${remaining.toStringAsFixed(2)} di €${budget.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isOverBudget
                ? Colors.red
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    final months = [
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}