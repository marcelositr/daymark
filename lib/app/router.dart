import 'package:go_router/go_router.dart';

import '../features/journal/presentation/journal_gate.dart';
import '../features/journal/presentation/today_screen.dart';
import '../presentation/app_shell.dart';
import '../presentation/placeholder_screen.dart';

final GoRouter daymarkRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return JournalGate(child: AppShell(navigationShell: navigationShell));
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/monthly',
              builder: (context, state) =>
                  const PlaceholderScreen(section: DaymarkSection.monthly),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/future',
              builder: (context, state) =>
                  const PlaceholderScreen(section: DaymarkSection.future),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/collections',
              builder: (context, state) =>
                  const PlaceholderScreen(section: DaymarkSection.collections),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) =>
                  const PlaceholderScreen(section: DaymarkSection.search),
            ),
          ],
        ),
      ],
    ),
  ],
);
