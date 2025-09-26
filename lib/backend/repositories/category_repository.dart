import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../../core/utils/id_generator.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // CATEGORIE DI DEFAULT (FISSE)

  /// Ottieni tutte le categorie di default per le entrate
  List<CategoryModel> getDefaultIncomeCategories() {
    return CategoryModel.getDefaultIncomeCategories();
  }

  /// Ottieni tutte le categorie di default per le spese
  List<CategoryModel> getDefaultExpenseCategories() {
    return CategoryModel.getDefaultExpenseCategories();
  }

  /// Ottieni una categoria di default per ID
  CategoryModel? getDefaultCategoryById(String categoryId, {required bool isIncome}) {
    final defaultCategories = isIncome
        ? getDefaultIncomeCategories()
        : getDefaultExpenseCategories();

    try {
      return defaultCategories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // CATEGORIE CUSTOM DELL'UTENTE

  /// Riferimento alla subcollection delle categorie custom dell'utente
  CollectionReference _getUserCustomCategoriesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('customCategories');
  }

  /// Crea una nuova categoria custom
  Future<CategoryModel> createCustomCategory({
    required String userId,
    required String description,
    required int iconCodePoint,
    required int colorValue,
  }) async {
    try {
      final categoryId = IdGenerator.generateCategoryId();

      final category = CategoryModel(
        id: categoryId,
        description: description,
        icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
        color: Color(colorValue),
      );

      await _getUserCustomCategoriesRef(userId)
          .doc(categoryId)
          .set(category.toJson());

      return category;
    } catch (e) {
      throw Exception('Errore nella creazione della categoria custom: $e');
    }
  }

  /// Ottieni tutte le categorie custom dell'utente
  Future<List<CategoryModel>> getUserCustomCategories(String userId) async {
    try {
      final querySnapshot = await _getUserCustomCategoriesRef(userId).get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Errore nel recupero delle categorie custom: $e');
    }
  }

  /// Ottieni una categoria custom specifica
  Future<CategoryModel?> getUserCustomCategoryById(String userId, String categoryId) async {
    try {
      final doc = await _getUserCustomCategoriesRef(userId)
          .doc(categoryId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return CategoryModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Errore nel recupero della categoria custom: $e');
    }
  }

  /// Aggiorna una categoria custom
  Future<CategoryModel> updateCustomCategory({
    required String userId,
    required String categoryId,
    String? description,
    int? iconCodePoint,
    int? colorValue,
  }) async {
    try {
      final existingCategory = await getUserCustomCategoryById(userId, categoryId);
      if (existingCategory == null) {
        throw Exception('Categoria non trovata');
      }

      final updatedCategory = existingCategory.copyWith(
        description: description ?? existingCategory.description,
        icon: iconCodePoint != null
            ? IconData(iconCodePoint, fontFamily: 'MaterialIcons')
            : existingCategory.icon,
        color: colorValue != null
            ? Color(colorValue)
            : existingCategory.color,
      );

      await _getUserCustomCategoriesRef(userId)
          .doc(categoryId)
          .update(updatedCategory.toJson());

      return updatedCategory;
    } catch (e) {
      throw Exception('Errore nell\'aggiornamento della categoria custom: $e');
    }
  }

  /// Elimina una categoria custom
  Future<void> deleteCustomCategory(String userId, String categoryId) async {
    try {
      // Verifica se la categoria esiste
      final category = await getUserCustomCategoryById(userId, categoryId);
      if (category == null) {
        throw Exception('Categoria non trovata');
      }

      // TODO: Verificare se la categoria è in uso prima di eliminarla
      // Questo controllo dovrebbe essere fatto nelle transazioni/entrate/spese

      await _getUserCustomCategoriesRef(userId)
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Errore nell\'eliminazione della categoria custom: $e');
    }
  }

  // METODI COMBINATI (DEFAULT + CUSTOM)

  /// Ottieni tutte le categorie disponibili per un utente (default + custom)
  Future<List<CategoryModel>> getAllUserCategories(String userId, {required bool isIncome}) async {
    try {
      final defaultCategories = isIncome
          ? getDefaultIncomeCategories()
          : getDefaultExpenseCategories();

      final customCategories = await getUserCustomCategories(userId);

      // Combina le categorie, rimuovendo eventuali duplicati per ID
      final allCategories = <String, CategoryModel>{};

      // Prima aggiungi le categorie di default
      for (final category in defaultCategories) {
        allCategories[category.id] = category;
      }

      // Poi aggiungi quelle custom (potrebbero sovrascrivere le default con stesso ID)
      for (final category in customCategories) {
        allCategories[category.id] = category;
      }

      return allCategories.values.toList()
        ..sort((a, b) => a.description.compareTo(b.description));
    } catch (e) {
      throw Exception('Errore nel recupero di tutte le categorie: $e');
    }
  }

  /// Ottieni una categoria per ID (cerca prima nelle custom, poi nelle default)
  Future<CategoryModel?> getCategoryById(String userId, String categoryId, {required bool isIncome}) async {
    try {
      // Prima cerca nelle categorie custom
      final customCategory = await getUserCustomCategoryById(userId, categoryId);
      if (customCategory != null) {
        return customCategory;
      }

      // Poi cerca nelle categorie di default
      return getDefaultCategoryById(categoryId, isIncome: isIncome);
    } catch (e) {
      throw Exception('Errore nel recupero della categoria: $e');
    }
  }

  /// Stream delle categorie custom dell'utente
  Stream<List<CategoryModel>> getUserCustomCategoriesStream(String userId) {
    return _getUserCustomCategoriesRef(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// Verifica se una categoria è utilizzata nelle transazioni dell'utente
  Future<bool> isCategoryInUse(String userId, String categoryId) async {
    try {
      // Controlla se è usata nelle entrate
      final incomesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('incomes')
          .where('category.id', isEqualTo: categoryId)
          .limit(1)
          .get();

      if (incomesQuery.docs.isNotEmpty) return true;

      // Controlla se è usata nelle spese
      final expensesQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('category.id', isEqualTo: categoryId)
          .limit(1)
          .get();

      return expensesQuery.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Errore nella verifica utilizzo categoria: $e');
    }
  }

  /// Conta quante volte una categoria è utilizzata
  Future<Map<String, int>> getCategoryUsageCount(String userId, String categoryId) async {
    try {
      final incomeCount = await _firestore
          .collection('users')
          .doc(userId)
          .collection('incomes')
          .where('category.id', isEqualTo: categoryId)
          .get()
          .then((query) => query.docs.length);

      final expenseCount = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .where('category.id', isEqualTo: categoryId)
          .get()
          .then((query) => query.docs.length);

      return {
        'incomes': incomeCount,
        'expenses': expenseCount,
        'total': incomeCount + expenseCount,
      };
    } catch (e) {
      throw Exception('Errore nel conteggio utilizzo categoria: $e');
    }
  }
}