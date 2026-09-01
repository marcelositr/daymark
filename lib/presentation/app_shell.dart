import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
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

    return LayoutBuilder(
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
    );
  }

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
