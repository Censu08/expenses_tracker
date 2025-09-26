import 'package:expenses_tracker/core/providers/bloc_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../backend/models/models.dart';
import '../../core/utils/responsive_utils.dart';
import '../../backend/blocs/blocs.dart';

/// Widget generico per gestire stati di loading, errore e contenuto
class BlocStateBuilder<B extends StateStreamable<S>, S> extends StatelessWidget {
  final B bloc;
  final Widget Function(BuildContext context, S state) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final bool Function(S state) isLoading;
  final bool Function(S state) hasError;
  final String Function(S state) getError;
  final bool Function(S state) isEmpty;

  const BlocStateBuilder({
    Key? key,
    required this.bloc,
    required this.builder,
    required this.isLoading,
    required this.hasError,
    required this.getError,
    required this.isEmpty,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      builder: (context, state) {
        if (isLoading(state)) {
          return loadingBuilder?.call(context) ?? const DefaultLoadingWidget();
        }

        if (hasError(state)) {
          return errorBuilder?.call(context, getError(state)) ??
              DefaultErrorWidget(message: getError(state));
        }

        if (isEmpty(state)) {
          return emptyBuilder?.call(context) ?? const DefaultEmptyWidget();
        }

        return builder(context, state);
      },
    );
  }
}

/// Widget di loading di default
class DefaultLoadingWidget extends StatelessWidget {
  final String? message;

  const DefaultLoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget di errore di default
class DefaultErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const DefaultErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getPagePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Qualcosa è andato storto',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget vuoto di default
class DefaultEmptyWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  const DefaultEmptyWidget({
    Key? key,
    this.title,
    this.message,
    this.icon,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getPagePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Nessun dato trovato',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget specifico per le transazioni
class TransactionStateWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<dynamic> transactions) builder;
  final String? emptyTitle;
  final String? emptyMessage;
  final Widget? emptyAction;

  const TransactionStateWidget({
    Key? key,
    required this.builder,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocStateBuilder<TransactionBloc, TransactionState>(
      bloc: context.read<TransactionBloc>(),
      isLoading: (state) => state is TransactionLoading,
      hasError: (state) => state is TransactionError,
      getError: (state) => (state as TransactionError).message,
      isEmpty: (state) {
        if (state is AllTransactionsLoaded) {
          return state.transactions.isEmpty;
        } else if (state is CurrentMonthTransactionsStreamActive) {
          return state.transactions.isEmpty;
        }
        return false;
      },
      builder: (context, state) {
        List<dynamic>? transactions;

        if (state is AllTransactionsLoaded) {
          transactions = state.transactions;
        } else if (state is CurrentMonthTransactionsStreamActive) {
          transactions = state.transactions;
        }

        if (transactions != null) {
          return builder(context, transactions);
        }

        return const DefaultEmptyWidget();
      },
      emptyBuilder: (context) => DefaultEmptyWidget(
        title: emptyTitle ?? 'Nessuna transazione',
        message: emptyMessage ?? 'Non hai ancora registrato alcuna transazione.',
        icon: Icons.receipt_long_outlined,
        action: emptyAction,
      ),
    );
  }
}

/// Widget specifico per le entrate
class IncomeStateWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<IncomeModel> incomes) builder;
  final String? emptyTitle;
  final String? emptyMessage;
  final Widget? emptyAction;

  const IncomeStateWidget({
    Key? key,
    required this.builder,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoading) {
          return const DefaultLoadingWidget(message: 'Caricamento entrate...');
        }

        if (state is IncomeError) {
          return DefaultErrorWidget(
            message: state.message,
            onRetry: () => context.read<IncomeBloc>().add(
              LoadCurrentMonthIncomesEvent(
                userId: context.currentUserId ?? '',
              ),
            ),
          );
        }

        final incomes = context.read<IncomeBloc>().currentIncomes;

        if (incomes == null || incomes.isEmpty) {
          return DefaultEmptyWidget(
            title: emptyTitle ?? 'Nessuna entrata',
            message: emptyMessage ?? 'Non hai ancora registrato alcuna entrata.',
            icon: Icons.trending_up_outlined,
            action: emptyAction,
          );
        }

        return builder(context, incomes);
      },
    );
  }
}

/// Widget specifico per le spese
class ExpenseStateWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<ExpenseModel> expenses) builder;
  final String? emptyTitle;
  final String? emptyMessage;
  final Widget? emptyAction;

  const ExpenseStateWidget({
    Key? key,
    required this.builder,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const DefaultLoadingWidget(message: 'Caricamento spese...');
        }

        if (state is ExpenseError) {
          return DefaultErrorWidget(
            message: state.message,
            onRetry: () => context.read<ExpenseBloc>().add(
              LoadCurrentMonthExpensesEvent(
                userId: context.currentUserId ?? '',
              ),
            ),
          );
        }

        final expenses = context.read<ExpenseBloc>().currentExpenses;

        if (expenses == null || expenses.isEmpty) {
          return DefaultEmptyWidget(
            title: emptyTitle ?? 'Nessuna spesa',
            message: emptyMessage ?? 'Non hai ancora registrato alcuna spesa.',
            icon: Icons.trending_down_outlined,
            action: emptyAction,
          );
        }

        return builder(context, expenses);
      },
    );
  }
}

/// Widget specifico per le categorie
class CategoryStateWidget extends StatelessWidget {
  final Widget Function(BuildContext context, List<CategoryModel> categories) builder;
  final String? emptyTitle;
  final String? emptyMessage;
  final Widget? emptyAction;

  const CategoryStateWidget({
    Key? key,
    required this.builder,
    this.emptyTitle,
    this.emptyMessage,
    this.emptyAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const DefaultLoadingWidget(message: 'Caricamento categorie...');
        }

        if (state is CategoryError) {
          return DefaultErrorWidget(
            message: state.message,
            onRetry: () => context.read<CategoryBloc>().add(
              LoadAllUserCategoriesEvent(
                userId: context.currentUserId ?? '',
                isIncome: true, // Default, può essere parametrizzato
              ),
            ),
          );
        }

        final categories = context.read<CategoryBloc>().currentCategories;

        if (categories == null || categories.isEmpty) {
          return DefaultEmptyWidget(
            title: emptyTitle ?? 'Nessuna categoria',
            message: emptyMessage ?? 'Non sono state trovate categorie.',
            icon: Icons.category_outlined,
            action: emptyAction,
          );
        }

        return builder(context, categories);
      },
    );
  }
}

/// Widget per mostrare un loading overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          loadingMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget per gestire refresh pull-to-refresh
class RefreshableWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const RefreshableWidget({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}