from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one match, found {count}")
    file.write_text(text.replace(old, new, 1))


def write(path: str, content: str) -> None:
    Path(path).write_text(content)


replace_once(
    "lib/core/session/journal_session.dart",
    """  Future<void> scheduleTaskToFuture({\n    required String entryId,\n    required String periodStart,\n  }) {\n""",
    """  Future<void> migrateTaskToCollection({\n    required String entryId,\n    required String collectionId,\n  }) {\n    return run(() async {\n      await taskActions.requireOpen(entryId: entryId);\n      await service.migrate(\n        sourceEntryId: entryId,\n        destinationOwner: JournalCollectionOwner(collectionId),\n      );\n    });\n  }\n\n  Future<void> scheduleTaskToFuture({\n    required String entryId,\n    required String periodStart,\n  }) {\n""",
)

replace_once(
    "lib/presentation/app_section_scope.dart",
    "  static const int futureSectionIndex = 2;\n",
    "  static const int futureSectionIndex = 2;\n  static const int collectionsSectionIndex = 3;\n",
)

write(
    "lib/features/journal/presentation/task_collection_migration_dialog.dart",
    """import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class TaskCollectionMigrationDataSource {
  Future<List<CollectionSummary>> listCollections();

  Future<void> migrateTask({
    required String entryId,
    required String collectionId,
  });
}

final Provider<TaskCollectionMigrationDataSource>
taskCollectionMigrationDataSourceProvider =
    Provider<TaskCollectionMigrationDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionTaskCollectionMigrationDataSource(session);
      }
      throw StateError('Task migration requires an unlocked journal session.');
    });

final class _SessionTaskCollectionMigrationDataSource
    implements TaskCollectionMigrationDataSource {
  const _SessionTaskCollectionMigrationDataSource(this._session);

  final JournalSession _session;

  @override
  Future<List<CollectionSummary>> listCollections() {
    return _session.listCollections();
  }

  @override
  Future<void> migrateTask({
    required String entryId,
    required String collectionId,
  }) {
    return _session.migrateTaskToCollection(
      entryId: entryId,
      collectionId: collectionId,
    );
  }
}

Future<String?> showTaskCollectionMigrationDialog({
  required BuildContext context,
  required TaskCollectionMigrationDataSource dataSource,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Future<List<CollectionSummary>> collectionsFuture =
      dataSource.listCollections();

  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.migrateTaskTitle),
      children: [
        FutureBuilder<List<CollectionSummary>>(
          future: collectionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(l10n.collectionsLoadFailed),
              );
            }

            final List<CollectionSummary> collections = snapshot.requireData;
            if (collections.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(l10n.emptyCollections),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final CollectionSummary collection in collections)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(collection.id),
                    child: Text(collection.title),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
""",
)

replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    "import 'journal_activity_guard.dart';\nimport 'task_schedule_dialog.dart';\n",
    "import 'journal_activity_guard.dart';\nimport 'task_collection_migration_dialog.dart';\nimport 'task_schedule_dialog.dart';\n",
)
replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    """        PopupMenuItem<_TaskAction>(\n          value: _TaskAction.schedule,\n          child: Text(l10n.scheduleTask),\n        ),\n""",
    """        PopupMenuItem<_TaskAction>(\n          value: _TaskAction.migrate,\n          child: Text(l10n.migrateTask),\n        ),\n        PopupMenuItem<_TaskAction>(\n          value: _TaskAction.schedule,\n          child: Text(l10n.scheduleTask),\n        ),\n""",
)
replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    """    final DateTime actionDate = _today;\n    String? schedulePeriodStart;\n    if (action == _TaskAction.schedule) {\n""",
    """    final DateTime actionDate = _today;\n    String? migrationCollectionId;\n    if (action == _TaskAction.migrate) {\n      migrationCollectionId = await showTaskCollectionMigrationDialog(\n        context: context,\n        dataSource: ref.read(taskCollectionMigrationDataSourceProvider),\n      );\n      if (!mounted || migrationCollectionId == null) {\n        return;\n      }\n    }\n\n    String? schedulePeriodStart;\n    if (action == _TaskAction.schedule) {\n""",
)
replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    """        case _TaskAction.schedule:\n          await dataSource.scheduleTaskToFuture(\n""",
    """        case _TaskAction.migrate:\n          await ref.read(taskCollectionMigrationDataSourceProvider).migrateTask(\n            entryId: entry.id,\n            collectionId: migrationCollectionId!,\n          );\n          break;\n        case _TaskAction.schedule:\n          await dataSource.scheduleTaskToFuture(\n""",
)
replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    "enum _TaskAction { complete, schedule, discard }\n",
    "enum _TaskAction { complete, migrate, schedule, discard }\n",
)

replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    "import 'journal_activity_guard.dart';\nimport 'task_schedule_dialog.dart';\n",
    "import 'journal_activity_guard.dart';\nimport 'task_collection_migration_dialog.dart';\nimport 'task_schedule_dialog.dart';\n",
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    """        PopupMenuItem<_MonthlyTaskAction>(\n          value: _MonthlyTaskAction.schedule,\n          child: Text(l10n.scheduleTask),\n        ),\n""",
    """        PopupMenuItem<_MonthlyTaskAction>(\n          value: _MonthlyTaskAction.migrate,\n          child: Text(l10n.migrateTask),\n        ),\n        PopupMenuItem<_MonthlyTaskAction>(\n          value: _MonthlyTaskAction.schedule,\n          child: Text(l10n.scheduleTask),\n        ),\n""",
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    """    final DateTime actionMonth = _month;\n    String? schedulePeriodStart;\n    if (action == _MonthlyTaskAction.schedule) {\n""",
    """    final DateTime actionMonth = _month;\n    String? migrationCollectionId;\n    if (action == _MonthlyTaskAction.migrate) {\n      migrationCollectionId = await showTaskCollectionMigrationDialog(\n        context: context,\n        dataSource: ref.read(taskCollectionMigrationDataSourceProvider),\n      );\n      if (!mounted || migrationCollectionId == null) {\n        return;\n      }\n    }\n\n    String? schedulePeriodStart;\n    if (action == _MonthlyTaskAction.schedule) {\n""",
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    """        case _MonthlyTaskAction.schedule:\n          await dataSource.scheduleTaskToFuture(\n""",
    """        case _MonthlyTaskAction.migrate:\n          await ref.read(taskCollectionMigrationDataSourceProvider).migrateTask(\n            entryId: entry.id,\n            collectionId: migrationCollectionId!,\n          );\n          break;\n        case _MonthlyTaskAction.schedule:\n          await dataSource.scheduleTaskToFuture(\n""",
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    "enum _MonthlyTaskAction { complete, schedule, discard }\n",
    "enum _MonthlyTaskAction { complete, migrate, schedule, discard }\n",
)

replace_once(
    "lib/features/journal/presentation/collections_screen.dart",
    "import 'package:daymark/l10n/app_localizations.dart';\n",
    "import 'package:daymark/l10n/app_localizations.dart';\nimport 'package:daymark/presentation/app_section_scope.dart';\n",
)
replace_once(
    "lib/features/journal/presentation/collections_screen.dart",
    """  bool _saving = false;\n  String? _taskActionEntryId;\n\n  @override\n  void initState() {\n""",
    """  bool _saving = false;\n  String? _taskActionEntryId;\n  bool _sectionScopeInitialized = false;\n  bool _wasCollectionsSectionActive = false;\n\n  @override\n  void initState() {\n""",
)
replace_once(
    "lib/features/journal/presentation/collections_screen.dart",
    """  @override\n  void dispose() {\n""",
    """  @override\n  void didChangeDependencies() {\n    super.didChangeDependencies();\n    final int? currentSectionIndex = AppSectionScope.maybeCurrentIndexOf(\n      context,\n    );\n    if (currentSectionIndex == null) {\n      return;\n    }\n\n    final bool isCollectionsSectionActive =\n        currentSectionIndex == AppSectionScope.collectionsSectionIndex;\n    if (_sectionScopeInitialized &&\n        isCollectionsSectionActive &&\n        !_wasCollectionsSectionActive) {\n      _collectionsFuture = _dataSource().list();\n      final String? collectionId = _selectedCollectionId;\n      if (collectionId != null) {\n        _collectionFuture = _dataSource().load(collectionId);\n      }\n    }\n    _sectionScopeInitialized = true;\n    _wasCollectionsSectionActive = isCollectionsSectionActive;\n  }\n\n  @override\n  void dispose() {\n""",
)

for path, migrate, title in [
    ("lib/l10n/app_en.arb", "Migrate", "Migrate task"),
    ("lib/l10n/app_pt.arb", "Migrar", "Migrar tarefa"),
    ("lib/l10n/app_pt_BR.arb", "Migrar", "Migrar tarefa"),
]:
    replace_once(
        path,
        '  "completeTask": ' + ('"Complete",\n' if path.endswith('app_en.arb') else '"Concluir",\n'),
        '  "completeTask": ' + ('"Complete",\n' if path.endswith('app_en.arb') else '"Concluir",\n')
        + f'  "migrateTask": "{migrate}",\n'
        + f'  "migrateTaskTitle": "{title}",\n',
    )

write(
    "test/session/collection_migration_session_test.dart",
    """import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-collection-migration-session-test-',
    );
    files = JournalFiles(directory);
    manager = JournalSessionManager(
      files: files,
      keyEnvelopeService: KeyEnvelopeService(parameters: Argon2Parameters.test),
    );
  });

  tearDown(() async {
    await manager.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test('Task migration to Collection preserves source and persists lineage', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'collection migration journal',
    );
    final DailyLogSnapshot daily = await created.loadDailyLog('2026-09-03');
    await created.captureDailyLogEntry(
      logId: daily.logId,
      type: JournalEntryType.task,
      content: 'Move into project',
    );
    final DailyLogSnapshot captured = await created.loadDailyLog('2026-09-03');
    final String collectionId = await created.createCollection(title: 'Project');

    await created.migrateTaskToCollection(
      entryId: captured.entries.single.id,
      collectionId: collectionId,
    );

    final DailyLogSnapshot sourceAfter = await created.loadDailyLog('2026-09-03');
    final CollectionSnapshot destinationAfter = await created.loadCollection(
      collectionId,
    );
    expect(sourceAfter.entries.single.taskState, JournalTaskState.migrated);
    expect(destinationAfter.entries, hasLength(1));
    expect(destinationAfter.entries.single.content, 'Move into project');
    expect(destinationAfter.entries.single.type, JournalEntryType.task);
    expect(destinationAfter.entries.single.taskState, JournalTaskState.open);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'collection migration journal',
    );
    final DailyLogSnapshot persistedSource = await reopened.loadDailyLog(
      '2026-09-03',
    );
    final CollectionSnapshot persistedDestination = await reopened.loadCollection(
      collectionId,
    );
    expect(persistedSource.entries.single.taskState, JournalTaskState.migrated);
    expect(persistedDestination.entries.single.taskState, JournalTaskState.open);
  });
}
""",
)

write(
    "test/journal/task_collection_migration_screen_test.dart",
    """import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/monthly_screen.dart';
import 'package:daymark/features/journal/presentation/task_collection_migration_dialog.dart';
import 'package:daymark/features/journal/presentation/today_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Today migrates an open Task into a selected Collection', (
    tester,
  ) async {
    final _TodayJournal today = _TodayJournal();
    final _MigrationDataSource migration = _MigrationDataSource(
      onMigrate: (entryId) => today.migrate(entryId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayJournalDataSourceProvider.overrideWithValue(today),
          taskCollectionMigrationDataSourceProvider.overrideWithValue(migration),
        ],
        child: _app(const TodayScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Migrate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(migration.migratedEntryId, 'today-task');
    expect(migration.collectionId, 'project');
    expect(today.entry.taskState, JournalTaskState.migrated);
    expect(find.text('>'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Monthly migrates an open Task into a selected Collection', (
    tester,
  ) async {
    final _MonthlyJournal monthly = _MonthlyJournal();
    final _MigrationDataSource migration = _MigrationDataSource(
      onMigrate: (entryId) => monthly.migrate(entryId),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monthlyJournalDataSourceProvider.overrideWithValue(monthly),
          taskCollectionMigrationDataSourceProvider.overrideWithValue(migration),
        ],
        child: _app(MonthlyScreen(initialMonth: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Tasks'));
    await tester.pump();

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Migrate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(migration.migratedEntryId, 'monthly-task');
    expect(migration.collectionId, 'project');
    expect(monthly.entry.taskState, JournalTaskState.migrated);
    expect(find.text('>'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });
}

MaterialApp _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

final class _MigrationDataSource implements TaskCollectionMigrationDataSource {
  _MigrationDataSource({required this.onMigrate});

  final void Function(String entryId) onMigrate;
  String? migratedEntryId;
  String? collectionId;

  @override
  Future<List<CollectionSummary>> listCollections() async => const [
    CollectionSummary(id: 'project', title: 'Project'),
  ];

  @override
  Future<void> migrateTask({
    required String entryId,
    required String collectionId,
  }) async {
    migratedEntryId = entryId;
    this.collectionId = collectionId;
    onMigrate(entryId);
  }
}

final class _TodayJournal implements TodayJournalDataSource {
  DailyLogEntry entry = const DailyLogEntry(
    id: 'today-task',
    type: JournalEntryType.task,
    taskState: JournalTaskState.open,
    content: 'Move today',
    ordinal: 0,
  );

  void migrate(String entryId) {
    expect(entryId, entry.id);
    entry = DailyLogEntry(
      id: entry.id,
      type: entry.type,
      taskState: JournalTaskState.migrated,
      content: entry.content,
      ordinal: entry.ordinal,
    );
  }

  @override
  Future<DailyLogSnapshot> load(String methodDate) async => DailyLogSnapshot(
    logId: 'daily',
    methodDate: methodDate,
    entries: [entry],
  );

  @override
  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  }) async {}

  @override
  Future<void> completeTask({required String entryId}) async {}

  @override
  Future<void> scheduleTaskToFuture({
    required String entryId,
    required String periodStart,
  }) async {}

  @override
  Future<void> discardTask({required String entryId}) async {}
}

final class _MonthlyJournal implements MonthlyJournalDataSource {
  MonthlyLogEntry entry = const MonthlyLogEntry(
    id: 'monthly-task',
    type: JournalEntryType.task,
    taskState: JournalTaskState.open,
    content: 'Move monthly',
    ordinal: 0,
    section: JournalMonthlySection.tasks,
    calendarDate: null,
  );

  void migrate(String entryId) {
    expect(entryId, entry.id);
    entry = MonthlyLogEntry(
      id: entry.id,
      type: entry.type,
      taskState: JournalTaskState.migrated,
      content: entry.content,
      ordinal: entry.ordinal,
      section: entry.section,
      calendarDate: entry.calendarDate,
    );
  }

  @override
  Future<MonthlyLogSnapshot> load(String periodStart) async => MonthlyLogSnapshot(
    logId: 'monthly',
    periodStart: periodStart,
    calendarEntries: const [],
    taskEntries: [entry],
  );

  @override
  Future<void> captureCalendarEvent({
    required String logId,
    required String calendarDate,
    required String content,
  }) async {}

  @override
  Future<void> captureTask({required String logId, required String content}) async {}

  @override
  Future<void> completeTask({required String entryId}) async {}

  @override
  Future<void> scheduleTaskToFuture({
    required String entryId,
    required String periodStart,
  }) async {}

  @override
  Future<void> discardTask({required String entryId}) async {}
}
""",
)

write(
    "test/journal/collections_activation_test.dart",
    """import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/collections_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:daymark/presentation/app_section_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Collections refreshes selected Collection when reactivated', (
    tester,
  ) async {
    final _CollectionsDataSource dataSource = _CollectionsDataSource();
    final ValueNotifier<int> currentSection = ValueNotifier<int>(
      AppSectionScope.collectionsSectionIndex,
    );
    addTearDown(currentSection.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionsJournalDataSourceProvider.overrideWithValue(dataSource),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppSectionScope(
              currentIndex: currentSection,
              child: const CollectionsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Project'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Original'), findsOneWidget);

    currentSection.value = 0;
    await tester.pump();
    dataSource.addMigratedTask();
    expect(find.text('Migrated from Today'), findsNothing);

    currentSection.value = AppSectionScope.collectionsSectionIndex;
    await tester.pump();
    await tester.pump();
    expect(find.text('Migrated from Today'), findsOneWidget);
  });
}

final class _CollectionsDataSource implements CollectionsJournalDataSource {
  final List<CollectionEntry> entries = [
    const CollectionEntry(
      id: 'original',
      type: JournalEntryType.note,
      taskState: null,
      content: 'Original',
      ordinal: 0,
    ),
  ];

  void addMigratedTask() {
    entries.add(
      const CollectionEntry(
        id: 'migrated',
        type: JournalEntryType.task,
        taskState: JournalTaskState.open,
        content: 'Migrated from Today',
        ordinal: 1,
      ),
    );
  }

  @override
  Future<List<CollectionSummary>> list() async => const [
    CollectionSummary(id: 'project', title: 'Project'),
  ];

  @override
  Future<String> create({required String title}) async => 'project';

  @override
  Future<CollectionSnapshot> load(String collectionId) async => CollectionSnapshot(
    id: 'project',
    title: 'Project',
    entries: entries,
  );

  @override
  Future<void> capture({
    required String collectionId,
    required JournalEntryType type,
    required String content,
  }) async {}

  @override
  Future<void> completeTask({required String entryId}) async {}

  @override
  Future<void> discardTask({required String entryId}) async {}
}
""",
)

print("PR #21 patch applied")
