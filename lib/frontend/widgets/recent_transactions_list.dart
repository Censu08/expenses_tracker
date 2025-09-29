import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/utils/responsive_utils.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<dynamic> transactions;
  final int? maxItems;

  const RecentTransactionsList({
    Key? key,
    required this.transactions,
    this.maxItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final displayTransactions = maxItems != null
        ? transactions.take(maxItems!).toList()
        : transactions;

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
                    // TODO: Naviga alla pagina transazioni
                  },
                  child: Text(
                    'Vedi Tutte',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (displayTransactions.isEmpty)
            _buildEmptyState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayTransactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = displayTransactions[index];
                return _buildTransactionTile(context, transaction, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Nessuna transazione',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Inizia aggiungendo la tua prima entrata o spesa',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, dynamic transaction, bool isMobile) {
    final String type = transaction['type'] ?? 'expense';
    final String description = transaction['description'] ?? 'Senza descrizione';
    final double amount = (transaction['amount'] ?? 0.0).toDouble();
    final String categoryName = transaction['category']?['description'] ?? 'Altro';
    final String categoryIcon = transaction['category']?['icon'] ?? 'other';
    final DateTime date = transaction['date']?.toDate() ?? DateTime.now();

    final bool isIncome = type == 'income';
    final Color color = isIncome ? Colors.green : Colors.red;
    final String sign = isIncome ? '+' : '-';
    final IconData icon = _getCategoryIcon(categoryIcon);
    final String formattedDate = _formatDate(date);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 8 : 12,
      ),
      leading: Container(
        width: isMobile ? 40 : 48,
        height: isMobile ? 40 : 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: isMobile ? 20 : 24),
      ),
      title: Text(
        description,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 14 : 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Chip(
            label: Text(
              categoryName,
              style: TextStyle(fontSize: isMobile ? 10 : 11, color: color),
            ),
            backgroundColor: color.withOpacity(0.1),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          Text(
            formattedDate,
            style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade600),
          ),
        ],
      ),
      trailing: Text(
        '$sign€${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 16 : 18,
          color: color,
        ),
      ),
      onTap: () {
        // TODO: Mostra dettagli transazione
      },
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'shopping_cart': Icons.shopping_cart,
      'local_gas_station': Icons.local_gas_station,
      'restaurant': Icons.restaurant,
      'medical_services': Icons.medical_services,
      'school': Icons.school,
      'directions_car': Icons.directions_car,
      'bolt': Icons.bolt,
      'movie': Icons.movie,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'work': Icons.work,
      'attach_money': Icons.attach_money,
      'business': Icons.business,
      'account_balance': Icons.account_balance,
      'trending_up': Icons.trending_up,
      'other': Icons.more_horiz,
    };

    return iconMap[iconName] ?? Icons.more_horiz;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Oggi ${DateFormat.Hm().format(date)}';
    } else if (transactionDate == yesterday) {
      return 'Ieri ${DateFormat.Hm().format(date)}';
    } else if (now.difference(transactionDate).inDays < 7) {
      return DateFormat('EEEE HH:mm', 'it_IT').format(date);
    } else {
      return DateFormat('dd MMM yyyy', 'it_IT').format(date);
    }
  }
}