import 'package:flutter/material.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';

class PeriodSelector extends StatelessWidget {
  final IncomePageState pageState;

  const PeriodSelector({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Periodo:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<String>(
                value: pageState.selectedPeriod,
                isExpanded: true,
                underline: const SizedBox(),
                items: pageState.periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    pageState.setState(() => pageState.selectedPeriod = value);
                    IncomePageFunctions.loadIncomeData(context, pageState);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}