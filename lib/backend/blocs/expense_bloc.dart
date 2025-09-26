import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_model.dart';
import '../models/recurrence_model.dart';
import '../../core/errors/app_exceptions.dart';

// ==============================================================================
// EVENTI
// ==============================================================================

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class CreateExpenseEvent extends ExpenseEvent {
  final String userId;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime expenseDate;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;

  const CreateExpenseEvent({
    required this.userId,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.expenseDate,
    this.isRecurring = false,
    this.recurrenceSettings,
  });

  @override
  List<Object?> get props => [
    userId, amount, description, categoryId, expenseDate, isRecurring, recurrenceSettings
  ];
}

class LoadExpenseByIdEvent extends ExpenseEvent {
  final String userId;
  final String expenseId;

  const LoadExpenseByIdEvent({
    required this.userId,
    required this.expenseId,
  });

  @override
  List<Object?> get props => [userId, expenseId];
}

class LoadUserExpensesEvent extends ExpenseEvent {
  final String userId;
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final bool? isRecurring;
  final NecessityLevel? minNecessityLevel;

  const LoadUserExpensesEvent({
    required this.userId,
    this.limit,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.isRecurring,
    this.minNecessityLevel,
  });

  @override
  List<Object?> get props => [userId, limit, startDate, endDate, categoryId, isRecurring, minNecessityLevel];
}

class LoadCurrentMonthExpensesEvent extends ExpenseEvent {
  final String userId;

  const LoadCurrentMonthExpensesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadCurrentWeekExpensesEvent extends ExpenseEvent {
  final String userId;

  const LoadCurrentWeekExpensesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadActiveRecurringExpensesEvent extends ExpenseEvent {
  final String userId;

  const LoadActiveRecurringExpensesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadExpensesByCategoryEvent extends ExpenseEvent {
  final String userId;
  final String categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadExpensesByCategoryEvent({
    required this.userId,
    required this.categoryId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, categoryId, startDate, endDate];
}

class LoadHighPriorityExpensesEvent extends ExpenseEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadHighPriorityExpensesEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadTopExpensesByAmountEvent extends ExpenseEvent {
  final String userId;
  final int limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadTopExpensesByAmountEvent({
    required this.userId,
    required this.limit,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, limit, startDate, endDate];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final String userId;
  final String expenseId;
  final double? amount;
  final String? description;
  final String? categoryId;
  final DateTime? expenseDate;
  final bool? isRecurring;
  final RecurrenceSettings? recurrenceSettings;

  const UpdateExpenseEvent({
    required this.userId,
    required this.expenseId,
    this.amount,
    this.description,
    this.categoryId,
    this.expenseDate,
    this.isRecurring,
    this.recurrenceSettings,
  });

  @override
  List<Object?> get props => [
    userId, expenseId, amount, description, categoryId, expenseDate, isRecurring, recurrenceSettings
  ];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String userId;
  final String expenseId;

  const DeleteExpenseEvent({
    required this.userId,
    required this.expenseId,
  });

  @override
  List<Object?> get props => [userId, expenseId];
}

class DuplicateExpenseEvent extends ExpenseEvent {
  final String userId;
  final String expenseId;
  final DateTime? newDate;
  final double? newAmount;

  const DuplicateExpenseEvent({
    required this.userId,
    required this.expenseId,
    this.newDate,
    this.newAmount,
  });

  @override
  List<Object?> get props => [userId, expenseId, newDate, newAmount];
}

// Eventi per statistiche
class LoadExpenseTotalForPeriodEvent extends ExpenseEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpenseTotalForPeriodEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadExpenseStatsByCategoryEvent extends ExpenseEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadExpenseStatsByCategoryEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadExpenseStatsByNecessityEvent extends ExpenseEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadExpenseStatsByNecessityEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadMonthlyExpenseAverageEvent extends ExpenseEvent {
  final String userId;
  final int monthsCount;

  const LoadMonthlyExpenseAverageEvent({
    required this.userId,
    this.monthsCount = 12,
  });

  @override
  List<Object?> get props => [userId, monthsCount];
}

class LoadCurrentMonthExpensesSummaryEvent extends ExpenseEvent {
  final String userId;
  final double? monthlyBudget;

  const LoadCurrentMonthExpensesSummaryEvent({
    required this.userId,
    this.monthlyBudget,
  });

  @override
  List<Object?> get props => [userId, monthlyBudget];
}

// Eventi per budget
class CheckBudgetExceededEvent extends ExpenseEvent {
  final String userId;
  final double monthlyBudget;

  const CheckBudgetExceededEvent({
    required this.userId,
    required this.monthlyBudget,
  });

  @override
  List<Object?> get props => [userId, monthlyBudget];
}

class LoadRemainingBudgetEvent extends ExpenseEvent {
  final String userId;
  final double monthlyBudget;

  const LoadRemainingBudgetEvent({
    required this.userId,
    required this.monthlyBudget,
  });

  @override
  List<Object?> get props => [userId, monthlyBudget];
}

class SuggestOptimalBudgetEvent extends ExpenseEvent {
  final String userId;
  final int monthsToAnalyze;

  const SuggestOptimalBudgetEvent({
    required this.userId,
    this.monthsToAnalyze = 6,
  });

  @override
  List<Object?> get props => [userId, monthsToAnalyze];
}

class LoadCurrentMonthBudgetStatusEvent extends ExpenseEvent {
  final String userId;
  final double monthlyBudget;

  const LoadCurrentMonthBudgetStatusEvent({
    required this.userId,
    required this.monthlyBudget,
  });

  @override
  List<Object?> get props => [userId, monthlyBudget];
}

// Eventi per ricorrenze
class GenerateRecurringExpensesEvent extends ExpenseEvent {
  final String userId;

  const GenerateRecurringExpensesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateRecurrenceSettingsExpensesEvent extends ExpenseEvent {
  final String userId;
  final String expenseId;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;

  const UpdateRecurrenceSettingsExpensesEvent({
    required this.userId,
    required this.expenseId,
    required this.isRecurring,
    this.recurrenceSettings,
  });

  @override
  List<Object?> get props => [userId, expenseId, isRecurring, recurrenceSettings];
}

// Eventi per stream
class StartExpensesStreamEvent extends ExpenseEvent {
  final String userId;
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const StartExpensesStreamEvent({
    required this.userId,
    this.limit,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, limit, startDate, endDate];
}

class StartCurrentMonthExpensesStreamEvent extends ExpenseEvent {
  final String userId;

  const StartCurrentMonthExpensesStreamEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StopExpensesStreamEvent extends ExpenseEvent {
  const StopExpensesStreamEvent();
}

// ==============================================================================
// STATI
// ==============================================================================

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Stati per spese singole
class ExpenseByIdLoaded extends ExpenseState {
  final ExpenseModel? expense;
  final String expenseId;

  const ExpenseByIdLoaded({
    required this.expense,
    required this.expenseId,
  });

  @override
  List<Object?> get props => [expense, expenseId];
}

// Stati per liste di spese
class UserExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const UserExpensesLoaded({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class CurrentMonthExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const CurrentMonthExpensesLoaded({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class CurrentWeekExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const CurrentWeekExpensesLoaded({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class ActiveRecurringExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const ActiveRecurringExpensesLoaded({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class ExpensesByCategoryLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String categoryId;

  const ExpensesByCategoryLoaded({
    required this.expenses,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [expenses, categoryId];
}

class HighPriorityExpensesLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const HighPriorityExpensesLoaded({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class TopExpensesByAmountLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final int limit;

  const TopExpensesByAmountLoaded({
    required this.expenses,
    required this.limit,
  });

  @override
  List<Object?> get props => [expenses, limit];
}

// Stati per operazioni CRUD
class ExpenseCreated extends ExpenseState {
  final ExpenseModel expense;

  const ExpenseCreated({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class ExpenseUpdated extends ExpenseState {
  final ExpenseModel expense;

  const ExpenseUpdated({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class ExpenseDeleted extends ExpenseState {
  final String expenseId;

  const ExpenseDeleted({required this.expenseId});

  @override
  List<Object?> get props => [expenseId];
}

class ExpenseDuplicated extends ExpenseState {
  final ExpenseModel originalExpense;
  final ExpenseModel duplicatedExpense;

  const ExpenseDuplicated({
    required this.originalExpense,
    required this.duplicatedExpense,
  });

  @override
  List<Object?> get props => [originalExpense, duplicatedExpense];
}

// Stati per statistiche
class ExpenseTotalForPeriodLoaded extends ExpenseState {
  final double total;
  final DateTime startDate;
  final DateTime endDate;

  const ExpenseTotalForPeriodLoaded({
    required this.total,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [total, startDate, endDate];
}

class ExpenseStatsByCategoryLoaded extends ExpenseState {
  final Map<String, double> stats;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseStatsByCategoryLoaded({
    required this.stats,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [stats, startDate, endDate];
}

class ExpenseStatsByNecessityLoaded extends ExpenseState {
  final Map<NecessityLevel, double> stats;
  final DateTime? startDate;
  final DateTime? endDate;

  const ExpenseStatsByNecessityLoaded({
    required this.stats,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [stats, startDate, endDate];
}

class MonthlyExpenseAverageLoaded extends ExpenseState {
  final double average;
  final int monthsCount;

  const MonthlyExpenseAverageLoaded({
    required this.average,
    required this.monthsCount,
  });

  @override
  List<Object?> get props => [average, monthsCount];
}

class CurrentMonthExpensesSummaryLoaded extends ExpenseState {
  final Map<String, dynamic> summary;

  const CurrentMonthExpensesSummaryLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

// Stati per budget
class BudgetExceededChecked extends ExpenseState {
  final bool isExceeded;
  final double monthlyBudget;

  const BudgetExceededChecked({
    required this.isExceeded,
    required this.monthlyBudget,
  });

  @override
  List<Object?> get props => [isExceeded, monthlyBudget];
}

class RemainingBudgetLoaded extends ExpenseState {
  final double remainingBudget;
  final double monthlyBudget;

  const RemainingBudgetLoaded({
    required this.remainingBudget,
    required this.monthlyBudget,
  });

  @override
  List<Object?> get props => [remainingBudget, monthlyBudget];
}

class OptimalBudgetSuggested extends ExpenseState {
  final double suggestedBudget;
  final int monthsAnalyzed;

  const OptimalBudgetSuggested({
    required this.suggestedBudget,
    required this.monthsAnalyzed,
  });

  @override
  List<Object?> get props => [suggestedBudget, monthsAnalyzed];
}

class CurrentMonthBudgetStatusLoaded extends ExpenseState {
  final Map<String, double> budgetStatus;

  const CurrentMonthBudgetStatusLoaded({required this.budgetStatus});

  @override
  List<Object?> get props => [budgetStatus];
}

// Stati per ricorrenze
class RecurringExpensesGenerated extends ExpenseState {
  final List<ExpenseModel> newExpenses;

  const RecurringExpensesGenerated({required this.newExpenses});

  @override
  List<Object?> get props => [newExpenses];
}

class RecurrenceSettingsExpensesUpdated extends ExpenseState {
  final ExpenseModel expense;

  const RecurrenceSettingsExpensesUpdated({required this.expense});

  @override
  List<Object?> get props => [expense];
}

// Stati per stream
class ExpensesStreamActive extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const ExpensesStreamActive({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class CurrentMonthExpensesStreamActive extends ExpenseState {
  final List<ExpenseModel> expenses;
  final String userId;

  const CurrentMonthExpensesStreamActive({
    required this.expenses,
    required this.userId,
  });

  @override
  List<Object?> get props => [expenses, userId];
}

class ExpensesStreamStopped extends ExpenseState {
  const ExpensesStreamStopped();
}

// ==============================================================================
// BLOC
// ==============================================================================

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseController _expenseController;

  ExpenseBloc({ExpenseController? expenseController})
      : _expenseController = expenseController ?? ExpenseController(),
        super(const ExpenseInitial()) {

    // Operazioni CRUD
    on<CreateExpenseEvent>(_onCreateExpense);
    on<LoadExpenseByIdEvent>(_onLoadExpenseById);
    on<LoadUserExpensesEvent>(_onLoadUserExpenses);
    on<LoadCurrentMonthExpensesEvent>(_onLoadCurrentMonthExpenses);
    on<LoadCurrentWeekExpensesEvent>(_onLoadCurrentWeekExpenses);
    on<LoadActiveRecurringExpensesEvent>(_onLoadActiveRecurringExpenses);
    on<LoadExpensesByCategoryEvent>(_onLoadExpensesByCategory);
    on<LoadHighPriorityExpensesEvent>(_onLoadHighPriorityExpenses);
    on<LoadTopExpensesByAmountEvent>(_onLoadTopExpensesByAmount);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<DuplicateExpenseEvent>(_onDuplicateExpense);

    // Statistiche
    on<LoadExpenseTotalForPeriodEvent>(_onLoadExpenseTotalForPeriod);
    on<LoadExpenseStatsByCategoryEvent>(_onLoadExpenseStatsByCategory);
    on<LoadExpenseStatsByNecessityEvent>(_onLoadExpenseStatsByNecessity);
    on<LoadMonthlyExpenseAverageEvent>(_onLoadMonthlyExpenseAverage);
    on<LoadCurrentMonthExpensesSummaryEvent>(_onLoadCurrentMonthSummary);

    // Budget
    on<CheckBudgetExceededEvent>(_onCheckBudgetExceeded);
    on<LoadRemainingBudgetEvent>(_onLoadRemainingBudget);
    on<SuggestOptimalBudgetEvent>(_onSuggestOptimalBudget);
    on<LoadCurrentMonthBudgetStatusEvent>(_onLoadCurrentMonthBudgetStatus);

    // Ricorrenze
    on<GenerateRecurringExpensesEvent>(_onGenerateRecurringExpenses);
    on<UpdateRecurrenceSettingsExpensesEvent>(_onUpdateRecurrenceSettings);

    // Stream
    on<StartExpensesStreamEvent>(_onStartExpensesStream);
    on<StartCurrentMonthExpensesStreamEvent>(_onStartCurrentMonthExpensesStream);
    on<StopExpensesStreamEvent>(_onStopExpensesStream);
  }

  // ==============================================================================
  // HANDLERS EVENTI CRUD
  // ==============================================================================

  Future<void> _onCreateExpense(
      CreateExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expense = await _expenseController.createExpense(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        categoryId: event.categoryId,
        expenseDate: event.expenseDate,
        isRecurring: event.isRecurring,
        recurrenceSettings: event.recurrenceSettings,
      );

      emit(ExpenseCreated(expense: expense));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadExpenseById(
      LoadExpenseByIdEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expense = await _expenseController.getExpenseById(event.userId, event.expenseId);

      emit(ExpenseByIdLoaded(
        expense: expense,
        expenseId: event.expenseId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserExpenses(
      LoadUserExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getUserExpenses(
        event.userId,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
        categoryId: event.categoryId,
        isRecurring: event.isRecurring,
        minNecessityLevel: event.minNecessityLevel,
      );

      emit(UserExpensesLoaded(
        expenses: expenses,
        userId: event.userId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentMonthExpenses(
      LoadCurrentMonthExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getCurrentMonthExpenses(event.userId);

      emit(CurrentMonthExpensesLoaded(
        expenses: expenses,
        userId: event.userId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentWeekExpenses(
      LoadCurrentWeekExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getCurrentWeekExpenses(event.userId);

      emit(CurrentWeekExpensesLoaded(
        expenses: expenses,
        userId: event.userId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadActiveRecurringExpenses(
      LoadActiveRecurringExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getActiveRecurringExpenses(event.userId);

      emit(ActiveRecurringExpensesLoaded(
        expenses: expenses,
        userId: event.userId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadExpensesByCategory(
      LoadExpensesByCategoryEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getExpensesByCategory(
        event.userId,
        event.categoryId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(ExpensesByCategoryLoaded(
        expenses: expenses,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadHighPriorityExpenses(
      LoadHighPriorityExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getHighPriorityExpenses(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(HighPriorityExpensesLoaded(
        expenses: expenses,
        userId: event.userId,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadTopExpensesByAmount(
      LoadTopExpensesByAmountEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expenses = await _expenseController.getTopExpensesByAmount(
        event.userId,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(TopExpensesByAmountLoaded(
        expenses: expenses,
        limit: event.limit,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expense = await _expenseController.updateExpense(
        userId: event.userId,
        expenseId: event.expenseId,
        amount: event.amount,
        description: event.description,
        categoryId: event.categoryId,
        expenseDate: event.expenseDate,
        isRecurring: event.isRecurring,
        recurrenceSettings: event.recurrenceSettings,
      );

      emit(ExpenseUpdated(expense: expense));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      await _expenseController.deleteExpense(event.userId, event.expenseId);
      emit(ExpenseDeleted(expenseId: event.expenseId));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onDuplicateExpense(
      DuplicateExpenseEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final originalExpense = await _expenseController.getExpenseById(event.userId, event.expenseId);
      if (originalExpense == null) {
        emit(const ExpenseError(message: 'Spesa originale non trovata'));
        return;
      }

      final duplicatedExpense = await _expenseController.duplicateExpense(
        event.userId,
        event.expenseId,
        newDate: event.newDate,
        newAmount: event.newAmount,
      );

      emit(ExpenseDuplicated(
        originalExpense: originalExpense,
        duplicatedExpense: duplicatedExpense,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI STATISTICHE
  // ==============================================================================

  Future<void> _onLoadExpenseTotalForPeriod(
      LoadExpenseTotalForPeriodEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final total = await _expenseController.getTotalExpenseForPeriod(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(ExpenseTotalForPeriodLoaded(
        total: total,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadExpenseStatsByCategory(
      LoadExpenseStatsByCategoryEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final stats = await _expenseController.getExpenseStatsByCategory(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(ExpenseStatsByCategoryLoaded(
        stats: stats,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadExpenseStatsByNecessity(
      LoadExpenseStatsByNecessityEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final stats = await _expenseController.getExpenseStatsByNecessityLevel(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(ExpenseStatsByNecessityLoaded(
        stats: stats,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyExpenseAverage(
      LoadMonthlyExpenseAverageEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final average = await _expenseController.getMonthlyExpenseAverage(
        event.userId,
        monthsCount: event.monthsCount,
      );

      emit(MonthlyExpenseAverageLoaded(
        average: average,
        monthsCount: event.monthsCount,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentMonthSummary(
      LoadCurrentMonthExpensesSummaryEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final summary = await _expenseController.getCurrentMonthSummary(
        event.userId,
        monthlyBudget: event.monthlyBudget,
      );

      emit(CurrentMonthExpensesSummaryLoaded(summary: summary));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI BUDGET
  // ==============================================================================

  Future<void> _onCheckBudgetExceeded(
      CheckBudgetExceededEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final isExceeded = await _expenseController.isBudgetExceeded(
        event.userId,
        event.monthlyBudget,
      );

      emit(BudgetExceededChecked(
        isExceeded: isExceeded,
        monthlyBudget: event.monthlyBudget,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadRemainingBudget(
      LoadRemainingBudgetEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final remaining = await _expenseController.getRemainingBudget(
        event.userId,
        event.monthlyBudget,
      );

      emit(RemainingBudgetLoaded(
        remainingBudget: remaining,
        monthlyBudget: event.monthlyBudget,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onSuggestOptimalBudget(
      SuggestOptimalBudgetEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final suggested = await _expenseController.suggestOptimalBudget(
        event.userId,
        monthsToAnalyze: event.monthsToAnalyze,
      );

      emit(OptimalBudgetSuggested(
        suggestedBudget: suggested,
        monthsAnalyzed: event.monthsToAnalyze,
      ));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentMonthBudgetStatus(
      LoadCurrentMonthBudgetStatusEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final status = await _expenseController.getCurrentMonthBudgetStatus(
        event.userId,
        event.monthlyBudget,
      );

      emit(CurrentMonthBudgetStatusLoaded(budgetStatus: status));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI RICORRENZE
  // ==============================================================================

  Future<void> _onGenerateRecurringExpenses(
      GenerateRecurringExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final newExpenses = await _expenseController.generateRecurringExpenses(event.userId);
      emit(RecurringExpensesGenerated(newExpenses: newExpenses));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRecurrenceSettings(
      UpdateRecurrenceSettingsExpensesEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpenseLoading());

    try {
      final expense = await _expenseController.updateRecurrenceSettings(
        userId: event.userId,
        expenseId: event.expenseId,
        isRecurring: event.isRecurring,
        recurrenceSettings: event.recurrenceSettings,
      );

      emit(RecurrenceSettingsExpensesUpdated(expense: expense));
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI STREAM
  // ==============================================================================

  Future<void> _onStartExpensesStream(
      StartExpensesStreamEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    try {
      await emit.forEach(
        _expenseController.getUserExpensesStream(
          event.userId,
          limit: event.limit,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
        onData: (expenses) => ExpensesStreamActive(
          expenses: expenses,
          userId: event.userId,
        ),
        onError: (error, stackTrace) => ExpenseError(message: error.toString()),
      );
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onStartCurrentMonthExpensesStream(
      StartCurrentMonthExpensesStreamEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    try {
      await emit.forEach(
        _expenseController.getCurrentMonthExpensesStream(event.userId),
        onData: (expenses) => CurrentMonthExpensesStreamActive(
          expenses: expenses,
          userId: event.userId,
        ),
        onError: (error, stackTrace) => ExpenseError(message: error.toString()),
      );
    } catch (e) {
      emit(ExpenseError(message: e.toString()));
    }
  }

  Future<void> _onStopExpensesStream(
      StopExpensesStreamEvent event,
      Emitter<ExpenseState> emit,
      ) async {
    emit(const ExpensesStreamStopped());
  }

  // ==============================================================================
  // GETTER DI UTILITÀ
  // ==============================================================================

  bool get isLoading => state is ExpenseLoading;
  bool get hasError => state is ExpenseError;
  String? get errorMessage => state is ExpenseError ? (state as ExpenseError).message : null;

  List<ExpenseModel>? get currentExpenses {
    if (state is UserExpensesLoaded) {
      return (state as UserExpensesLoaded).expenses;
    } else if (state is CurrentMonthExpensesLoaded) {
      return (state as CurrentMonthExpensesLoaded).expenses;
    } else if (state is CurrentWeekExpensesLoaded) {
      return (state as CurrentWeekExpensesLoaded).expenses;
    } else if (state is ActiveRecurringExpensesLoaded) {
      return (state as ActiveRecurringExpensesLoaded).expenses;
    } else if (state is ExpensesByCategoryLoaded) {
      return (state as ExpensesByCategoryLoaded).expenses;
    } else if (state is HighPriorityExpensesLoaded) {
      return (state as HighPriorityExpensesLoaded).expenses;
    } else if (state is TopExpensesByAmountLoaded) {
      return (state as TopExpensesByAmountLoaded).expenses;
    } else if (state is ExpensesStreamActive) {
      return (state as ExpensesStreamActive).expenses;
    } else if (state is CurrentMonthExpensesStreamActive) {
      return (state as CurrentMonthExpensesStreamActive).expenses;
    }
    return null;
  }

  double? get currentTotal {
    if (state is ExpenseTotalForPeriodLoaded) {
      return (state as ExpenseTotalForPeriodLoaded).total;
    }
    return null;
  }

  Map<String, double>? get currentStatsByCategory {
    if (state is ExpenseStatsByCategoryLoaded) {
      return (state as ExpenseStatsByCategoryLoaded).stats;
    }
    return null;
  }

  Map<String, double>? get currentBudgetStatus {
    if (state is CurrentMonthBudgetStatusLoaded) {
      return (state as CurrentMonthBudgetStatusLoaded).budgetStatus;
    }
    return null;
  }

  Map<String, dynamic>? get currentMonthSummary {
    if (state is CurrentMonthExpensesSummaryLoaded) {
      return (state as CurrentMonthExpensesSummaryLoaded).summary;
    }
    return null;
  }
}