import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../repositories/category_repository.dart';
import '../models/category_model.dart';
import '../../core/errors/app_exceptions.dart';

class CategoryController {
  final CategoryRepository _categoryRepository;

  CategoryController({CategoryRepository? categoryRepository})
      : _categoryRepository = categoryRepository ?? CategoryRepository();

  // ==============================================================================
  // CATEGORIE DEFAULT
  // ==============================================================================

  /// Ottieni tutte le categorie default per entrate
  List<CategoryModel> getDefaultIncomeCategories() {
    try {
      final categories = _categoryRepository.getDefaultIncomeCategories();
      debugPrint('Recuperate ${categories.length} categorie default per entrate');
      return categories;
    } catch (e) {
      debugPrint('Errore nel recupero categorie default entrate: $e');
      rethrow;
    }
  }

  /// Ottieni tutte le categorie default per spese
  List<CategoryModel> getDefaultExpenseCategories() {
    try {
      final categories = _categoryRepository.getDefaultExpenseCategories();
      debugPrint('Recuperate ${categories.length} categorie default per spese');
      return categories;
    } catch (e) {
      debugPrint('Errore nel recupero categorie default spese: $e');
      rethrow;
    }
  }

  /// Ottieni una categoria default per ID
  CategoryModel? getDefaultCategoryById(String categoryId, {required bool isIncome}) {
    try {
      final category = _categoryRepository.getDefaultCategoryById(categoryId, isIncome: isIncome);
      if (category != null) {
        debugPrint('Categoria default trovata: ${category.description}');
      } else {
        debugPrint('Categoria default non trovata per ID: $categoryId');
      }
      return category;
    } catch (e) {
      debugPrint('Errore nel recupero categoria default: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // CATEGORIE CUSTOM UTENTE
  // ==============================================================================

  /// Crea una nuova categoria custom
  Future<CategoryModel> createCustomCategory({
    required String userId,
    required String description,
    required IconData icon,
    required Color color,
  }) async {
    try {
      // Validazioni
      _validateCategoryData(description: description);
      _validateUserId(userId);

      final category = await _categoryRepository.createCustomCategory(
        userId: userId,
        description: description.trim(),
        iconCodePoint: icon.codePoint,
        colorValue: color.value,
      );

      debugPrint('Categoria custom creata con successo: ${category.id}');
      return category;
    } catch (e) {
      debugPrint('Errore nella creazione categoria custom: $e');
      rethrow;
    }
  }

  /// Ottieni tutte le categorie custom dell'utente
  Future<List<CategoryModel>> getUserCustomCategories(String userId) async {
    try {
      _validateUserId(userId);

      final categories = await _categoryRepository.getUserCustomCategories(userId);
      debugPrint('Recuperate ${categories.length} categorie custom per utente: $userId');
      return categories;
    } catch (e) {
      debugPrint('Errore nel recupero categorie custom: $e');
      rethrow;
    }
  }

  /// Ottieni una categoria custom specifica
  Future<CategoryModel?> getUserCustomCategoryById(String userId, String categoryId) async {
    try {
      _validateUserId(userId);
      _validateCategoryId(categoryId);

      final category = await _categoryRepository.getUserCustomCategoryById(userId, categoryId);
      if (category != null) {
        debugPrint('Categoria custom trovata: ${category.description}');
      } else {
        debugPrint('Categoria custom non trovata: $categoryId');
      }
      return category;
    } catch (e) {
      debugPrint('Errore nel recupero categoria custom: $e');
      rethrow;
    }
  }

  /// Aggiorna una categoria custom
  Future<CategoryModel> updateCustomCategory({
    required String userId,
    required String categoryId,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    try {
      _validateUserId(userId);
      _validateCategoryId(categoryId);

      if (description != null) {
        _validateCategoryData(description: description);
      }

      final updatedCategory = await _categoryRepository.updateCustomCategory(
        userId: userId,
        categoryId: categoryId,
        description: description?.trim(),
        iconCodePoint: icon?.codePoint,
        colorValue: color?.value,
      );

      debugPrint('Categoria custom aggiornata: $categoryId');
      return updatedCategory;
    } catch (e) {
      debugPrint('Errore nell\'aggiornamento categoria custom: $e');
      rethrow;
    }
  }

  /// Elimina una categoria custom (con controllo utilizzo)
  Future<void> deleteCustomCategory(String userId, String categoryId) async {
    try {
      _validateUserId(userId);
      _validateCategoryId(categoryId);

      // Verifica se la categoria è in uso
      final isInUse = await _categoryRepository.isCategoryInUse(userId, categoryId);
      if (isInUse) {
        throw const ValidationException(
            'Impossibile eliminare la categoria: è utilizzata in una o più transazioni'
        );
      }

      await _categoryRepository.deleteCustomCategory(userId, categoryId);
      debugPrint('Categoria custom eliminata: $categoryId');
    } catch (e) {
      debugPrint('Errore nell\'eliminazione categoria custom: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // OPERAZIONI COMBINATE
  // ==============================================================================

  /// Ottieni tutte le categorie disponibili per un utente (default + custom)
  Future<List<CategoryModel>> getAllUserCategories(String userId, {required bool isIncome}) async {
    try {
      _validateUserId(userId);

      final categories = await _categoryRepository.getAllUserCategories(userId, isIncome: isIncome);
      debugPrint('Recuperate ${categories.length} categorie totali per utente: $userId');
      return categories;
    } catch (e) {
      debugPrint('Errore nel recupero di tutte le categorie: $e');
      rethrow;
    }
  }

  /// Ottieni una categoria per ID (cerca prima custom, poi default)
  Future<CategoryModel?> getCategoryById(String userId, String categoryId, {required bool isIncome}) async {
    try {
      _validateUserId(userId);
      _validateCategoryId(categoryId);

      final category = await _categoryRepository.getCategoryById(userId, categoryId, isIncome: isIncome);
      if (category != null) {
        debugPrint('Categoria trovata: ${category.description}');
      } else {
        debugPrint('Categoria non trovata: $categoryId');
      }
      return category;
    } catch (e) {
      debugPrint('Errore nel recupero categoria: $e');
      rethrow;
    }
  }

  /// Verifica se una categoria è utilizzata
  Future<bool> isCategoryInUse(String userId, String categoryId) async {
    try {
      _validateUserId(userId);
      _validateCategoryId(categoryId);

      final isInUse = await _categoryRepository.isCategoryInUse(userId, categoryId);
      debugPrint('Categoria $categoryId in uso: $isInUse');
      return isInUse;
    } catch (e) {
      debugPrint('Errore nella verifica utilizzo categoria: $e');
      rethrow;
    }
  }

  /// Ottieni statistiche utilizzo categoria
  Future<Map<String, int>> getCategoryUsageStats(String userId, String categoryId) async {
    try {
      _validateUserId(userId);
      _validateCategoryId(categoryId);

      final stats = await _categoryRepository.getCategoryUsageCount(userId, categoryId);
      debugPrint('Statistiche utilizzo categoria $categoryId: $stats');
      return stats;
    } catch (e) {
      debugPrint('Errore nel recupero statistiche categoria: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // STREAM E REAL-TIME UPDATES
  // ==============================================================================

  /// Stream delle categorie custom dell'utente
  Stream<List<CategoryModel>> getUserCustomCategoriesStream(String userId) {
    try {
      _validateUserId(userId);

      debugPrint('Avviato stream categorie custom per utente: $userId');
      return _categoryRepository.getUserCustomCategoriesStream(userId);
    } catch (e) {
      debugPrint('Errore nell\'avvio stream categorie custom: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // UTILITY E HELPER METHODS
  // ==============================================================================

  /// Suggerisci categorie simili in base al nome
  List<CategoryModel> suggestSimilarCategories(String searchTerm, List<CategoryModel> availableCategories) {
    try {
      if (searchTerm.trim().isEmpty) return [];

      final searchLower = searchTerm.toLowerCase().trim();

      return availableCategories.where((category) {
        return category.description.toLowerCase().contains(searchLower);
      }).toList()
        ..sort((a, b) => a.description.compareTo(b.description));
    } catch (e) {
      debugPrint('Errore nella ricerca categorie simili: $e');
      return [];
    }
  }

  /// Ottieni le categorie più utilizzate
  Future<List<CategoryModel>> getMostUsedCategories(String userId, {required bool isIncome, int limit = 5}) async {
    try {
      _validateUserId(userId);

      final allCategories = await getAllUserCategories(userId, isIncome: isIncome);
      final usageStats = <CategoryModel, int>{};

      for (final category in allCategories) {
        final stats = await getCategoryUsageStats(userId, category.id);
        final usage = isIncome ? (stats['incomes'] ?? 0) : (stats['expenses'] ?? 0);
        if (usage > 0) {
          usageStats[category] = usage;
        }
      }

      final sortedCategories = usageStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final result = sortedCategories.take(limit).map((entry) => entry.key).toList();
      debugPrint('Recuperate ${result.length} categorie più utilizzate');
      return result;
    } catch (e) {
      debugPrint('Errore nel recupero categorie più utilizzate: $e');
      return [];
    }
  }

  /// Crea categorie predefinite personalizzate per un nuovo utente
  Future<List<CategoryModel>> createInitialCustomCategories(String userId, {required bool isIncome}) async {
    try {
      _validateUserId(userId);

      final createdCategories = <CategoryModel>[];

      // Aggiungi alcune categorie personalizzate comuni
      final initialCategories = isIncome
          ? _getInitialIncomeCategories()
          : _getInitialExpenseCategories();

      for (final categoryData in initialCategories) {
        try {
          final category = await createCustomCategory(
            userId: userId,
            description: categoryData['description'],
            icon: categoryData['icon'],
            color: categoryData['color'],
          );
          createdCategories.add(category);
        } catch (e) {
          // Ignora errori singoli ma continua con le altre categorie
          debugPrint('Errore nella creazione categoria iniziale ${categoryData['description']}: $e');
        }
      }

      debugPrint('Create ${createdCategories.length} categorie iniziali per utente: $userId');
      return createdCategories;
    } catch (e) {
      debugPrint('Errore nella creazione categorie iniziali: $e');
      rethrow;
    }
  }

  // ==============================================================================
  // VALIDAZIONI PRIVATE
  // ==============================================================================

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw const ValidationException('User ID richiesto');
    }
  }

  void _validateCategoryId(String categoryId) {
    if (categoryId.trim().isEmpty) {
      throw const ValidationException('Category ID richiesto');
    }
  }

  void _validateCategoryData({required String description}) {
    if (description.trim().isEmpty) {
      throw const ValidationException('Descrizione categoria richiesta');
    }
    if (description.trim().length < 2) {
      throw const ValidationException('Descrizione categoria troppo corta');
    }
    if (description.length > 50) {
      throw const ValidationException('Descrizione categoria troppo lunga (max 50 caratteri)');
    }
  }

  // ==============================================================================
  // DATI INIZIALI HELPER
  // ==============================================================================

  List<Map<String, dynamic>> _getInitialIncomeCategories() {
    return [
      {
        'description': 'Lavoro Part-time',
        'icon': Icons.schedule,
        'color': Colors.lightBlue,
      },
      {
        'description': 'Vendite Online',
        'icon': Icons.shopping_bag,
        'color': Colors.green,
      },
    ];
  }

  List<Map<String, dynamic>> _getInitialExpenseCategories() {
    return [
      {
        'description': 'Abbonamenti',
        'icon': Icons.subscriptions,
        'color': Colors.purple,
      },
      {
        'description': 'Casa e Famiglia',
        'icon': Icons.home_filled,
        'color': Colors.brown,
      },
    ];
  }
}