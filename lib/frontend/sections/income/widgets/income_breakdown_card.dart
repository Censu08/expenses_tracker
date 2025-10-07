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
          mainAxisSize: MainAxisSize.min, // ⬅️ FIX: Use minimum space needed
          children: [
            Text(
              'Suddivisione per Categoria',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16), // ⬅️ FIX: Reduced from 20 to 16
            if (pageState.cachedStats.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ⬅️ FIX: Minimum space
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
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true, // ⬅️ FIX: Use only needed space
                  physics: const NeverScrollableScrollPhysics(), // ⬅️ FIX: Disable internal scroll
                  padding: EdgeInsets.zero, // ⬅️ FIX: Remove default padding
                  itemCount: pageState.cachedStats.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12), // ⬅️ FIX: Spacing between items
                  itemBuilder: (context, index) {
                    final entry = pageState.cachedStats.entries.elementAt(index);
                    final totalAmount = pageState.cachedStats.values.fold(0.0, (sum, amount) => sum + amount);
                    final percentage = totalAmount > 0 ? entry.value / totalAmount : 0.0;
                    return _CategoryItem(
                      categoryId: entry.key,
                      amount: entry.value,
                      percentage: percentage,
                    );
                  },
                ),
              ),
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

        // ⬅️ FIX: Removed outer Padding, using intrinsic sizes
        return Column(
          mainAxisSize: MainAxisSize.min, // ⬅️ FIX: Minimum space needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with category name and amount
            Row(
              children: [
                // Color indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                // Category name
                Expanded(
                  flex: 2,
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13, // ⬅️ FIX: Explicit size
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                // Amount
                Text(
                  '€${amount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // ⬅️ FIX: Explicit size
                  ),
                ),
                const SizedBox(width: 4),
                // Percentage
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11, // ⬅️ FIX: Smaller percentage
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6), // ⬅️ FIX: Reduced from 8 to 6
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6, // ⬅️ FIX: Explicit height for progress bar
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: categoryColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}