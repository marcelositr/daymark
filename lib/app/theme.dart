import 'package:daymark/app/design_tokens.dart';
import 'package:flutter/material.dart';

abstract final class DaymarkTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ThemeData base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
    );

    final ColorScheme colors = base.colorScheme;

    final BorderRadius controlRadius = BorderRadius.circular(
      DaymarkDesign.controlRadius,
    );
    final BorderRadius surfaceRadius = BorderRadius.circular(
      DaymarkDesign.surfaceRadius,
    );

    final RoundedRectangleBorder controlShape = RoundedRectangleBorder(
      borderRadius: controlRadius,
    );
    final RoundedRectangleBorder surfaceShape = RoundedRectangleBorder(
      borderRadius: surfaceRadius,
    );

    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: controlRadius,
      borderSide: BorderSide(color: colors.outlineVariant),
    );

    final OutlineInputBorder focusedInputBorder = OutlineInputBorder(
      borderRadius: controlRadius,
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    );

    final OutlineInputBorder errorInputBorder = OutlineInputBorder(
      borderRadius: controlRadius,
      borderSide: BorderSide(color: colors.error),
    );

    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 11,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: focusedInputBorder,
        errorBorder: errorInputBorder,
        focusedErrorBorder: errorInputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, DaymarkDesign.controlHeight),
          padding: DaymarkDesign.controlPadding,
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, DaymarkDesign.controlHeight),
          padding: DaymarkDesign.controlPadding,
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, DaymarkDesign.compactControlHeight),
          padding: DaymarkDesign.compactControlPadding,
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(DaymarkDesign.compactControlHeight),
          padding: const EdgeInsets.all(8),
          shape: controlShape,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, DaymarkDesign.compactControlHeight),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            DaymarkDesign.compactControlPadding,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(controlShape),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(shape: surfaceShape, elevation: 3),
      dialogTheme: DialogThemeData(
        shape: surfaceShape,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      navigationRailTheme: NavigationRailThemeData(
        minWidth: 72,
        useIndicator: true,
        indicatorShape: controlShape,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: DaymarkDesign.navigationBarHeight,
        indicatorShape: controlShape,
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
