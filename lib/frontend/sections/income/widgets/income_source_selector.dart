import 'package:flutter/material.dart';
import '../../../../backend/models/income/income_source_enum.dart';

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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? Colors.red.withOpacity(0.5)
                  : selectedSource != null
                  ? selectedSource!.color.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              width: errorText != null ? 2 : 1.5,
            ),
            boxShadow: [
              if (selectedSource != null)
                BoxShadow(
                  color: selectedSource!.color.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: DropdownButtonFormField<IncomeSource>(
            value: selectedSource,
            decoration: InputDecoration(
              labelText: 'Fonte di Reddito',
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selectedSource?.color ?? Colors.grey[700],
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: selectedSource != null
                      ? LinearGradient(
                    colors: [
                      selectedSource!.color,
                      selectedSource!.color.withOpacity(0.7),
                    ],
                  )
                      : LinearGradient(
                    colors: [
                      Colors.grey.shade400,
                      Colors.grey.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    if (selectedSource != null)
                      BoxShadow(
                        color: selectedSource!.color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Icon(
                  selectedSource?.icon ?? Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              errorText: errorText,
              filled: !enabled,
              fillColor: enabled ? null : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: IncomeSource.values.map((source) {
              return DropdownMenuItem(
                value: source,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: selectedSource == source
                        ? source.color.withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: source.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          source.icon,
                          size: 20,
                          color: source.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          source.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      if (selectedSource == source)
                        Icon(
                          Icons.check_circle,
                          color: source.color,
                          size: 20,
                        ),
                    ],
                  ),
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
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: selectedSource?.color ?? Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedSource != null
              ? selectedSource!.color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          if (selectedSource != null)
            BoxShadow(
              color: selectedSource!.color.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: selectedSource != null
                  ? LinearGradient(
                colors: [
                  selectedSource!.color,
                  selectedSource!.color.withOpacity(0.7),
                ],
              )
                  : LinearGradient(
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                if (selectedSource != null)
                  BoxShadow(
                    color: selectedSource!.color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Icon(
              selectedSource?.icon ?? Icons.account_balance_wallet,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<IncomeSource>(
              value: selectedSource,
              hint: Text(
                'Seleziona fonte',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: selectedSource?.color ?? Colors.grey[600],
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              items: IncomeSource.values.map((source) {
                return DropdownMenuItem(
                  value: source,
                  child: Row(
                    children: [
                      Icon(source.icon, size: 18, color: source.color),
                      const SizedBox(width: 10),
                      Text(
                        source.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}