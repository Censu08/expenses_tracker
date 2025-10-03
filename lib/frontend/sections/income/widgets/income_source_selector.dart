import 'package:flutter/material.dart';

import '../../../../backend/models/income/income_source_enum.dart';

/// Widget dropdown per selezionare la fonte di reddito
class IncomeSourceSelector extends StatelessWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onChanged;
  final String? errorText;
  final bool enabled;

  const IncomeSourceSelector({
    Key? key,
    required this.selectedSource,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<IncomeSource>(
          value: selectedSource,
          decoration: InputDecoration(
            labelText: 'Fonte di Reddito',
            prefixIcon: Icon(
              selectedSource?.icon ?? Icons.account_balance_wallet,
              color: selectedSource?.color,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            errorText: errorText,
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey[100],
          ),
          items: IncomeSource.values.map((source) {
            return DropdownMenuItem(
              value: source,
              child: Row(
                children: [
                  Icon(
                    source.icon,
                    size: 20,
                    color: source.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          source.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          source.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: (value) {
            if (value == null) {
              return 'Seleziona una fonte di reddito';
            }
            return null;
          },
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),

        // Info box per la fonte selezionata
        if (selectedSource != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selectedSource!.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedSource!.color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: selectedSource!.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedSource!.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedSource!.color.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Variante compatta del selector (per spazi ristretti)
class CompactIncomeSourceSelector extends StatelessWidget {
  final IncomeSource? selectedSource;
  final ValueChanged<IncomeSource?> onChanged;

  const CompactIncomeSourceSelector({
    Key? key,
    required this.selectedSource,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<IncomeSource>(
      value: selectedSource,
      hint: const Text('Fonte'),
      isExpanded: true,
      underline: Container(
        height: 1,
        color: Colors.grey[300],
      ),
      items: IncomeSource.values.map((source) {
        return DropdownMenuItem(
          value: source,
          child: Row(
            children: [
              Icon(source.icon, size: 18, color: source.color),
              const SizedBox(width: 8),
              Text(source.displayName),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}