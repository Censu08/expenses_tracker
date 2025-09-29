import 'package:flutter/foundation.dart';
import 'cache_manager.dart';
import 'dashboard_cache_manager.dart';

/// Manager globale che coordina tutti i cache manager dell'applicazione
class GlobalCacheManager {
  // Singleton
  static final GlobalCacheManager _instance = GlobalCacheManager._internal();
  factory GlobalCacheManager() => _instance;
  GlobalCacheManager._internal() {
    _initializeCacheManagers();
  }

  // Cache managers specifici per ogni pagina/feature
  late final DashboardCacheManager dashboard;
  // Aggiungi altri cache manager qui in futuro:
  // late final IncomeCacheManager income;
  // late final ExpenseCacheManager expense;

  /// Lista di tutti i cache manager per operazioni batch
  late final List<CacheManager> _allCacheManagers;

  /// Inizializza tutti i cache manager
  void _initializeCacheManagers() {
    dashboard = DashboardCacheManager();

    _allCacheManagers = [
      dashboard,
      // Aggiungi altri qui
    ];

    debugPrint('🚀 GlobalCacheManager inizializzato con ${_allCacheManagers.length} cache manager');
  }

  /// Invalida tutte le cache (forza ricaricamento globale)
  void invalidateAllCaches() {
    debugPrint('🔄 Invalidazione di tutte le cache...');
    for (final manager in _allCacheManagers) {
      manager.invalidateCache();
    }
  }

  /// Cancella tutte le cache (al logout)
  void clearAllCaches() {
    debugPrint('🗑️ Cancellazione di tutte le cache...');
    for (final manager in _allCacheManagers) {
      manager.clearCache();
    }
  }

  /// Gestisce il cambio utente in tutti i cache manager
  void onUserChanged(String? newUserId) {
    debugPrint('👤 Cambio utente globale: $newUserId');
    for (final manager in _allCacheManagers) {
      manager.onUserChanged(newUserId);
    }
  }

  /// Invalida le cache correlate a transazioni/finanze
  void invalidateFinancialCaches() {
    debugPrint('💰 Invalidazione cache finanziarie...');
    dashboard.invalidateCache();
    // Aggiungi altri cache finanziari qui
  }

  /// Statistiche globali sulla cache
  Map<String, dynamic> getCacheStats() {
    final stats = <String, dynamic>{
      'total_managers': _allCacheManagers.length,
      'managers_with_cache': _allCacheManagers.where((m) => m.hasCachedData).length,
      'managers_with_valid_cache': _allCacheManagers.where((m) => m.isCacheValid).length,
    };
    return stats;
  }

  /// Stampa statistiche cache per debug
  void printCacheStats() {
    final stats = getCacheStats();
    debugPrint('📊 Cache Stats:');
    debugPrint('  Total managers: ${stats['total_managers']}');
    debugPrint('  With data: ${stats['managers_with_cache']}');
    debugPrint('  Valid: ${stats['managers_with_valid_cache']}');
  }
}