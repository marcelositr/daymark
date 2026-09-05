import 'package:flutter/widgets.dart';

abstract final class DaymarkDesign {
  static const double controlRadius = 8;
  static const double surfaceRadius = 12;

  static const double controlHeight = 44;
  static const double compactControlHeight = 40;
  static const double navigationBarHeight = 64;

  static const double trackerStripeWidth = 4;
  static const double trackerStripeHeight = 28;
  static const double trackerStripeRadius = 2;

  static const EdgeInsets controlPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );

  static const EdgeInsets compactControlPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
}
