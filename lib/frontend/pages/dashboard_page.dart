import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/bloc_state_widgets.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/dashboard_income_diversification_card.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/providers/bloc_providers.dart';
import '../../core/cache/cache.dart';
import '../../backend/blocs/blocs.dart';
import '../../backend/models/income/income_model.dart';
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
              debugPrint('✅ Dashboard data cached');
            }

            if (state is FinancialAlertsLoaded) {
              _cacheManager.updateFinancialAlerts(state.alerts);
              debugPrint('✅ Financial alerts cached: ${state.alerts.length}');
            }
          },
        ),
      ],
      child: RefreshableWidget(
        onRefresh: _refreshDashboardData,
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (_cacheManager.isLoading) {
              return _buildLoadingCard();
            }

            if (state is TransactionError && _cacheManager.cachedData == null) {
              return _buildErrorCard(state.message);
            }

            final dashboardData = _cacheManager.cachedData ?? {};
            if (dashboardData.isEmpty) {
              return _buildEmptyTransactions();
            }

            if (ResponsiveUtils.isMobile(context)) {
              return _buildMobileLayout(dashboardData);
            } else if (ResponsiveUtils.isTablet(context)) {
              return _buildTabletLayout(dashboardData);
            } else {
              return _buildDesktopLayout(dashboardData);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> dashboardData) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialAlerts(),
          _buildSummaryCard(dashboardData),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          const DashboardIncomeDiversificationCard(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          QuickActionsGrid(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),
          _buildRecentTransactions(dashboardData),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(Map<String, dynamic> dashboardData) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFinancialAlerts(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildSummaryCard(dashboardData),
                    SizedBox(height: ResponsiveUtils.getSpacing(context)),
                    const DashboardIncomeDiversificationCard(),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(flex: 1, child: QuickActionsGrid()),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildSectionTitle('Transazioni Recenti'),
          const SizedBox(height: 12),
          _buildRecentTransactions(dashboardData),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> dashboardData) {
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
                        _buildSummaryCard(dashboardData),
                        SizedBox(height: ResponsiveUtils.getSpacing(context)),
                        const DashboardIncomeDiversificationCard(),
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
                      const SizedBox(height: 12),
                      Expanded(child: _buildRecentTransactions(dashboardData)),
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

  Widget _buildFinancialAlerts() {
    final alerts = _cacheManager.financialAlerts;
    if (alerts == null || alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context)),
      child: Card(
        color: Colors.orange.shade50,
        child: InkWell(
          onTap: () => _showAlertsDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${alerts.length} ${alerts.length == 1 ? 'Alert Finanziario' : 'Alert Finanziari'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alerts.first['message'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> dashboardData) {
    return EnhancedExpenseSummaryCard(dashboardData: dashboardData);
  }

  Widget _buildRecentTransactions(Map<String, dynamic> dashboardData) {
    final recentTransactions = dashboardData['recent_transactions'] as List? ?? [];

    if (recentTransactions.isEmpty) {
      return _buildEmptyTransactions();
    }

    return EnhancedRecentTransactionsList(
      transactions: recentTransactions.cast<Map<String, dynamic>>(),
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
            fontSize: ResponsiveUtils.isMobile(context) ? 18 : 22,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 40.0 : 60.0),
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
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nessuna transazione',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Inizia aggiungendo la tua prima entrata o spesa',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertsDialog(BuildContext context) {
    final alerts = _cacheManager.financialAlerts ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Finanziari'),
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

  IconData _getAlertIcon(String? type) {
    switch (type) {
      case 'budget_exceeded':
        return Icons.error;
      case 'budget_warning':
        return Icons.warning;
      case 'unusual_spending':
        return Icons.trending_up;
      default:
        return Icons.info;
    }
  }

  Color _getAlertColor(String? severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isIncome = transaction['type'] == 'income';
          final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
          final description = transaction['description'] ?? 'N/A';
          final date = transaction['date'] ?? '';

          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            leading: CircleAvatar(
              backgroundColor: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: isIncome ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              description,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 14 : 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              date.toString(),
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}€${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }
}

class EnhancedExpenseSummaryCard extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  const EnhancedExpenseSummaryCard({
    Key? key,
    required this.dashboardData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summaryCards = dashboardData['summary_cards'] ?? {};
    final totalIncome =
        (summaryCards['total_income_month'] as num?)?.toDouble() ?? 0.0;
    final totalExpense =
        (summaryCards['total_expense_month'] as num?)?.toDouble() ?? 0.0;
    final netBalance =
        (summaryCards['net_balance_month'] as num?)?.toDouble() ?? 0.0;

    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Riepilogo Mensile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 18 : 22,
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Entrate',
                    totalIncome,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Spese',
                    totalExpense,
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              context,
              'Bilancio',
              netBalance,
              Icons.account_balance,
              netBalance >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context,
      String label,
      double amount,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '€${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}