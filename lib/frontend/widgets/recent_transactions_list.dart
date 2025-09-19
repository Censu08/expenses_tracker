import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class RecentTransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dati mock per le transazioni recenti
    final transactions = [
      _Transaction(
        id: '1',
        title: 'Supermercato Esselunga',
        category: 'Spesa',
        amount: -45.50,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.shopping_cart,
        color: Colors.blue,
      ),
      _Transaction(
        id: '2',
        title: 'Rifornimento Q8',
        category: 'Carburante',
        amount: -65.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.local_gas_station,
        color: Colors.orange,
      ),
      _Transaction(
        id: '3',
        title: 'Ristorante La Tavola',
        category: 'Ristorante',
        amount: -32.80,
        date: DateTime.now().subtract(const Duration(days: 2)),
        icon: Icons.restaurant,
        color: Colors.red,
      ),
      _Transaction(
        id: '4',
        title: 'Farmacia San Marco',
        category: 'Salute',
        amount: -18.90,
        date: DateTime.now().subtract(const Duration(days: 3)),
        icon: Icons.medical_services,
        color: Colors.green,
      ),
      _Transaction(
        id: '5',
        title: 'Stipendio',
        category: 'Reddito',
        amount: 2500.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
        icon: Icons.account_balance,
        color: Colors.green,
      ),
    ];

    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ultime Transazioni',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 16 : 18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Mostra tutte le transazioni
                  },
                  child: Text(
                    'Vedi Tutte',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionTile(context, transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, _Transaction transaction) {
    final isIncome = transaction.amount > 0;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final isMobile = ResponsiveUtils.isMobile(context);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 20.0,
        vertical: isMobile ? 4.0 : 8.0,
      ),
      leading: CircleAvatar(
        radius: isMobile ? 18 : 20,
        backgroundColor: transaction.color.withOpacity(0.1),
        child: Icon(
          transaction.icon,
          color: transaction.color,
          size: isMobile ? 18 : 20,
        ),
      ),
      title: Text(
        transaction.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: isMobile ? 14 : 16,
        ),
      ),
      subtitle: Text(
        '${transaction.category} • ${_formatDate(transaction.date)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: isMobile ? 12 : 13,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : ''}€ ${transaction.amount.abs().toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: amountColor,
          fontSize: isMobile ? 13 : 15,
        ),
      ),
      onTap: () {
        // TODO: Mostra dettagli transazione
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Oggi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _Transaction {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;

  const _Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
  });
}