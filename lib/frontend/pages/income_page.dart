import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

class IncomePage extends StatefulWidget {
  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  String _selectedPeriod = 'Questo Mese';
  final List<String> _periods = [
    'Questa Settimana',
    'Questo Mese',
    'Ultimi 3 Mesi',
    'Quest\'Anno',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildResponsiveBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddIncomeDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuova Entrata'),
      ),
    );
  }

  Widget _buildResponsiveBody() {
    if (ResponsiveUtils.isMobile(context)) {
      return _buildMobileLayout();
    } else if (ResponsiveUtils.isTablet(context)) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildIncomeSummaryCard(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildIncomeBreakdownCard(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildRecentIncomeCard(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildIncomeSummaryCard(),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context)),
              Expanded(
                flex: 1,
                child: _buildIncomeBreakdownCard(),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          _buildRecentIncomeCard(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: ResponsiveUtils.getPagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSelector(),
          SizedBox(height: ResponsiveUtils.getSpacing(context)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonna sinistra - Riepilogo e Breakdown
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildIncomeSummaryCard(),
                      SizedBox(height: ResponsiveUtils.getSpacing(context)),
                      Expanded(child: _buildIncomeBreakdownCard()),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getSpacing(context)),
                // Colonna destra - Entrate Recenti
                Expanded(
                  flex: 2,
                  child: _buildRecentIncomeCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
                value: _selectedPeriod,
                isExpanded: true,
                underline: const SizedBox(),
                items: _periods.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPeriod = value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Entrate Totali',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '€ 3.250,00',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+12.5% vs mese scorso',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeBreakdownCard() {
    final incomeCategories = [
      IncomeCategory('Stipendio', 2500.00, Colors.blue, 0.77),
      IncomeCategory('Freelance', 500.00, Colors.purple, 0.15),
      IncomeCategory('Investimenti', 150.00, Colors.orange, 0.05),
      IncomeCategory('Altro', 100.00, Colors.grey, 0.03),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suddivisione per Categoria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...incomeCategories.map((category) => _buildCategoryItem(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IncomeCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '€ ${category.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: category.percentage,
            backgroundColor: category.color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(category.color),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentIncomeCard() {
    final recentIncomes = [
      IncomeTransaction(
        'Stipendio Dicembre',
        'Stipendio',
        2500.00,
        DateTime.now().subtract(const Duration(days: 1)),
        Icons.account_balance,
        Colors.blue,
      ),
      IncomeTransaction(
        'Progetto Website',
        'Freelance',
        350.00,
        DateTime.now().subtract(const Duration(days: 3)),
        Icons.web,
        Colors.purple,
      ),
      IncomeTransaction(
        'Dividendi Azioni',
        'Investimenti',
        75.00,
        DateTime.now().subtract(const Duration(days: 5)),
        Icons.trending_up,
        Colors.orange,
      ),
      IncomeTransaction(
        'Vendita Usato',
        'Altro',
        50.00,
        DateTime.now().subtract(const Duration(days: 7)),
        Icons.sell,
        Colors.grey,
      ),
    ];

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
                TextButton(
                  onPressed: () {},
                  child: const Text('Vedi Tutte'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: recentIncomes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final income = recentIncomes[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: income.color.withOpacity(0.1),
                    child: Icon(income.icon, color: income.color),
                  ),
                  title: Text(
                    income.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${income.category} • ${_formatDate(income.date)}',
                  ),
                  trailing: Text(
                    '+€ ${income.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // TODO: Mostra dettagli entrata
                  },
                );
              },
            ),
          ),
        ],
      ),
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

  void _showAddIncomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuova Entrata'),
        content: const Text('Funzionalità in arrivo!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class IncomeCategory {
  final String name;
  final double amount;
  final Color color;
  final double percentage;

  IncomeCategory(this.name, this.amount, this.color, this.percentage);
}

class IncomeTransaction {
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color color;

  IncomeTransaction(
      this.title,
      this.category,
      this.amount,
      this.date,
      this.icon,
      this.color,
      );
}