import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/providers/bloc_providers.dart';
import '../../backend/blocs/blocs.dart';
import '../../backend/models/models.dart';
import '../widgets/bloc_state_widgets.dart';
import '../widgets/add_income_form.dart';
import '../widgets/income_details_dialog.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

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

  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadIncomeData();
    }
  }

  void _loadIncomeData() {
    final userId = context.currentUserId;
    if (userId != null) {
      final (startDate, endDate) = _getDateRangeForPeriod(_selectedPeriod);

      // Carica categorie entrate
      context.categoryBloc.add(LoadAllUserCategoriesEvent(
        userId: userId,
        isIncome: true,
      ));

      // Carica entrate per periodo
      context.incomeBloc.add(LoadUserIncomesEvent(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      ));

      // Carica statistiche per categoria
      context.incomeBloc.add(LoadIncomeStatsByCategoryEvent(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      ));

      // Carica riepilogo mensile corrente
      context.incomeBloc.add(LoadCurrentMonthSummaryEvent(
        userId: userId,
      ));
    }
  }

  (DateTime, DateTime) _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Questa Settimana':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return (
        DateTime(weekStart.year, weekStart.month, weekStart.day),
        DateTime(now.year, now.month, now.day, 23, 59, 59)
        );
      case 'Questo Mese':
        return (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
      case 'Ultimi 3 Mesi':
        return (
        DateTime(now.year, now.month - 3, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
      case 'Quest\'Anno':
        return (
        DateTime(now.year, 1, 1),
        DateTime(now.year, 12, 31, 23, 59, 59)
        );
      default:
        return (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshableWidget(
        onRefresh: () async {
          _loadIncomeData();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: _buildResponsiveBody(),
      ),
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
                    _loadIncomeData(); // Ricarica i dati per il nuovo periodo
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
    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (state is IncomeError) {
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
                ],
              ),
            ),
          );
        }

        double totalAmount = 0.0;
        double previousPeriodAmount = 0.0;
        double growthPercentage = 0.0;

        if (state is CurrentMonthSummaryLoaded) {
          final summary = state.summary;
          totalAmount = summary['total']?.toDouble() ?? 0.0;
          previousPeriodAmount = summary['previous_month_total']?.toDouble() ?? 0.0;

          if (previousPeriodAmount > 0) {
            growthPercentage = ((totalAmount - previousPeriodAmount) / previousPeriodAmount) * 100;
          }
        } else if (state is UserIncomesLoaded) {
          totalAmount = state.incomes.fold(0.0, (sum, income) => sum + income.amount);
        }

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
                  '€ ${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (growthPercentage != 0.0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: growthPercentage >= 0
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          growthPercentage >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: growthPercentage >= 0 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${growthPercentage >= 0 ? '+' : ''}${growthPercentage.toStringAsFixed(1)}% vs periodo precedente',
                          style: TextStyle(
                            color: growthPercentage >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomeBreakdownCard() {
    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        if (state is IncomeLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        Map<String, double> categoryStats = {};
        double totalAmount = 0.0;

        if (state is IncomeStatsByCategoryLoaded) {
          categoryStats = state.stats;
          totalAmount = categoryStats.values.fold(0.0, (sum, amount) => sum + amount);
        } else if (state is UserIncomesLoaded) {
          // Calcola statistiche dalle entrate caricate
          for (final income in state.incomes) {
            final categoryId = income.category.id;
            categoryStats[categoryId] = (categoryStats[categoryId] ?? 0.0) + income.amount;
          }
          totalAmount = categoryStats.values.fold(0.0, (sum, amount) => sum + amount);
        }

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
                if (categoryStats.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nessuna entrata nel periodo selezionato',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...categoryStats.entries.map((entry) {
                    final percentage = totalAmount > 0 ? entry.value / totalAmount : 0.0;
                    return _buildCategoryItem(
                      entry.key,
                      entry.value,
                      percentage,
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(String categoryId, double amount, double percentage) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        // Trova la categoria per ID
        CategoryModel? category;
        if (categoryState is AllUserCategoriesLoaded) {
          category = categoryState.categories.firstWhere(
                (cat) => cat.id == categoryId,
            orElse: () => CategoryModel.getDefaultIncomeCategories().first, // Fallback
          );
        }

        final categoryName = category?.description ?? 'Sconosciuta';
        final categoryColor = category?.color ?? Colors.grey;

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
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        categoryName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '€ ${amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: categoryColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentIncomeCard() {
    return BlocBuilder<IncomeBloc, IncomeState>(
      builder: (context, state) {
        List<IncomeModel> recentIncomes = [];

        if (state is UserIncomesLoaded) {
          // Prendi le più recenti
          recentIncomes = List.from(state.incomes)
            ..sort((a, b) => b.incomeDate.compareTo(a.incomeDate))
            ..take(10).toList();
        }

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
                      onPressed: () => _showAllIncomes(),
                      child: const Text('Vedi Tutte'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state is IncomeLoading
                    ? const Center(child: CircularProgressIndicator())
                    : recentIncomes.isEmpty
                    ? Center(
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
                )
                    : ListView.separated(
                  itemCount: recentIncomes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final income = recentIncomes[index];
                    return _buildIncomeListTile(income);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomeListTile(IncomeModel income) {
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
          Text('${income.category.description} • ${_formatDate(income.incomeDate)}'),
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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '+€ ${income.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 16,
            ),
          ),
          PopupMenuButton(
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
            onSelected: (value) => _handleIncomeAction(value as String, income),
          ),
        ],
      ),
      onTap: () => _showIncomeDetails(income),
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
      builder: (context) => AddIncomeForm(
        onIncomeAdded: () {
          Navigator.pop(context);
          _loadIncomeData(); // Ricarica i dati
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrata aggiunta con successo!')),
          );
        },
      ),
    );
  }

  void _showIncomeDetails(IncomeModel income) {
    showDialog(
      context: context,
      builder: (context) => IncomeDetailsDialog(
        income: income,
        onUpdated: () => _loadIncomeData(),
      ),
    );
  }

  void _handleIncomeAction(String action, IncomeModel income) {
    final userId = context.currentUserId;
    if (userId == null) return;

    switch (action) {
      case 'edit':
        _showEditIncomeDialog(income);
        break;
      case 'delete':
        _showDeleteConfirmation(income);
        break;
    }
  }

  void _showEditIncomeDialog(IncomeModel income) {
    showDialog(
      context: context,
      builder: (context) => AddIncomeForm(
        initialIncome: income,
        onIncomeAdded: () {
          Navigator.pop(context);
          _loadIncomeData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrata modificata con successo!')),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(IncomeModel income) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Vuoi davvero eliminare l\'entrata "${income.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIncome(income);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _deleteIncome(IncomeModel income) {
    final userId = context.currentUserId;
    if (userId == null) return;

    context.incomeBloc.add(DeleteIncomeEvent(
      userId: userId,
      incomeId: income.id,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrata eliminata')),
    );
  }

  void _showAllIncomes() {
    // TODO: Naviga alla pagina con tutte le entrate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzionalità in sviluppo')),
    );
  }
}