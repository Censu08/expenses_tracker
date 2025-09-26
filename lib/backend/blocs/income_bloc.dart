import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../controllers/income_controller.dart';
import '../models/income_model.dart';
import '../models/recurrence_model.dart';
import '../../core/errors/app_exceptions.dart';

// ==============================================================================
// EVENTI
// ==============================================================================

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

class CreateIncomeEvent extends IncomeEvent {
  final String userId;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime incomeDate;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;

  const CreateIncomeEvent({
    required this.userId,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.incomeDate,
    this.isRecurring = false,
    this.recurrenceSettings,
  });

  @override
  List<Object?> get props => [
    userId, amount, description, categoryId, incomeDate, isRecurring, recurrenceSettings
  ];
}

class LoadIncomeByIdEvent extends IncomeEvent {
  final String userId;
  final String incomeId;

  const LoadIncomeByIdEvent({
    required this.userId,
    required this.incomeId,
  });

  @override
  List<Object?> get props => [userId, incomeId];
}

class LoadUserIncomesEvent extends IncomeEvent {
  final String userId;
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final bool? isRecurring;

  const LoadUserIncomesEvent({
    required this.userId,
    this.limit,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.isRecurring,
  });

  @override
  List<Object?> get props => [userId, limit, startDate, endDate, categoryId, isRecurring];
}

class LoadCurrentMonthIncomesEvent extends IncomeEvent {
  final String userId;

  const LoadCurrentMonthIncomesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadCurrentWeekIncomesEvent extends IncomeEvent {
  final String userId;

  const LoadCurrentWeekIncomesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadActiveRecurringIncomesEvent extends IncomeEvent {
  final String userId;

  const LoadActiveRecurringIncomesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadIncomesByCategoryEvent extends IncomeEvent {
  final String userId;
  final String categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadIncomesByCategoryEvent({
    required this.userId,
    required this.categoryId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, categoryId, startDate, endDate];
}

class UpdateIncomeEvent extends IncomeEvent {
  final String userId;
  final String incomeId;
  final double? amount;
  final String? description;
  final String? categoryId;
  final DateTime? incomeDate;
  final bool? isRecurring;
  final RecurrenceSettings? recurrenceSettings;

  const UpdateIncomeEvent({
    required this.userId,
    required this.incomeId,
    this.amount,
    this.description,
    this.categoryId,
    this.incomeDate,
    this.isRecurring,
    this.recurrenceSettings,
  });

  @override
  List<Object?> get props => [
    userId, incomeId, amount, description, categoryId, incomeDate, isRecurring, recurrenceSettings
  ];
}

class DeleteIncomeEvent extends IncomeEvent {
  final String userId;
  final String incomeId;

  const DeleteIncomeEvent({
    required this.userId,
    required this.incomeId,
  });

  @override
  List<Object?> get props => [userId, incomeId];
}

class DuplicateIncomeEvent extends IncomeEvent {
  final String userId;
  final String incomeId;
  final DateTime? newDate;
  final double? newAmount;

  const DuplicateIncomeEvent({
    required this.userId,
    required this.incomeId,
    this.newDate,
    this.newAmount,
  });

  @override
  List<Object?> get props => [userId, incomeId, newDate, newAmount];
}

// Eventi per statistiche
class LoadIncomeTotalForPeriodEvent extends IncomeEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadIncomeTotalForPeriodEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadIncomeStatsByCategoryEvent extends IncomeEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadIncomeStatsByCategoryEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadMonthlyIncomeAverageEvent extends IncomeEvent {
  final String userId;
  final int monthsCount;

  const LoadMonthlyIncomeAverageEvent({
    required this.userId,
    this.monthsCount = 12,
  });

  @override
  List<Object?> get props => [userId, monthsCount];
}

class LoadCurrentMonthSummaryEvent extends IncomeEvent {
  final String userId;

  const LoadCurrentMonthSummaryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Eventi per ricorrenze
class GenerateRecurringIncomesEvent extends IncomeEvent {
  final String userId;

  const GenerateRecurringIncomesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateRecurrenceSettingsEvent extends IncomeEvent {
  final String userId;
  final String incomeId;
  final bool isRecurring;
  final RecurrenceSettings? recurrenceSettings;

  const UpdateRecurrenceSettingsEvent({
    required this.userId,
    required this.incomeId,
    required this.isRecurring,
    this.recurrenceSettings,
  });

  @override
  List<Object?> get props => [userId, incomeId, isRecurring, recurrenceSettings];
}

// Eventi per stream
class StartIncomesStreamEvent extends IncomeEvent {
  final String userId;
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const StartIncomesStreamEvent({
    required this.userId,
    this.limit,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, limit, startDate, endDate];
}

class StartCurrentMonthIncomesStreamEvent extends IncomeEvent {
  final String userId;

  const StartCurrentMonthIncomesStreamEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StopIncomesStreamEvent extends IncomeEvent {
  const StopIncomesStreamEvent();
}

// ==============================================================================
// STATI
// ==============================================================================

abstract class IncomeState extends Equatable {
  const IncomeState();

  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

class IncomeError extends IncomeState {
  final String message;

  const IncomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Stati per entrate singole
class IncomeByIdLoaded extends IncomeState {
  final IncomeModel? income;
  final String incomeId;

  const IncomeByIdLoaded({
    required this.income,
    required this.incomeId,
  });

  @override
  List<Object?> get props => [income, incomeId];
}

// Stati per liste di entrate
class UserIncomesLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final String userId;

  const UserIncomesLoaded({
    required this.incomes,
    required this.userId,
  });

  @override
  List<Object?> get props => [incomes, userId];
}

class CurrentMonthIncomesLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final String userId;

  const CurrentMonthIncomesLoaded({
    required this.incomes,
    required this.userId,
  });

  @override
  List<Object?> get props => [incomes, userId];
}

class CurrentWeekIncomesLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final String userId;

  const CurrentWeekIncomesLoaded({
    required this.incomes,
    required this.userId,
  });

  @override
  List<Object?> get props => [incomes, userId];
}

class ActiveRecurringIncomesLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final String userId;

  const ActiveRecurringIncomesLoaded({
    required this.incomes,
    required this.userId,
  });

  @override
  List<Object?> get props => [incomes, userId];
}

class IncomesByCategoryLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final String categoryId;

  const IncomesByCategoryLoaded({
    required this.incomes,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [incomes, categoryId];
}

// Stati per operazioni CRUD
class IncomeCreated extends IncomeState {
  final IncomeModel income;

  const IncomeCreated({required this.income});

  @override
  List<Object?> get props => [income];
}

class IncomeUpdated extends IncomeState {
  final IncomeModel income;

  const IncomeUpdated({required this.income});

  @override
  List<Object?> get props => [income];
}

class IncomeDeleted extends IncomeState {
  final String incomeId;

  const IncomeDeleted({required this.incomeId});

  @override
  List<Object?> get props => [incomeId];
}

class IncomeDuplicated extends IncomeState {
  final IncomeModel originalIncome;
  final IncomeModel duplicatedIncome;

  const IncomeDuplicated({
    required this.originalIncome,
    required this.duplicatedIncome,
  });

  @override
  List<Object?> get props => [originalIncome, duplicatedIncome];
}

// Stati per statistiche
class IncomeTotalForPeriodLoaded extends IncomeState {
  final double total;
  final DateTime startDate;
  final DateTime endDate;

  const IncomeTotalForPeriodLoaded({
    required this.total,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [total, startDate, endDate];
}

class IncomeStatsByCategoryLoaded extends IncomeState {
  final Map<String, double> stats;
  final DateTime? startDate;
  final DateTime? endDate;

  const IncomeStatsByCategoryLoaded({
    required this.stats,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [stats, startDate, endDate];
}

class MonthlyIncomeAverageLoaded extends IncomeState {
  final double average;
  final int monthsCount;

  const MonthlyIncomeAverageLoaded({
    required this.average,
    required this.monthsCount,
  });

  @override
  List<Object?> get props => [average, monthsCount];
}

class CurrentMonthSummaryLoaded extends IncomeState {
  final Map<String, dynamic> summary;

  const CurrentMonthSummaryLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

// Stati per ricorrenze
class RecurringIncomesGenerated extends IncomeState {
  final List<IncomeModel> newIncomes;

  const RecurringIncomesGenerated({required this.newIncomes});

  @override
  List<Object?> get props => [newIncomes];
}

class RecurrenceSettingsUpdated extends IncomeState {
  final IncomeModel income;

  const RecurrenceSettingsUpdated({required this.income});

  @override
  List<Object?> get props => [income];
}

// Stati per stream
class IncomesStreamActive extends IncomeState {
  final List<IncomeModel> incomes;
  final String userId;

  const IncomesStreamActive({
    required this.incomes,
    required this.userId,
  });

  @override
  List<Object?> get props => [incomes, userId];
}

class CurrentMonthIncomesStreamActive extends IncomeState {
  final List<IncomeModel> incomes;
  final String userId;

  const CurrentMonthIncomesStreamActive({
    required this.incomes,
    required this.userId,
  });

  @override
  List<Object?> get props => [incomes, userId];
}

class IncomesStreamStopped extends IncomeState {
  const IncomesStreamStopped();
}

// ==============================================================================
// BLOC
// ==============================================================================

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final IncomeController _incomeController;

  IncomeBloc({IncomeController? incomeController})
      : _incomeController = incomeController ?? IncomeController(),
        super(const IncomeInitial()) {

    // Operazioni CRUD
    on<CreateIncomeEvent>(_onCreateIncome);
    on<LoadIncomeByIdEvent>(_onLoadIncomeById);
    on<LoadUserIncomesEvent>(_onLoadUserIncomes);
    on<LoadCurrentMonthIncomesEvent>(_onLoadCurrentMonthIncomes);
    on<LoadCurrentWeekIncomesEvent>(_onLoadCurrentWeekIncomes);
    on<LoadActiveRecurringIncomesEvent>(_onLoadActiveRecurringIncomes);
    on<LoadIncomesByCategoryEvent>(_onLoadIncomesByCategory);
    on<UpdateIncomeEvent>(_onUpdateIncome);
    on<DeleteIncomeEvent>(_onDeleteIncome);
    on<DuplicateIncomeEvent>(_onDuplicateIncome);

    // Statistiche
    on<LoadIncomeTotalForPeriodEvent>(_onLoadIncomeTotalForPeriod);
    on<LoadIncomeStatsByCategoryEvent>(_onLoadIncomeStatsByCategory);
    on<LoadMonthlyIncomeAverageEvent>(_onLoadMonthlyIncomeAverage);
    on<LoadCurrentMonthSummaryEvent>(_onLoadCurrentMonthSummary);

    // Ricorrenze
    on<GenerateRecurringIncomesEvent>(_onGenerateRecurringIncomes);
    on<UpdateRecurrenceSettingsEvent>(_onUpdateRecurrenceSettings);

    // Stream
    on<StartIncomesStreamEvent>(_onStartIncomesStream);
    on<StartCurrentMonthIncomesStreamEvent>(_onStartCurrentMonthIncomesStream);
    on<StopIncomesStreamEvent>(_onStopIncomesStream);
  }

  // ==============================================================================
  // HANDLERS EVENTI CRUD
  // ==============================================================================

  Future<void> _onCreateIncome(
      CreateIncomeEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final income = await _incomeController.createIncome(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        categoryId: event.categoryId,
        incomeDate: event.incomeDate,
        isRecurring: event.isRecurring,
        recurrenceSettings: event.recurrenceSettings,
      );

      emit(IncomeCreated(income: income));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadIncomeById(
      LoadIncomeByIdEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final income = await _incomeController.getIncomeById(event.userId, event.incomeId);

      emit(IncomeByIdLoaded(
        income: income,
        incomeId: event.incomeId,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserIncomes(
      LoadUserIncomesEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final incomes = await _incomeController.getUserIncomes(
        event.userId,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
        categoryId: event.categoryId,
        isRecurring: event.isRecurring,
      );

      emit(UserIncomesLoaded(
        incomes: incomes,
        userId: event.userId,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentMonthIncomes(
      LoadCurrentMonthIncomesEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final incomes = await _incomeController.getCurrentMonthIncomes(event.userId);

      emit(CurrentMonthIncomesLoaded(
        incomes: incomes,
        userId: event.userId,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentWeekIncomes(
      LoadCurrentWeekIncomesEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final incomes = await _incomeController.getCurrentWeekIncomes(event.userId);

      emit(CurrentWeekIncomesLoaded(
        incomes: incomes,
        userId: event.userId,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadActiveRecurringIncomes(
      LoadActiveRecurringIncomesEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final incomes = await _incomeController.getActiveRecurringIncomes(event.userId);

      emit(ActiveRecurringIncomesLoaded(
        incomes: incomes,
        userId: event.userId,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadIncomesByCategory(
      LoadIncomesByCategoryEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final incomes = await _incomeController.getIncomesByCategory(
        event.userId,
        event.categoryId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(IncomesByCategoryLoaded(
        incomes: incomes,
        categoryId: event.categoryId,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onUpdateIncome(
      UpdateIncomeEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final income = await _incomeController.updateIncome(
        userId: event.userId,
        incomeId: event.incomeId,
        amount: event.amount,
        description: event.description,
        categoryId: event.categoryId,
        incomeDate: event.incomeDate,
        isRecurring: event.isRecurring,
        recurrenceSettings: event.recurrenceSettings,
      );

      emit(IncomeUpdated(income: income));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onDeleteIncome(
      DeleteIncomeEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      await _incomeController.deleteIncome(event.userId, event.incomeId);
      emit(IncomeDeleted(incomeId: event.incomeId));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onDuplicateIncome(
      DuplicateIncomeEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final originalIncome = await _incomeController.getIncomeById(event.userId, event.incomeId);
      if (originalIncome == null) {
        emit(const IncomeError(message: 'Entrata originale non trovata'));
        return;
      }

      final duplicatedIncome = await _incomeController.duplicateIncome(
        event.userId,
        event.incomeId,
        newDate: event.newDate,
        newAmount: event.newAmount,
      );

      emit(IncomeDuplicated(
        originalIncome: originalIncome,
        duplicatedIncome: duplicatedIncome,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI STATISTICHE
  // ==============================================================================

  Future<void> _onLoadIncomeTotalForPeriod(
      LoadIncomeTotalForPeriodEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final total = await _incomeController.getTotalIncomeForPeriod(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(IncomeTotalForPeriodLoaded(
        total: total,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadIncomeStatsByCategory(
      LoadIncomeStatsByCategoryEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final stats = await _incomeController.getIncomeStatsByCategory(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(IncomeStatsByCategoryLoaded(
        stats: stats,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyIncomeAverage(
      LoadMonthlyIncomeAverageEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final average = await _incomeController.getMonthlyIncomeAverage(
        event.userId,
        monthsCount: event.monthsCount,
      );

      emit(MonthlyIncomeAverageLoaded(
        average: average,
        monthsCount: event.monthsCount,
      ));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentMonthSummary(
      LoadCurrentMonthSummaryEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final summary = await _incomeController.getCurrentMonthSummary(event.userId);
      emit(CurrentMonthSummaryLoaded(summary: summary));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI RICORRENZE
  // ==============================================================================

  Future<void> _onGenerateRecurringIncomes(
      GenerateRecurringIncomesEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final newIncomes = await _incomeController.generateRecurringIncomes(event.userId);
      emit(RecurringIncomesGenerated(newIncomes: newIncomes));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRecurrenceSettings(
      UpdateRecurrenceSettingsEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomeLoading());

    try {
      final income = await _incomeController.updateRecurrenceSettings(
        userId: event.userId,
        incomeId: event.incomeId,
        isRecurring: event.isRecurring,
        recurrenceSettings: event.recurrenceSettings,
      );

      emit(RecurrenceSettingsUpdated(income: income));
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI STREAM
  // ==============================================================================

  Future<void> _onStartIncomesStream(
      StartIncomesStreamEvent event,
      Emitter<IncomeState> emit,
      ) async {
    try {
      await emit.forEach(
        _incomeController.getUserIncomesStream(
          event.userId,
          limit: event.limit,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
        onData: (incomes) => IncomesStreamActive(
          incomes: incomes,
          userId: event.userId,
        ),
        onError: (error, stackTrace) => IncomeError(message: error.toString()),
      );
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onStartCurrentMonthIncomesStream(
      StartCurrentMonthIncomesStreamEvent event,
      Emitter<IncomeState> emit,
      ) async {
    try {
      await emit.forEach(
        _incomeController.getCurrentMonthIncomesStream(event.userId),
        onData: (incomes) => CurrentMonthIncomesStreamActive(
          incomes: incomes,
          userId: event.userId,
        ),
        onError: (error, stackTrace) => IncomeError(message: error.toString()),
      );
    } catch (e) {
      emit(IncomeError(message: e.toString()));
    }
  }

  Future<void> _onStopIncomesStream(
      StopIncomesStreamEvent event,
      Emitter<IncomeState> emit,
      ) async {
    emit(const IncomesStreamStopped());
  }

  // ==============================================================================
  // GETTER DI UTILITÀ
  // ==============================================================================

  bool get isLoading => state is IncomeLoading;
  bool get hasError => state is IncomeError;
  String? get errorMessage => state is IncomeError ? (state as IncomeError).message : null;

  List<IncomeModel>? get currentIncomes {
    if (state is UserIncomesLoaded) {
      return (state as UserIncomesLoaded).incomes;
    } else if (state is CurrentMonthIncomesLoaded) {
      return (state as CurrentMonthIncomesLoaded).incomes;
    } else if (state is CurrentWeekIncomesLoaded) {
      return (state as CurrentWeekIncomesLoaded).incomes;
    } else if (state is ActiveRecurringIncomesLoaded) {
      return (state as ActiveRecurringIncomesLoaded).incomes;
    } else if (state is IncomesByCategoryLoaded) {
      return (state as IncomesByCategoryLoaded).incomes;
    } else if (state is IncomesStreamActive) {
      return (state as IncomesStreamActive).incomes;
    } else if (state is CurrentMonthIncomesStreamActive) {
      return (state as CurrentMonthIncomesStreamActive).incomes;
    }
    return null;
  }

  double? get currentTotal {
    if (state is IncomeTotalForPeriodLoaded) {
      return (state as IncomeTotalForPeriodLoaded).total;
    }
    return null;
  }

  Map<String, double>? get currentStatsByCategory {
    if (state is IncomeStatsByCategoryLoaded) {
      return (state as IncomeStatsByCategoryLoaded).stats;
    }
    return null;
  }

  Map<String, dynamic>? get currentMonthSummary {
    if (state is CurrentMonthSummaryLoaded) {
      return (state as CurrentMonthSummaryLoaded).summary;
    }
    return null;
  }
}