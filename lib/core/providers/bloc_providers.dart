// File: lib/core/providers/bloc_providers.dart

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
        // User BLoC - già esistente nel progetto
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),

        // Category BLoC
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            categoryController: CategoryController(),
          ),
        ),

        // Income BLoC
        BlocProvider<IncomeBloc>(
          create: (context) => IncomeBloc(
            incomeController: IncomeController(),
          ),
        ),

        // Expense BLoC
        BlocProvider<ExpenseBloc>(
          create: (context) => ExpenseBloc(
            expenseController: ExpenseController(),
          ),
        ),

        // Transaction BLoC (per operazioni combinate)
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
  // User BLoC
  UserBloc get userBloc => read<UserBloc>();
  UserState get userState => watch<UserBloc>().state;

  // Category BLoC
  CategoryBloc get categoryBloc => read<CategoryBloc>();
  CategoryState get categoryState => watch<CategoryBloc>().state;

  // Income BLoC
  IncomeBloc get incomeBloc => read<IncomeBloc>();
  IncomeState get incomeState => watch<IncomeBloc>().state;

  // Expense BLoC
  ExpenseBloc get expenseBloc => read<ExpenseBloc>();
  ExpenseState get expenseState => watch<ExpenseBloc>().state;

  // Transaction BLoC
  TransactionBloc get transactionBloc => read<TransactionBloc>();
  TransactionState get transactionState => watch<TransactionBloc>().state;

  // Helper methods per verificare stati di loading comuni
  bool get isAnyBlocLoading =>
      userState is UserLoading ||
          categoryState is CategoryLoading ||
          incomeState is IncomeLoading ||
          expenseState is ExpenseLoading ||
          transactionState is TransactionLoading;

  bool get hasAnyBlocError =>
      userState is UserError ||
          categoryState is CategoryError ||
          incomeState is IncomeError ||
          expenseState is ExpenseError ||
          transactionState is TransactionError;

  String? get firstBlocError {
    if (userState is UserError) return (userState as UserError).message;
    if (categoryState is CategoryError) return (categoryState as CategoryError).message;
    if (incomeState is IncomeError) return (incomeState as IncomeError).message;
    if (expenseState is ExpenseError) return (expenseState as ExpenseError).message;
    if (transactionState is TransactionError) return (transactionState as TransactionError).message;
    return null;
  }

  // Helper per ottenere l'utente corrente
  String? get currentUserId {
    if (userState is UserAuthenticated) {
      return (userState as UserAuthenticated).user.id;
    }
    return null;
  }

  bool get isUserAuthenticated => userState is UserAuthenticated;
}