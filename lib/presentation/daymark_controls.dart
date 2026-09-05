import 'package:daymark/app/design_tokens.dart';
import 'package:flutter/material.dart';

class DaymarkDropdownButton<T> extends StatelessWidget {
  const DaymarkDropdownButton({
    required this.value,
    required this.items,
    required this.onChanged,
    this.dropdownKey,
    this.isExpanded = false,
    super.key,
  });

  final Key? dropdownKey;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool enabled = onChanged != null;

    return Container(
      constraints: const BoxConstraints(minHeight: DaymarkDesign.controlHeight),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DaymarkDesign.controlRadius),
        border: Border.all(
          color: enabled
              ? colors.outlineVariant
              : colors.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          key: dropdownKey,
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          isExpanded: isExpanded,
          alignment: AlignmentDirectional.centerStart,
          borderRadius: BorderRadius.circular(DaymarkDesign.controlRadius),
          menuMaxHeight: 360,
        ),
      ),
    );
  }
}
