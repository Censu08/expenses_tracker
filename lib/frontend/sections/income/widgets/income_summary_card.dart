import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/blocs.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';

class IncomeSummaryCard extends StatelessWidget {
  final IncomePageState pageState;

  const IncomeSummaryCard({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is UserIncomesLoaded) {
          pageState.setState(() {
            pageState.cachedIncomes = state.incomes;
            pageState.cachedStats = IncomePageFunctions.calculateStats(state.incomes);
          });
          debugPrint('✅ [IncomePage] Cached ${state.incomes.length} incomes');
        }

        // Ricarica dopo creazione
        if (state is IncomeCreated) {
          debugPrint('✅ [IncomePage] Income created, reloading...');
          IncomePageFunctions.loadIncomeData(context, pageState);
        }

        // Ricarica dopo aggiornamento
        if (state is IncomeUpdated) {
          debugPrint('✅ [IncomePage] Income updated, reloading...');
          IncomePageFunctions.loadIncomeData(context, pageState);
        }

        // Ricarica dopo duplicazione
        if (state is IncomeDuplicated) {
          debugPrint('✅ [IncomePage] Income duplicated, reloading...');
          IncomePageFunctions.loadIncomeData(context, pageState);
        }

        if (state is IncomeError) {
          debugPrint('❌ [IncomePage] Income error: ${state.message}');
        }
      },
      builder: (context, state) {
        if (state is IncomeLoading && pageState.cachedIncomes.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is IncomeError && pageState.cachedIncomes.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Errore nel caricamento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => IncomePageFunctions.loadIncomeData(context, pageState),
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            ),
          );
        }

        final totalAmount = pageState.cachedIncomes.fold(0.0, (sum, income) => sum + income.amount);
        final incomeCount = pageState.cachedIncomes.length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Usa Flexible per gestire overflow
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 24, // Ridotto da 28 a 24
                    ),
                    const SizedBox(width: 8), // Ridotto da 12 a 8
                    Flexible(
                      child: Text(
                        'Entrate Totali',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '€ ${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$incomeCount ${incomeCount == 1 ? 'entrata' : 'entrate'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}