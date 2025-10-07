import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';

class IncomeSourceFilter extends StatefulWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onSourceSelected;

  const IncomeSourceFilter({
    Key? key,
    required this.selectedSource,
    required this.onSourceSelected,
  }) : super(key: key);

  @override
  State<IncomeSourceFilter> createState() => _IncomeSourceFilterState();
}

class _IncomeSourceFilterState extends State<IncomeSourceFilter> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: RawScrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thumbColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            trackColor: Colors.grey.withOpacity(0.2),
            trackBorderColor: Colors.transparent,
            radius: const Radius.circular(10),
            thickness: 6,
            interactive: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: IncomeSource.values.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildFilterChip(
                      context: context,
                      label: 'Tutte',
                      icon: Icons.grid_view,
                      isSelected: widget.selectedSource == null,
                      onTap: () => widget.onSourceSelected(null),
                      color: Colors.blue,
                    );
                  }

                  final source = IncomeSource.values[index - 1];
                  return _buildFilterChip(
                    context: context,
                    label: source.displayName,
                    icon: source.icon,
                    isSelected: widget.selectedSource == source,
                    onTap: () => widget.onSourceSelected(source),
                    color: source.color,
                  );
                },
              ),
            ),
          ),
        ),
      ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}