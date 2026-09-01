import 'package:flutter/material.dart';

abstract final class DaymarkTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }
}
