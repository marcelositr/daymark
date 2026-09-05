import 'package:flutter/widgets.dart';

abstract final class DaymarkDesign {
  static const double controlRadius = 8;
  static const double surfaceRadius = 12;

  static const double controlHeight = 44;
  static const double compactControlHeight = 40;
  static const double navigationBarHeight = 64;

  static const double compactPageBreakpoint = 600;
  static const double widePageBreakpoint = 1200;
  static const double pageMaxWidth = 960;

  static const EdgeInsets compactPagePadding = EdgeInsets.fromLTRB(
    16,
    16,
    16,
    12,
  );
  static const EdgeInsets regularPagePadding = EdgeInsets.fromLTRB(
    24,
    24,
    24,
    16,
  );
  static const EdgeInsets widePagePadding = EdgeInsets.fromLTRB(32, 32, 32, 24);

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
