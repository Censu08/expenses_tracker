/// Costanti utilizzate dalle repository
class RepositoryConstants {

  // NOMI COLLECTION FIRESTORE
  static const String usersCollection = 'users';
  static const String incomesCollection = 'incomes';
  static const String expensesCollection = 'expenses';
  static const String customCategoriesCollection = 'customCategories';

  // LIMITI QUERY
  static const int defaultQueryLimit = 50;
  static const int maxQueryLimit = 100;
  static const int recentTransactionsLimit = 10;
  static const int topExpensesLimit = 5;

  // CONFIGURAZIONI PAGINAZIONE
  static const int pageSize = 20;
  static const int maxPageSize = 50;

  // LIMITI TEMPORALI
  static const int maxMonthsHistory = 24; // 2 anni
  static const int defaultStatsMonths = 12; // 1 anno
  static const int maxRecurrenceMonths = 120; // 10 anni

  // TIMEOUT E RETRY
  static const Duration queryTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // VALIDAZIONI
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 999999999.99;
  static const int maxDescriptionLength = 200;
  static const int maxCategoryNameLength = 50;

  // CATEGORIE DEFAULT IDS
  static const Map<String, String> defaultIncomeCategoryIds = {
    'salary': 'salary',
    'freelance': 'freelance',
    'investments': 'investments',
    'bonus': 'bonus',
    'rental': 'rental',
    'business': 'business',
    'other': 'other',
  };

  static const Map<String, String> defaultExpenseCategoryIds = {
    'groceries': 'groceries',
    'fuel': 'fuel',
    'restaurant': 'restaurant',
    'health': 'health',
    'education': 'education',
    'transport': 'transport',
    'utilities': 'utilities',
    'entertainment': 'entertainment',
    'shopping': 'shopping',
    'other': 'other',
  };

  // MESSAGGI DI ERRORE
  static const String userNotFoundError = 'Utente non trovato';
  static const String categoryNotFoundError = 'Categoria non trovata';
  static const String incomeNotFoundError = 'Entrata non trovata';
  static const String expenseNotFoundError = 'Spesa non trovata';
  static const String invalidAmountError = 'Importo non valido';
  static const String invalidDateError = 'Data non valida';
  static const String categoryInUseError = 'Categoria in uso, impossibile eliminare';
  static const String networkError = 'Errore di connessione';
  static const String permissionDeniedError = 'Permessi insufficienti';

  // CACHE CONFIGURATION
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxCacheSize = 100;

  // BATCH OPERATION LIMITS
  static const int maxBatchSize = 500; // Firestore limit
  static const int recommendedBatchSize = 100;

  // RECURRING TRANSACTION CONFIG
  static const int maxRecurringInstances = 1000;
  static const int recurringLookaheadDays = 90; // 3 mesi

  /// Verifica se un importo è valido
  static bool isValidAmount(double amount) {
    return amount >= minTransactionAmount && amount <= maxTransactionAmount;
  }

  /// Verifica se una descrizione è valida
  static bool isValidDescription(String description) {
    return description.trim().isNotEmpty &&
        description.length <= maxDescriptionLength;
  }

  /// Verifica se un nome categoria è valido
  static bool isValidCategoryName(String name) {
    return name.trim().isNotEmpty &&
        name.length <= maxCategoryNameLength;
  }

  /// Ottieni il messaggio di errore formattato
  static String getFormattedError(String baseError, [String? details]) {
    if (details != null && details.isNotEmpty) {
      return '$baseError: $details';
    }
    return baseError;
  }

  /// Calcola il numero di pagine necessarie
  static int calculatePages(int totalItems, {int? customPageSize}) {
    final size = customPageSize ?? pageSize;
    return (totalItems / size).ceil();
  }

  /// Valida i parametri di data per le query
  static bool isValidDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return true;

    if (startDate.isAfter(endDate)) return false;

    // Non permettere range troppo ampi (più di 2 anni)
    final maxRange = Duration(days: 365 * 2);
    return endDate.difference(startDate) <= maxRange;
  }

  /// Ottieni la data limite per le query storiche
  static DateTime getHistoryLimit() {
    return DateTime.now().subtract(Duration(days: 365 * (maxMonthsHistory ~/ 12)));
  }
}

/// Configurazione per le operazioni di export/import
class ExportImportConfig {
  static const String exportVersion = '1.0';
  static const List<String> supportedFormats = ['json', 'csv'];
  static const int maxExportRecords = 10000;
  static const String defaultExportFormat = 'json';

  // Headers per export CSV
  static const List<String> incomeHeaders = [
    'ID', 'Importo', 'Descrizione', 'Categoria', 'Data Entrata',
    'Data Creazione', 'Ricorrente', 'Tipo Ricorrenza', 'Livello Necessità'
  ];

  static const List<String> expenseHeaders = [
    'ID', 'Importo', 'Descrizione', 'Categoria', 'Data Spesa',
    'Data Creazione', 'Ricorrente', 'Tipo Ricorrenza', 'Livello Necessità'
  ];

  static const List<String> categoryHeaders = [
    'ID', 'Descrizione', 'Codice Icona', 'Colore'
  ];
}

/// Configurazione per la cache locale
class CacheConfig {
  static const String cachePrefix = 'expenses_tracker_';
  static const Map<String, Duration> cacheExpirations = {
    'categories': Duration(hours: 24),
    'monthly_stats': Duration(hours: 1),
    'recent_transactions': Duration(minutes: 10),
    'user_preferences': Duration(days: 7),
  };

  static String getCacheKey(String type, String userId, [String? suffix]) {
    final key = '${cachePrefix}${type}_$userId';
    return suffix != null ? '${key}_$suffix' : key;
  }
}