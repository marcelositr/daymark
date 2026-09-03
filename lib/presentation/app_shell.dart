import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import 'app_section_scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final ValueNotifier<int> _currentSectionIndex;

  @override
  void initState() {
    super.initState();
    _currentSectionIndex = ValueNotifier<int>(
      widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final int currentIndex = widget.navigationShell.currentIndex;
    if (_currentSectionIndex.value != currentIndex) {
      _currentSectionIndex.value = currentIndex;
    }
  }

  @override
  void dispose() {
    _currentSectionIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final StatefulNavigationShell navigationShell = widget.navigationShell;
    final List<NavigationDestination> bottomDestinations = [
      NavigationDestination(
        icon: const Icon(Icons.today_outlined),
        label: l10n.today,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month_outlined),
        label: l10n.monthly,
      ),
      NavigationDestination(
        icon: const Icon(Icons.event_outlined),
        label: l10n.future,
      ),
      NavigationDestination(
        icon: const Icon(Icons.book_outlined),
        label: l10n.collections,
      ),
      NavigationDestination(icon: const Icon(Icons.search), label: l10n.search),
    ];

    return AppSectionScope(
      currentIndex: _currentSectionIndex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 720) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: _goToBranch,
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.today_outlined),
                        label: Text(l10n.today),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: Text(l10n.monthly),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.event_outlined),
                        label: Text(l10n.future),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.book_outlined),
                        label: Text(l10n.collections),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.search),
                        label: Text(l10n.search),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: navigationShell),
                ],
              ),
            );
          }

          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _goToBranch,
              destinations: bottomDestinations,
            ),
          );
        },
      ),
    );
  }

  void _goToBranch(int index) {
    final StatefulNavigationShell navigationShell = widget.navigationShell;
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
    if (_currentSectionIndex.value != index) {
      _currentSectionIndex.value = index;
    }
  }
}
