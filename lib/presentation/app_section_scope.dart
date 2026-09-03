import 'package:flutter/material.dart';

/// Publishes the active top-level Daymark section to retained shell branches.
///
/// `StatefulShellRoute.indexedStack` intentionally keeps inactive branches
/// mounted. Screens that need to refresh when they become visible again can
/// depend on this scope without coupling their data layer to navigation.
final class AppSectionScope extends InheritedNotifier<ValueNotifier<int>> {
  const AppSectionScope({
    required ValueNotifier<int> currentIndex,
    required super.child,
    super.key,
  }) : super(notifier: currentIndex);

  static const int futureSectionIndex = 2;
  static const int collectionsSectionIndex = 3;
  static const int searchSectionIndex = 4;

  static int? maybeCurrentIndexOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppSectionScope>()
        ?.notifier
        ?.value;
  }
}
