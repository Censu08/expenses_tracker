import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/bloc_state_widgets.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/quick_actions_grid.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/providers/bloc_providers.dart';
import '../../backend/blocs/blocs.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Accedi al Provider qui invece che in initState()
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadDashboardData();
    }
  }

  void _loadDashboardData() {
    final userId = context.currentUserId;
    if (userId != null) {
      // Carica i dati della dashboard
      context.transactionBloc.add(LoadDashboardDataEvent(userId: userId));

      // Carica gli alert finanziari
      context.transactionBloc.add(LoadFinancialAlertsEvent(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableWidget(
      onRefresh: () async {
        _loadDashboardData();
        // Aggiungi un piccolo delay per mostrare il refresh indicator
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: _buildResponsiveBody(),
    );
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
          // Alert finanziari se presenti
          _buildFinancialAlerts(),

          // Riepilogo spese aggiornato con dati reali
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is DashboardDataLoaded) {
                return EnhancedExpenseSummaryCard(
                  dashboardData: state.dashboardData,
                );
              }
              return ExpenseSummaryCard(); // Fallback al widget esistente
            },
          ),

          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          // Azioni rapide
          QuickActionsGrid(),

          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),

          // Lista transazioni aggiornata con dati reali
          TransactionStateWidget(
            builder: (context, transactions) => EnhancedRecentTransactionsList(
              transactions: transactions,
            ),
            emptyTitle: 'Nessuna transazione',
            emptyMessage: 'Aggiungi la tua prima entrata o spesa per iniziare!',
            emptyAction: ElevatedButton.icon(
              onPressed: () => _showQuickAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Transazione'),
            ),
          ),
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
          // Alert finanziari
          _buildFinancialAlerts(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state is DashboardDataLoaded) {
                      return EnhancedExpenseSummaryCard(
                        dashboardData: state.dashboardData,
                      );
                    }
                    return ExpenseSummaryCard();
                  },
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: 1,
                child: QuickActionsGrid(),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getSpacing(context)),

          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),

          TransactionStateWidget(
            builder: (context, transactions) => EnhancedRecentTransactionsList(
              transactions: transactions,
            ),
          ),
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
          // Alert finanziari
          _buildFinancialAlerts(),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonna sinistra - Riepilogo e Azioni Rapide
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BlocBuilder<TransactionBloc, TransactionState>(
                          builder: (context, state) {
                            if (state is DashboardDataLoaded) {
                              return EnhancedExpenseSummaryCard(
                                dashboardData: state.dashboardData,
                              );
                            }
                            return ExpenseSummaryCard();
                          },
                        ),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        QuickActionsGrid(),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: ResponsiveUtils.getSpacing(context)),

                // Colonna destra - Transazioni Recenti
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Transazioni Recenti'),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TransactionStateWidget(
                          builder: (context, transactions) => SingleChildScrollView(
                            child: EnhancedRecentTransactionsList(
                              transactions: transactions,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: ResponsiveUtils.isMobile(context) ? 20 : 24,
      ),
    );
  }

  Widget _buildFinancialAlerts() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is FinancialAlertsLoaded && state.alerts.isNotEmpty) {
          return Column(
            children: [
              _buildAlertsCard(state.alerts),
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
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: Theme.of(context).colorScheme.error,
                ),
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

/// Enhanced version of ExpenseSummaryCard that uses real data
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
    final monthlyBalance = currentPeriod['monthly_balance'] ?? {};
    final budgetStatus = currentPeriod['budget_status'];

    final totalIncome = summaryCards['total_income_month']?.toDouble() ?? 0.0;
    final totalExpense = summaryCards['total_expense_month']?.toDouble() ?? 0.0;
    final netBalance = summaryCards['net_balance_month']?.toDouble() ?? 0.0;
    final budgetPercentage = summaryCards['budget_percentage']?.toDouble() ?? 0.0;

    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    final remaining = budgetStatus['remaining']?.toDouble() ?? 0.0;
    final spent = budgetStatus['spent']?.toDouble() ?? 0.0;
    final budget = budgetStatus['budget']?.toDouble() ?? 0.0;

    final progress = (percentage / 100).clamp(0.0, 1.0);
    final isOverBudget = percentage > 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

/// Enhanced version of RecentTransactionsList that uses real data
class EnhancedRecentTransactionsList extends StatelessWidget {
  final List<dynamic> transactions;

  const EnhancedRecentTransactionsList({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ultime Transazioni',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all transactions page
                  },
                  child: Text(
                    'Vedi Tutte',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildTransactionTile(BuildContext context, dynamic transaction) {
    // Determine if it's an income or expense based on the transaction data structure
    final isIncome = transaction['type'] == 'income';
    final amount = transaction['amount'] as double;
    final description = transaction['description'] as String;
    final category = transaction['category'] as String;
    final date = transaction['date'] as DateTime;

    final amountColor = isIncome ? Colors.green : Colors.red;
    final isMobile = ResponsiveUtils.isMobile(context);

    // Get appropriate icon based on category
    final icon = _getCategoryIcon(category, isIncome);
    final iconColor = _getCategoryColor(category, isIncome);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 20.0,
        vertical: isMobile ? 4.0 : 8.0,
      ),
      leading: CircleAvatar(
        radius: isMobile ? 18 : 20,
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(
          icon,
          color: iconColor,
          size: isMobile ? 18 : 20,
        ),
      ),
      title: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      subtitle: Text(
        '$category • ${_formatDate(date)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: isMobile ? 12 : 13,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}€ ${amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: amountColor,
          fontSize: isMobile ? 13 : 15,
        ),
      ),
      onTap: () {
        // TODO: Navigate to transaction details
      },
    );
  }

  IconData _getCategoryIcon(String category, bool isIncome) {
    if (isIncome) {
      switch (category.toLowerCase()) {
        case 'stipendio':
        case 'salary':
          return Icons.account_balance;
        case 'freelance':
          return Icons.web;
        case 'investimenti':
        case 'investments':
          return Icons.trending_up;
        default:
          return Icons.attach_money;
      }
    } else {
      switch (category.toLowerCase()) {
        case 'spesa':
        case 'groceries':
          return Icons.shopping_cart;
        case 'carburante':
        case 'fuel':
          return Icons.local_gas_station;
        case 'ristorante':
        case 'restaurant':
          return Icons.restaurant;
        case 'salute':
        case 'health':
          return Icons.medical_services;
        default:
          return Icons.shopping_bag;
      }
    }
  }

  Color _getCategoryColor(String category, bool isIncome) {
    if (isIncome) return Colors.green;

    switch (category.toLowerCase()) {
      case 'spesa':
        return Colors.blue;
      case 'carburante':
        return Colors.orange;
      case 'ristorante':
        return Colors.red;
      case 'salute':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
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
}