import 'package:flutter/foundation.dart';

/// Classe astratta base per tutti i cache manager
abstract class CacheManager<T> {
  T? _cachedData;
  DateTime? _lastFetchTime;
  String? _currentUserId;

  /// Durata validità cache (default 5 minuti, override per personalizzare)
  Duration get cacheValidityDuration => const Duration(minutes: 5);

  /// Nome del cache manager per logging
  String get managerName;

  // Getters comuni
  T? get cachedData => _cachedData;
  DateTime? get lastFetchTime => _lastFetchTime;
  String? get currentUserId => _currentUserId;
  bool get hasCachedData => _cachedData != null;
  bool get isCacheValid => _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < cacheValidityDuration;

  /// Verifica se i dati sono disponibili in cache valida per l'utente
  bool hasValidCacheForUser(String userId) {
    return _currentUserId == userId && hasCachedData && isCacheValid;
  }

  /// Aggiorna i dati nella cache
  void updateCache(T data, {required String userId}) {
    _cachedData = data;
    _currentUserId = userId;
    _lastFetchTime = DateTime.now();
    onCacheUpdated(data);
    debugPrint('✅ [$managerName] Cache aggiornata per utente: $userId');
  }

  /// Invalida la cache (forza il ricaricamento)
  void invalidateCache() {
    _lastFetchTime = null;
    onCacheInvalidated();
    debugPrint('🔄 [$managerName] Cache invalidata');
  }

  /// Cancella completamente la cache
  void clearCache() {
    _cachedData = null;
    _lastFetchTime = null;
    _currentUserId = null;
    onCacheCleared();
    debugPrint('🗑️ [$managerName] Cache cancellata');
  }

  /// Gestisce il cambio utente
  void onUserChanged(String? newUserId) {
    if (newUserId != _currentUserId) {
      clearCache();
      _currentUserId = newUserId;
      debugPrint('👤 [$managerName] Utente cambiato: $newUserId');
    }
  }

  /// Verifica se serve ricaricare i dati
  bool shouldReloadData(String userId) {
    return _currentUserId != userId || !hasValidCacheForUser(userId);
  }

  // Metodi hook per sottoclassi (opzionali)
  void onCacheUpdated(T data) {}
  void onCacheInvalidated() {}
  void onCacheCleared() {}
}

/// Stato di caricamento per i cache manager
enum CacheLoadingState {
  initial,
  loading,
  loaded,
  error,
  refreshing,
}

/// Mixin per gestire lo stato di caricamento
mixin CacheLoadingStateMixin {
  CacheLoadingState _loadingState = CacheLoadingState.initial;
  String? _errorMessage;

  CacheLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == CacheLoadingState.loading;
  bool get isLoaded => _loadingState == CacheLoadingState.loaded;
  bool get isRefreshing => _loadingState == CacheLoadingState.refreshing;
  bool get hasError => _loadingState == CacheLoadingState.error;

  void setLoadingState(CacheLoadingState state, {String? error}) {
    _loadingState = state;
    _errorMessage = error;
  }

  void setLoading() => setLoadingState(CacheLoadingState.loading);
  void setLoaded() => setLoadingState(CacheLoadingState.loaded);
  void setRefreshing() => setLoadingState(CacheLoadingState.refreshing);
  void setError(String message) => setLoadingState(CacheLoadingState.error, error: message);
}