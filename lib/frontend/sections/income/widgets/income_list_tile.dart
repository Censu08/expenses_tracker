import 'package:flutter/material.dart';
import '../../../../backend/models/models.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';

class IncomeListTile extends StatelessWidget {
  final IncomeModel income;
  final IncomePageState pageState;

  const IncomeListTile({
    super.key,
    required this.income,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      leading: CircleAvatar(
        backgroundColor: income.category.color.withOpacity(0.1),
        child: Icon(income.category.icon, color: income.category.color),
      ),
      title: Text(
        income.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${income.category.description} • ${IncomePageFunctions.formatDate(income.incomeDate)}',
          ),
          if (income.isRecurring)
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ricorrente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+€ ${income.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 16,
            ),
          ),
          PopupMenuButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: 20),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Modifica'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Elimina', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) => IncomePageFunctions.handleIncomeAction(
              context,
              pageState,
              value as String,
              income,
            ),
          ),
        ],
      ),
      onTap: () => IncomePageFunctions.showIncomeDetails(context, pageState, income),
    );
  }
}