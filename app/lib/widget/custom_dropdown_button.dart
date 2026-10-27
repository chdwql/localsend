import 'package:flutter/material.dart';

/// A [DropdownButton] styled for the FlClash / Modern iOS aesthetic.
class CustomDropdownButton<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final bool expanded;

  const CustomDropdownButton({
    required this.value,
    required this.items,
    this.onChanged,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? Colors.white.withAlpha(14) : Colors.black.withAlpha(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: expanded,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(16),
        items: items,
        icon: const Icon(Icons.unfold_more, size: 18),
        onChanged: onChanged == null
            ? null
            : (value) {
                if (value != null) {
                  onChanged!(value);
                }
              },
      ),
    );
  }
}
