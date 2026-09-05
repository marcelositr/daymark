import 'package:daymark/app/design_tokens.dart';
import 'package:flutter/material.dart';

class DaymarkPageFrame extends StatelessWidget {
  const DaymarkPageFrame({
    required this.child,
    this.maxWidth = DaymarkDesign.pageMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final EdgeInsets padding = switch (constraints.maxWidth) {
            < DaymarkDesign.compactPageBreakpoint =>
              DaymarkDesign.compactPagePadding,
            >= DaymarkDesign.widePageBreakpoint =>
              DaymarkDesign.widePagePadding,
            _ => DaymarkDesign.regularPagePadding,
          };

          return Align(
            alignment: AlignmentDirectional.topCenter,
            child: SizedBox(
              width: maxWidth,
              height: constraints.maxHeight,
              child: Padding(padding: padding, child: child),
            ),
          );
        },
      ),
    );
  }
}
