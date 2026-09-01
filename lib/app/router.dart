import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/app_shell.dart';
import '../presentation/placeholder_screen.dart';

final GoRouter daymarkRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const PlaceholderScreen(
                section: DaymarkSection.today,
                isFoundationHome: true,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/monthly',
              builder: (context, state) => const PlaceholderScreen(
                section: DaymarkSection.monthly,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/future',
              builder: (context, state) => const PlaceholderScreen(
                section: DaymarkSection.future,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/collections',
              builder: (context, state) => const PlaceholderScreen(
                section: DaymarkSection.collections,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const PlaceholderScreen(
                section: DaymarkSection.search,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
