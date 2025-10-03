import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/blocs.dart';
import '../../../../backend/models/models.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';
import 'income_list_tile.dart';

class RecentIncomeCard extends StatelessWidget {
  final IncomePageState pageState;

  const RecentIncomeCard({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entrate Recenti',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<IncomeBloc, IncomeState>(
              builder: (context, state) {
                if (state is IncomeLoading && pageState.cachedIncomes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final recentIncomes = List.from(pageState.cachedIncomes)
                  ..sort((a, b) => b.incomeDate.compareTo(a.incomeDate))
                  ..take(10).toList();

                if (recentIncomes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessuna entrata trovata',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aggiungi la tua prima entrata',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: recentIncomes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final income = recentIncomes[index];
                    return IncomeListTile(
                      income: income,
                      pageState: pageState,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}