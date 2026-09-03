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
    final int bottomSelectedIndex = navigationShell.currentIndex < 4
        ? navigationShell.currentIndex
        : 4;
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
      NavigationDestination(
        icon: const Icon(Icons.more_horiz),
        label: l10n.more,
      ),
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
                      NavigationRailDestination(
                        icon: const Icon(Icons.format_list_numbered),
                        label: Text(l10n.index),
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
              selectedIndex: bottomSelectedIndex,
              onDestinationSelected: (index) {
                if (index < 4) {
                  _goToBranch(index);
                  return;
                }
                _showMore(context, l10n);
              },
              destinations: bottomDestinations,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMore(BuildContext context, AppLocalizations l10n) async {
    final int? branchIndex = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: Text(l10n.search),
                onTap: () => Navigator.of(sheetContext).pop(4),
              ),
              ListTile(
                leading: const Icon(Icons.format_list_numbered),
                title: Text(l10n.index),
                onTap: () => Navigator.of(sheetContext).pop(5),
              ),
            ],
          ),
        );
      },
    );
    if (branchIndex != null && mounted) {
      _goToBranch(branchIndex);
    }
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
