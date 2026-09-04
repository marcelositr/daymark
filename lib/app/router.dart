import 'package:go_router/go_router.dart';

import '../features/journal/domain/journal_domain.dart';
import '../features/journal/presentation/collections_screen.dart';
import '../features/journal/presentation/daily_history_screen.dart';
import '../features/journal/presentation/future_history_screen.dart';
import '../features/journal/presentation/future_screen.dart';
import '../features/journal/presentation/index_screen.dart';
import '../features/journal/presentation/journal_gate.dart';
import '../features/journal/presentation/monthly_screen.dart';
import '../features/journal/presentation/search_screen.dart';
import '../features/journal/presentation/today_screen.dart';
import '../presentation/app_shell.dart';

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
            GoRoute(
              path: '/daily/:date',
              builder: (context, state) =>
                  DailyHistoryScreen(methodDate: state.pathParameters['date']!),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/monthly',
              builder: (context, state) => const MonthlyScreen(),
            ),
            GoRoute(
              path: '/monthly/:period',
              builder: (context, state) => MonthlyScreen(
                key: state.pageKey,
                initialMonth: DateTime.parse(state.pathParameters['period']!),
                initialSection: switch (state.uri.queryParameters['section']) {
                  'calendar' => JournalMonthlySection.calendar,
                  'tasks' => JournalMonthlySection.tasks,
                  _ => null,
                },
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/future',
              builder: (context, state) => const FutureScreen(),
            ),
            GoRoute(
              path: '/future/:period',
              builder: (context, state) => FutureHistoryScreen(
                key: state.pageKey,
                periodStart: state.pathParameters['period']!,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/collections',
              builder: (context, state) => const CollectionsScreen(),
            ),
            GoRoute(
              path: '/collections/:collectionId',
              builder: (context, state) => CollectionsScreen(
                key: state.pageKey,
                initialCollectionId: state.pathParameters['collectionId']!,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/index',
              builder: (context, state) => const IndexScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
