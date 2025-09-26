import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';
import '../../core/errors/app_exceptions.dart';

// ==============================================================================
// EVENTI
// ==============================================================================

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadDefaultCategoriesEvent extends CategoryEvent {
  final bool isIncome;

  const LoadDefaultCategoriesEvent({required this.isIncome});

  @override
  List<Object?> get props => [isIncome];
}

class LoadUserCustomCategoriesEvent extends CategoryEvent {
  final String userId;

  const LoadUserCustomCategoriesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadAllUserCategoriesEvent extends CategoryEvent {
  final String userId;
  final bool isIncome;

  const LoadAllUserCategoriesEvent({required this.userId, required this.isIncome});

  @override
  List<Object?> get props => [userId, isIncome];
}

class CreateCustomCategoryEvent extends CategoryEvent {
  final String userId;
  final String description;
  final IconData icon;
  final Color color;

  const CreateCustomCategoryEvent({
    required this.userId,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [userId, description, icon, color];
}

class UpdateCustomCategoryEvent extends CategoryEvent {
  final String userId;
  final String categoryId;
  final String? description;
  final IconData? icon;
  final Color? color;

  const UpdateCustomCategoryEvent({
    required this.userId,
    required this.categoryId,
    this.description,
    this.icon,
    this.color,
  });

  @override
  List<Object?> get props => [userId, categoryId, description, icon, color];
}

class DeleteCustomCategoryEvent extends CategoryEvent {
  final String userId;
  final String categoryId;

  const DeleteCustomCategoryEvent({
    required this.userId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [userId, categoryId];
}

class GetCategoryByIdEvent extends CategoryEvent {
  final String userId;
  final String categoryId;
  final bool isIncome;

  const GetCategoryByIdEvent({
    required this.userId,
    required this.categoryId,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [userId, categoryId, isIncome];
}

class CheckCategoryUsageEvent extends CategoryEvent {
  final String userId;
  final String categoryId;

  const CheckCategoryUsageEvent({
    required this.userId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [userId, categoryId];
}

class GetCategoryUsageStatsEvent extends CategoryEvent {
  final String userId;
  final String categoryId;

  const GetCategoryUsageStatsEvent({
    required this.userId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [userId, categoryId];
}

class SearchCategoriesEvent extends CategoryEvent {
  final String searchTerm;
  final List<CategoryModel> availableCategories;

  const SearchCategoriesEvent({
    required this.searchTerm,
    required this.availableCategories,
  });

  @override
  List<Object?> get props => [searchTerm, availableCategories];
}

class GetMostUsedCategoriesEvent extends CategoryEvent {
  final String userId;
  final bool isIncome;
  final int limit;

  const GetMostUsedCategoriesEvent({
    required this.userId,
    required this.isIncome,
    this.limit = 5,
  });

  @override
  List<Object?> get props => [userId, isIncome, limit];
}

// ==============================================================================
// STATI
// ==============================================================================

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Stati per categorie default
class DefaultCategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final bool isIncome;

  const DefaultCategoriesLoaded({
    required this.categories,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [categories, isIncome];
}

// Stati per categorie custom
class CustomCategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final String userId;

  const CustomCategoriesLoaded({
    required this.categories,
    required this.userId,
  });

  @override
  List<Object?> get props => [categories, userId];
}

// Stati per tutte le categorie utente
class AllUserCategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final String userId;
  final bool isIncome;

  const AllUserCategoriesLoaded({
    required this.categories,
    required this.userId,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [categories, userId, isIncome];
}

// Stati per singola categoria
class CategoryByIdLoaded extends CategoryState {
  final CategoryModel? category;
  final String categoryId;

  const CategoryByIdLoaded({
    required this.category,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [category, categoryId];
}

// Stati per operazioni CRUD
class CustomCategoryCreated extends CategoryState {
  final CategoryModel category;

  const CustomCategoryCreated({required this.category});

  @override
  List<Object?> get props => [category];
}

class CustomCategoryUpdated extends CategoryState {
  final CategoryModel category;

  const CustomCategoryUpdated({required this.category});

  @override
  List<Object?> get props => [category];
}

class CustomCategoryDeleted extends CategoryState {
  final String categoryId;

  const CustomCategoryDeleted({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

// Stati per utilizzo categorie
class CategoryUsageChecked extends CategoryState {
  final bool isInUse;
  final String categoryId;

  const CategoryUsageChecked({
    required this.isInUse,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [isInUse, categoryId];
}

class CategoryUsageStatsLoaded extends CategoryState {
  final Map<String, int> usageStats;
  final String categoryId;

  const CategoryUsageStatsLoaded({
    required this.usageStats,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [usageStats, categoryId];
}

// Stati per ricerca
class CategoriesSearchResults extends CategoryState {
  final List<CategoryModel> results;
  final String searchTerm;

  const CategoriesSearchResults({
    required this.results,
    required this.searchTerm,
  });

  @override
  List<Object?> get props => [results, searchTerm];
}

// Stati per categorie più utilizzate
class MostUsedCategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final bool isIncome;

  const MostUsedCategoriesLoaded({
    required this.categories,
    required this.isIncome,
  });

  @override
  List<Object?> get props => [categories, isIncome];
}

// ==============================================================================
// BLOC
// ==============================================================================

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryController _categoryController;

  CategoryBloc({CategoryController? categoryController})
      : _categoryController = categoryController ?? CategoryController(),
        super(const CategoryInitial()) {

    on<LoadDefaultCategoriesEvent>(_onLoadDefaultCategories);
    on<LoadUserCustomCategoriesEvent>(_onLoadUserCustomCategories);
    on<LoadAllUserCategoriesEvent>(_onLoadAllUserCategories);
    on<CreateCustomCategoryEvent>(_onCreateCustomCategory);
    on<UpdateCustomCategoryEvent>(_onUpdateCustomCategory);
    on<DeleteCustomCategoryEvent>(_onDeleteCustomCategory);
    on<GetCategoryByIdEvent>(_onGetCategoryById);
    on<CheckCategoryUsageEvent>(_onCheckCategoryUsage);
    on<GetCategoryUsageStatsEvent>(_onGetCategoryUsageStats);
    on<SearchCategoriesEvent>(_onSearchCategories);
    on<GetMostUsedCategoriesEvent>(_onGetMostUsedCategories);
  }

  Future<void> _onLoadDefaultCategories(
      LoadDefaultCategoriesEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final categories = event.isIncome
          ? _categoryController.getDefaultIncomeCategories()
          : _categoryController.getDefaultExpenseCategories();

      emit(DefaultCategoriesLoaded(
        categories: categories,
        isIncome: event.isIncome,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserCustomCategories(
      LoadUserCustomCategoriesEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final categories = await _categoryController.getUserCustomCategories(event.userId);

      emit(CustomCategoriesLoaded(
        categories: categories,
        userId: event.userId,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadAllUserCategories(
      LoadAllUserCategoriesEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final categories = await _categoryController.getAllUserCategories(
        event.userId,
        isIncome: event.isIncome,
      );

      emit(AllUserCategoriesLoaded(
        categories: categories,
        userId: event.userId,
        isIncome: event.isIncome,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onCreateCustomCategory(
      CreateCustomCategoryEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final category = await _categoryController.createCustomCategory(
        userId: event.userId,
        description: event.description,
        icon: event.icon,
        color: event.color,
      );

      emit(CustomCategoryCreated(category: category));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCustomCategory(
      UpdateCustomCategoryEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final category = await _categoryController.updateCustomCategory(
        userId: event.userId,
        categoryId: event.categoryId,
        description: event.description,
        icon: event.icon,
        color: event.color,
      );

      emit(CustomCategoryUpdated(category: category));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCustomCategory(
      DeleteCustomCategoryEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      await _categoryController.deleteCustomCategory(
        event.userId,
        event.categoryId,
      );

      emit(CustomCategoryDeleted(categoryId: event.categoryId));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onGetCategoryById(
      GetCategoryByIdEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final category = await _categoryController.getCategoryById(
        event.userId,
        event.categoryId,
        isIncome: event.isIncome,
      );

      emit(CategoryByIdLoaded(
        category: category,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onCheckCategoryUsage(
      CheckCategoryUsageEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final isInUse = await _categoryController.isCategoryInUse(
        event.userId,
        event.categoryId,
      );

      emit(CategoryUsageChecked(
        isInUse: isInUse,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onGetCategoryUsageStats(
      GetCategoryUsageStatsEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final stats = await _categoryController.getCategoryUsageStats(
        event.userId,
        event.categoryId,
      );

      emit(CategoryUsageStatsLoaded(
        usageStats: stats,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onSearchCategories(
      SearchCategoriesEvent event,
      Emitter<CategoryState> emit,
      ) async {
    try {
      final results = _categoryController.suggestSimilarCategories(
        event.searchTerm,
        event.availableCategories,
      );

      emit(CategoriesSearchResults(
        results: results,
        searchTerm: event.searchTerm,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  Future<void> _onGetMostUsedCategories(
      GetMostUsedCategoriesEvent event,
      Emitter<CategoryState> emit,
      ) async {
    emit(const CategoryLoading());

    try {
      final categories = await _categoryController.getMostUsedCategories(
        event.userId,
        isIncome: event.isIncome,
        limit: event.limit,
      );

      emit(MostUsedCategoriesLoaded(
        categories: categories,
        isIncome: event.isIncome,
      ));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  // Getter di utilità
  bool get isLoading => state is CategoryLoading;
  bool get hasError => state is CategoryError;
  String? get errorMessage => state is CategoryError ? (state as CategoryError).message : null;

  // Helper per ottenere le categorie dall'ultimo stato caricato
  List<CategoryModel>? get currentCategories {
    if (state is DefaultCategoriesLoaded) {
      return (state as DefaultCategoriesLoaded).categories;
    } else if (state is CustomCategoriesLoaded) {
      return (state as CustomCategoriesLoaded).categories;
    } else if (state is AllUserCategoriesLoaded) {
      return (state as AllUserCategoriesLoaded).categories;
    } else if (state is CategoriesSearchResults) {
      return (state as CategoriesSearchResults).results;
    } else if (state is MostUsedCategoriesLoaded) {
      return (state as MostUsedCategoriesLoaded).categories;
    }
    return null;
  }
}