import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/blocs/blocs.dart';
import '../../backend/controllers/controllers.dart';

class BlocProvidersSetup extends StatelessWidget {
  final Widget child;

  const BlocProvidersSetup({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            categoryController: CategoryController(),
          ),
        ),
        BlocProvider<IncomeBloc>(
          create: (context) => IncomeBloc(
            incomeController: IncomeController(),
          ),
        ),
        BlocProvider<ExpenseBloc>(
          create: (context) => ExpenseBloc(
            expenseController: ExpenseController(),
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(
            transactionController: TransactionController(),
          ),
        ),
      ],
      child: child,
    );
  }
}

/// Extension per facilitare l'accesso ai BLoC dal BuildContext
extension BlocContextExtensions on BuildContext {
  // ============================================================================
  // BLOCS (per usare negli event handlers - usa read())
  // ============================================================================

  UserBloc get userBloc => read<UserBloc>();
  CategoryBloc get categoryBloc => read<CategoryBloc>();
  IncomeBloc get incomeBloc => read<IncomeBloc>();
  ExpenseBloc get expenseBloc => read<ExpenseBloc>();
  TransactionBloc get transactionBloc => read<TransactionBloc>();

  // ============================================================================
  // STATES (per usare nel build - usa watch())
  // ============================================================================

  UserState get userState => watch<UserBloc>().state;
  CategoryState get categoryState => watch<CategoryBloc>().state;
  IncomeState get incomeState => watch<IncomeBloc>().state;
  ExpenseState get expenseState => watch<ExpenseBloc>().state;
  TransactionState get transactionState => watch<TransactionBloc>().state;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Helper per ottenere l'utente corrente (usa read per evitare rebuild)
  /// Da usare SOLO negli event handlers, NON nel build method!
  String? get currentUserId {
    final state = read<UserBloc>().state;
    if (state is UserAuthenticated) {
      return state.user.id;
    }
    return null;
  }

  /// Versione watchable per usare nel build method
  String? get watchCurrentUserId {
    final state = watch<UserBloc>().state;
    if (state is UserAuthenticated) {
      return state.user.id;
    }
    return null;
  }

  bool get isUserAuthenticated {
    final state = read<UserBloc>().state;
    return state is UserAuthenticated;
  }

  /// Helper methods per verificare stati di loading comuni
  bool get isAnyBlocLoading =>
      read<UserBloc>().state is UserLoading ||
          read<CategoryBloc>().state is CategoryLoading ||
          read<IncomeBloc>().state is IncomeLoading ||
          read<ExpenseBloc>().state is ExpenseLoading ||
          read<TransactionBloc>().state is TransactionLoading;

  bool get hasAnyBlocError =>
      read<UserBloc>().state is UserError ||
          read<CategoryBloc>().state is CategoryError ||
          read<IncomeBloc>().state is IncomeError ||
          read<ExpenseBloc>().state is ExpenseError ||
          read<TransactionBloc>().state is TransactionError;

  String? get firstBlocError {
    final userState = read<UserBloc>().state;
    final categoryState = read<CategoryBloc>().state;
    final incomeState = read<IncomeBloc>().state;
    final expenseState = read<ExpenseBloc>().state;
    final transactionState = read<TransactionBloc>().state;

    if (userState is UserError) return userState.message;
    if (categoryState is CategoryError) return categoryState.message;
    if (incomeState is IncomeError) return incomeState.message;
    if (expenseState is ExpenseError) return expenseState.message;
    if (transactionState is TransactionError) return transactionState.message;
    return null;
  }
}