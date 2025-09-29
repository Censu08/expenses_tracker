import 'package:flutter/foundation.dart';
import 'cache_manager.dart';

/// Cache manager specifico per la Dashboard
class DashboardCacheManager extends CacheManager<Map<String, dynamic>>
    with CacheLoadingStateMixin {

  @override
  String get managerName => 'Dashboard';

  @override
  Duration get cacheValidityDuration => const Duration(minutes: 5);

  // Dati specifici dashboard
  List<dynamic>? _recentTransactions;
  List<Map<String, dynamic>>? _financialAlerts;
  Map<String, dynamic>? _summaryCards;
  Map<String, dynamic>? _currentPeriod;

  // Getters specifici
  List<dynamic>? get recentTransactions => _recentTransactions;
  List<Map<String, dynamic>>? get financialAlerts => _financialAlerts;
  Map<String, dynamic>? get summaryCards => _summaryCards;
  Map<String, dynamic>? get currentPeriod => _currentPeriod;

  /// Aggiorna tutti i dati della dashboard
  void updateDashboardData(Map<String, dynamic> data, {required String userId}) {
    updateCache(data, userId: userId);

    // Estrai e salva i componenti specifici
    _summaryCards = data['summary_cards'];
    _currentPeriod = data['current_period'];
    _recentTransactions = data['recent_transactions'];

    setLoaded();
    debugPrint('✅ [Dashboard] Dati completi aggiornati');
  }

  /// Aggiorna solo le transazioni recenti (da stream)
  void updateRecentTransactions(List<dynamic> transactions) {
    _recentTransactions = transactions;

    // Aggiorna anche nel cachedData principale se esiste
    if (cachedData != null) {
      cachedData!['recent_transactions'] = transactions;
    }

    debugPrint('✅ [Dashboard] ${transactions.length} transazioni aggiornate');
  }

  /// Aggiorna solo gli alert finanziari
  void updateFinancialAlerts(List<Map<String, dynamic>> alerts) {
    _financialAlerts = alerts;

    // Aggiorna anche nel cachedData principale se esiste
    if (cachedData != null) {
      cachedData!['financial_alerts'] = alerts;
    }

    debugPrint('✅ [Dashboard] ${alerts.length} alert aggiornati');
  }

  @override
  void onCacheCleared() {
    _recentTransactions = null;
    _financialAlerts = null;
    _summaryCards = null;
    _currentPeriod = null;
    setLoadingState(CacheLoadingState.initial);
  }

  @override
  void onCacheInvalidated() {
    setLoadingState(CacheLoadingState.initial);
  }

  /// Ottieni il bilancio netto corrente dalla cache
  double? get currentNetBalance {
    return _summaryCards?['net_balance_month']?.toDouble();
  }

  /// Ottieni il totale entrate del mese dalla cache
  double? get currentMonthIncome {
    return _summaryCards?['total_income_month']?.toDouble();
  }

  /// Ottieni il totale spese del mese dalla cache
  double? get currentMonthExpense {
    return _summaryCards?['total_expense_month']?.toDouble();
  }

  /// Ottieni la percentuale budget dalla cache
  double? get budgetPercentage {
    return _summaryCards?['budget_percentage']?.toDouble();
  }

  /// Verifica se ci sono alert critici
  bool get hasCriticalAlerts {
    if (_financialAlerts == null) return false;
    return _financialAlerts!.any((alert) => alert['severity'] == 'high');
  }

  /// Conta il numero di transazioni
  int get transactionCount {
    return _recentTransactions?.length ?? 0;
  }
}