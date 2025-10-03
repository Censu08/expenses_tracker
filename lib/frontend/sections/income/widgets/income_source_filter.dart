import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';

class IncomeSourceFilter extends StatelessWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onSourceSelected;

  const IncomeSourceFilter({
    Key? key,
    required this.selectedSource,
    required this.onSourceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Chip "Tutte"
          _buildFilterChip(
            context: context,
            label: 'Tutte',
            icon: Icons.grid_view,
            isSelected: selectedSource == null,
            onTap: () => onSourceSelected(null),
            color: Colors.blue,
          ),
          const SizedBox(width: 8),

          // Chip per ogni source
          ...IncomeSource.values.map((source) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context: context,
                label: source.displayName,
                icon: source.icon,
                isSelected: selectedSource == source,
                onTap: () => onSourceSelected(source),
                color: source.color,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(isSelected ? 1.0 : 0.3),
        ),
      ),
    );
  }
}