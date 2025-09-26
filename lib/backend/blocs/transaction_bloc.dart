import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../controllers/transaction_controller.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../../core/errors/app_exceptions.dart';

// ==============================================================================
// EVENTI
// ==============================================================================

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllTransactionsEvent extends TransactionEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const LoadAllTransactionsEvent({
    required this.userId,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, limit];
}

class LoadNetBalanceForPeriodEvent extends TransactionEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadNetBalanceForPeriodEvent({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadCategoryStatsCompleteEvent extends TransactionEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadCategoryStatsCompleteEvent({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class LoadCurrentMonthTransactionsSummaryEvent extends TransactionEvent {
  final String userId;

  const LoadCurrentMonthTransactionsSummaryEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadDashboardDataEvent extends TransactionEvent {
  final String userId;
  final double? monthlyBudget;

  const LoadDashboardDataEvent({
    required this.userId,
    this.monthlyBudget,
  });

  @override
  List<Object?> get props => [userId, monthlyBudget];
}

class LoadMonthlyTrendsEvent extends TransactionEvent {
  final String userId;
  final int monthsCount;

  const LoadMonthlyTrendsEvent({
    required this.userId,
    this.monthsCount = 12,
  });

  @override
  List<Object?> get props => [userId, monthsCount];
}

class LoadCategoryComparisonEvent extends TransactionEvent {
  final String userId;
  final DateTime period1Start;
  final DateTime period1End;
  final DateTime period2Start;
  final DateTime period2End;

  const LoadCategoryComparisonEvent({
    required this.userId,
    required this.period1Start,
    required this.period1End,
    required this.period2Start,
    required this.period2End,
  });

  @override
  List<Object?> get props => [userId, period1Start, period1End, period2Start, period2End];
}

class CreateTransferEvent extends TransactionEvent {
  final String userId;
  final double amount;
  final String description;
  final String fromCategoryId;
  final String toCategoryId;
  final DateTime date;

  const CreateTransferEvent({
    required this.userId,
    required this.amount,
    required this.description,
    required this.fromCategoryId,
    required this.toCategoryId,
    required this.date,
  });

  @override
  List<Object?> get props => [userId, amount, description, fromCategoryId, toCategoryId, date];
}

class ExportAllUserDataEvent extends TransactionEvent {
  final String userId;

  const ExportAllUserDataEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteAllUserFinancialDataEvent extends TransactionEvent {
  final String userId;

  const DeleteAllUserFinancialDataEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadFinancialForecastEvent extends TransactionEvent {
  final String userId;
  final int forecastMonths;

  const LoadFinancialForecastEvent({
    required this.userId,
    this.forecastMonths = 3,
  });

  @override
  List<Object?> get props => [userId, forecastMonths];
}

class LoadFinancialAlertsEvent extends TransactionEvent {
  final String userId;
  final double? monthlyBudget;

  const LoadFinancialAlertsEvent({
    required this.userId,
    this.monthlyBudget,
  });

  @override
  List<Object?> get props => [userId, monthlyBudget];
}

// Eventi per stream
class StartCurrentMonthTransactionsStreamEvent extends TransactionEvent {
  final String userId;

  const StartCurrentMonthTransactionsStreamEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StopTransactionsStreamEvent extends TransactionEvent {
  const StopTransactionsStreamEvent();
}

// ==============================================================================
// STATI
// ==============================================================================

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Stati per transazioni
class AllTransactionsLoaded extends TransactionState {
  final List<dynamic> transactions;
  final String userId;

  const AllTransactionsLoaded({
    required this.transactions,
    required this.userId,
  });

  @override
  List<Object?> get props => [transactions, userId];
}

class NetBalanceForPeriodLoaded extends TransactionState {
  final Map<String, double> balance;
  final DateTime startDate;
  final DateTime endDate;

  const NetBalanceForPeriodLoaded({
    required this.balance,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [balance, startDate, endDate];
}

class CategoryStatsCompleteLoaded extends TransactionState {
  final Map<String, Map<String, double>> stats;
  final DateTime? startDate;
  final DateTime? endDate;

  const CategoryStatsCompleteLoaded({
    required this.stats,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [stats, startDate, endDate];
}

class CurrentMonthTransactionsSummaryLoaded extends TransactionState {
  final Map<String, dynamic> summary;

  const CurrentMonthTransactionsSummaryLoaded({required this.summary});

  @override
  List<Object?> get props => [summary];
}

class DashboardDataLoaded extends TransactionState {
  final Map<String, dynamic> dashboardData;

  const DashboardDataLoaded({required this.dashboardData});

  @override
  List<Object?> get props => [dashboardData];
}

class MonthlyTrendsLoaded extends TransactionState {
  final List<Map<String, dynamic>> trends;
  final int monthsCount;

  const MonthlyTrendsLoaded({
    required this.trends,
    required this.monthsCount,
  });

  @override
  List<Object?> get props => [trends, monthsCount];
}

class CategoryComparisonLoaded extends TransactionState {
  final Map<String, dynamic> comparison;

  const CategoryComparisonLoaded({required this.comparison});

  @override
  List<Object?> get props => [comparison];
}

class TransferCreated extends TransactionState {
  final Map<String, dynamic> transfer;

  const TransferCreated({required this.transfer});

  @override
  List<Object?> get props => [transfer];
}

class AllUserDataExported extends TransactionState {
  final Map<String, dynamic> exportData;

  const AllUserDataExported({required this.exportData});

  @override
  List<Object?> get props => [exportData];
}

class AllUserFinancialDataDeleted extends TransactionState {
  final String userId;

  const AllUserFinancialDataDeleted({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FinancialForecastLoaded extends TransactionState {
  final Map<String, dynamic> forecast;

  const FinancialForecastLoaded({required this.forecast});

  @override
  List<Object?> get props => [forecast];
}

class FinancialAlertsLoaded extends TransactionState {
  final List<Map<String, dynamic>> alerts;

  const FinancialAlertsLoaded({required this.alerts});

  @override
  List<Object?> get props => [alerts];
}

// Stati per stream
class CurrentMonthTransactionsStreamActive extends TransactionState {
  final List<dynamic> transactions;
  final String userId;

  const CurrentMonthTransactionsStreamActive({
    required this.transactions,
    required this.userId,
  });

  @override
  List<Object?> get props => [transactions, userId];
}

class TransactionsStreamStopped extends TransactionState {
  const TransactionsStreamStopped();
}

// ==============================================================================
// BLOC
// ==============================================================================

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionController _transactionController;

  TransactionBloc({TransactionController? transactionController})
      : _transactionController = transactionController ?? TransactionController(),
        super(const TransactionInitial()) {

    on<LoadAllTransactionsEvent>(_onLoadAllTransactions);
    on<LoadNetBalanceForPeriodEvent>(_onLoadNetBalanceForPeriod);
    on<LoadCategoryStatsCompleteEvent>(_onLoadCategoryStatsComplete);
    on<LoadCurrentMonthTransactionsSummaryEvent>(_onLoadCurrentMonthSummary);
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<LoadMonthlyTrendsEvent>(_onLoadMonthlyTrends);
    on<LoadCategoryComparisonEvent>(_onLoadCategoryComparison);
    on<CreateTransferEvent>(_onCreateTransfer);
    on<ExportAllUserDataEvent>(_onExportAllUserData);
    on<DeleteAllUserFinancialDataEvent>(_onDeleteAllUserFinancialData);
    on<LoadFinancialForecastEvent>(_onLoadFinancialForecast);
    on<LoadFinancialAlertsEvent>(_onLoadFinancialAlerts);
    on<StartCurrentMonthTransactionsStreamEvent>(_onStartCurrentMonthTransactionsStream);
    on<StopTransactionsStreamEvent>(_onStopTransactionsStream);
  }

  // ==============================================================================
  // HANDLERS EVENTI
  // ==============================================================================

  Future<void> _onLoadAllTransactions(
      LoadAllTransactionsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final transactions = await _transactionController.getAllTransactions(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      );

      emit(AllTransactionsLoaded(
        transactions: transactions,
        userId: event.userId,
      ));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadNetBalanceForPeriod(
      LoadNetBalanceForPeriodEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final balance = await _transactionController.getNetBalanceForPeriod(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(NetBalanceForPeriodLoaded(
        balance: balance,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadCategoryStatsComplete(
      LoadCategoryStatsCompleteEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final stats = await _transactionController.getCategoryStatsComplete(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(CategoryStatsCompleteLoaded(
        stats: stats,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadCurrentMonthSummary(
      LoadCurrentMonthTransactionsSummaryEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final summary = await _transactionController.getCurrentMonthSummary(event.userId);

      emit(CurrentMonthTransactionsSummaryLoaded(summary: summary));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardDataEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final dashboardData = await _transactionController.getDashboardData(
        event.userId,
        monthlyBudget: event.monthlyBudget,
      );

      emit(DashboardDataLoaded(dashboardData: dashboardData));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadMonthlyTrends(
      LoadMonthlyTrendsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final trends = await _transactionController.getMonthlyTrends(
        event.userId,
        monthsCount: event.monthsCount,
      );

      emit(MonthlyTrendsLoaded(
        trends: trends,
        monthsCount: event.monthsCount,
      ));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadCategoryComparison(
      LoadCategoryComparisonEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final comparison = await _transactionController.getCategoryComparison(
        event.userId,
        period1Start: event.period1Start,
        period1End: event.period1End,
        period2Start: event.period2Start,
        period2End: event.period2End,
      );

      emit(CategoryComparisonLoaded(comparison: comparison));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onCreateTransfer(
      CreateTransferEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final transfer = await _transactionController.createTransfer(
        userId: event.userId,
        amount: event.amount,
        description: event.description,
        fromCategoryId: event.fromCategoryId,
        toCategoryId: event.toCategoryId,
        date: event.date,
      );

      emit(TransferCreated(transfer: transfer));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onExportAllUserData(
      ExportAllUserDataEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final exportData = await _transactionController.exportAllUserData(event.userId);

      emit(AllUserDataExported(exportData: exportData));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAllUserFinancialData(
      DeleteAllUserFinancialDataEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      await _transactionController.deleteAllUserFinancialData(event.userId);

      emit(AllUserFinancialDataDeleted(userId: event.userId));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadFinancialForecast(
      LoadFinancialForecastEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final forecast = await _transactionController.getFinancialForecast(
        event.userId,
        forecastMonths: event.forecastMonths,
      );

      emit(FinancialForecastLoaded(forecast: forecast));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onLoadFinancialAlerts(
      LoadFinancialAlertsEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionLoading());

    try {
      final alerts = await _transactionController.getFinancialAlerts(
        event.userId,
        monthlyBudget: event.monthlyBudget,
      );

      emit(FinancialAlertsLoaded(alerts: alerts));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  // ==============================================================================
  // HANDLERS EVENTI STREAM
  // ==============================================================================

  Future<void> _onStartCurrentMonthTransactionsStream(
      StartCurrentMonthTransactionsStreamEvent event,
      Emitter<TransactionState> emit,
      ) async {
    try {
      await emit.forEach(
        _transactionController.getCurrentMonthTransactionsStream(event.userId),
        onData: (transactions) => CurrentMonthTransactionsStreamActive(
          transactions: transactions,
          userId: event.userId,
        ),
        onError: (error, stackTrace) => TransactionError(message: error.toString()),
      );
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onStopTransactionsStream(
      StopTransactionsStreamEvent event,
      Emitter<TransactionState> emit,
      ) async {
    emit(const TransactionsStreamStopped());
  }

  // ==============================================================================
  // GETTER DI UTILITÀ
  // ==============================================================================

  bool get isLoading => state is TransactionLoading;
  bool get hasError => state is TransactionError;
  String? get errorMessage => state is TransactionError ? (state as TransactionError).message : null;

  List<dynamic>? get currentTransactions {
    if (state is AllTransactionsLoaded) {
      return (state as AllTransactionsLoaded).transactions;
    } else if (state is CurrentMonthTransactionsStreamActive) {
      return (state as CurrentMonthTransactionsStreamActive).transactions;
    }
    return null;
  }

  Map<String, double>? get currentNetBalance {
    if (state is NetBalanceForPeriodLoaded) {
      return (state as NetBalanceForPeriodLoaded).balance;
    }
    return null;
  }

  Map<String, dynamic>? get currentDashboardData {
    if (state is DashboardDataLoaded) {
      return (state as DashboardDataLoaded).dashboardData;
    }
    return null;
  }

  Map<String, dynamic>? get currentMonthSummary {
    if (state is CurrentMonthTransactionsSummaryLoaded) {
      return (state as CurrentMonthTransactionsSummaryLoaded).summary;
    }
    return null;
  }

  List<Map<String, dynamic>>? get currentTrends {
    if (state is MonthlyTrendsLoaded) {
      return (state as MonthlyTrendsLoaded).trends;
    }
    return null;
  }

  Map<String, Map<String, double>>? get currentCategoryStats {
    if (state is CategoryStatsCompleteLoaded) {
      return (state as CategoryStatsCompleteLoaded).stats;
    }
    return null;
  }

  Map<String, dynamic>? get currentCategoryComparison {
    if (state is CategoryComparisonLoaded) {
      return (state as CategoryComparisonLoaded).comparison;
    }
    return null;
  }

  Map<String, dynamic>? get currentForecast {
    if (state is FinancialForecastLoaded) {
      return (state as FinancialForecastLoaded).forecast;
    }
    return null;
  }

  List<Map<String, dynamic>>? get currentAlerts {
    if (state is FinancialAlertsLoaded) {
      return (state as FinancialAlertsLoaded).alerts;
    }
    return null;
  }

  Map<String, dynamic>? get lastTransfer {
    if (state is TransferCreated) {
      return (state as TransferCreated).transfer;
    }
    return null;
  }

  Map<String, dynamic>? get lastExportData {
    if (state is AllUserDataExported) {
      return (state as AllUserDataExported).exportData;
    }
    return null;
  }

  // Helper per ottenere informazioni rapide dalla dashboard
  double? get currentMonthIncome {
    final dashboard = currentDashboardData;
    return dashboard?['current_period']?['monthly_balance']?['incomes'];
  }

  double? get currentMonthExpense {
    final dashboard = currentDashboardData;
    return dashboard?['current_period']?['monthly_balance']?['expenses'];
  }

  double? get currentMonthNetBalance {
    final dashboard = currentDashboardData;
    return dashboard?['current_period']?['monthly_balance']?['net_balance'];
  }

  double? get budgetPercentage {
    final dashboard = currentDashboardData;
    return dashboard?['summary_cards']?['budget_percentage'];
  }

  int get alertsCount {
    return currentAlerts?.length ?? 0;
  }

  List<Map<String, dynamic>> get highPriorityAlerts {
    return currentAlerts?.where((alert) => alert['severity'] == 'high').toList() ?? [];
  }

  bool get hasBudgetAlert {
    return currentAlerts?.any((alert) =>
    alert['type'] == 'budget_exceeded' || alert['type'] == 'budget_warning'
    ) ?? false;
  }
}