import 'package:flutter/material.dart';
import '../../../../backend/models/models.dart';
import '../pages/income_page.dart';
import '../functions/income_page_functions.dart';
import 'income_source_badge.dart';

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
        backgroundColor: income.source.color.withOpacity(0.1),
        child: Icon(income.source.icon, color: income.source.color),
      ),
      title: Text(
        income.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            income.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Badge categoria esistente
              Icon(income.source.icon, size: 14, color: income.source.color),
              const SizedBox(width: 4),
              Text(
                income.source.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              IncomeSourceBadge(
                source: income.source,
                showLabel: true,
                iconSize: 14,
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