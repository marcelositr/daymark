import 'package:daymark/app/design_tokens.dart';
import 'package:daymark/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final MapEntry<String, ThemeData> entry in <String, ThemeData>{
    'light': DaymarkTheme.light(),
    'dark': DaymarkTheme.dark(),
  }.entries) {
    test('Daymark ${entry.key} theme exposes the shared control grammar', () {
      final ThemeData theme = entry.value;

      expect(theme.useMaterial3, isTrue);
      expect(theme.inputDecorationTheme.isDense, isTrue);
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
      expect(theme.filledButtonTheme.style, isNotNull);
      expect(theme.outlinedButtonTheme.style, isNotNull);
      expect(theme.textButtonTheme.style, isNotNull);
      expect(theme.iconButtonTheme.style, isNotNull);
      expect(theme.segmentedButtonTheme.style, isNotNull);
      expect(theme.popupMenuTheme.shape, isA<RoundedRectangleBorder>());
      expect(theme.dialogTheme.shape, isA<RoundedRectangleBorder>());
      expect(
        theme.navigationBarTheme.height,
        DaymarkDesign.navigationBarHeight,
      );
    });
  }
}
