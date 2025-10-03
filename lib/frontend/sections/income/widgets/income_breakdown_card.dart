import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../backend/blocs/blocs.dart';
import '../../../../backend/models/models.dart';
import '../pages/income_page.dart';

class IncomeBreakdownCard extends StatelessWidget {
  final IncomePageState pageState;

  const IncomeBreakdownCard({
    super.key,
    required this.pageState,
  });

  @override
  Widget build(BuildContext context) {
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
            if (pageState.cachedStats.isEmpty)
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
              ...pageState.cachedStats.entries.map((entry) {
                final totalAmount = pageState.cachedStats.values.fold(0.0, (sum, amount) => sum + amount);
                final percentage = totalAmount > 0 ? entry.value / totalAmount : 0.0;
                return _CategoryItem(
                  categoryId: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String categoryId;
  final double amount;
  final double percentage;

  const _CategoryItem({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        CategoryModel? category;
        if (categoryState is AllUserCategoriesLoaded) {
          try {
            category = categoryState.categories.firstWhere(
                  (cat) => cat.id == categoryId,
            );
          } catch (e) {
            category = CategoryModel.getDefaultIncomeCategories().firstWhere(
                  (cat) => cat.id == categoryId,
              orElse: () => CategoryModel.getDefaultIncomeCategories().first,
            );
          }
        } else {
          category = CategoryModel.getDefaultIncomeCategories().firstWhere(
                (cat) => cat.id == categoryId,
            orElse: () => CategoryModel.getDefaultIncomeCategories().first,
          );
        }

        final categoryName = category.description;
        final categoryColor = category.color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usa LayoutBuilder per adattarsi allo spazio disponibile
              LayoutBuilder(
                builder: (context, constraints) {
                  // Se lo spazio è molto ristretto, nascondi l'icona
                  final showIcon = constraints.maxWidth > 100;

                  return Row(
                    children: [
                      if (showIcon) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          categoryName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '€ ${amount.toStringAsFixed(2)}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
}