from pathlib import Path
import json


def read(path: str) -> str:
    return Path(path).read_text()


def write(path: str, content: str) -> None:
    Path(path).write_text(content)


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one match, found {count}")
    write(path, text.replace(old, new, 1))


def replace_section(path: str, start: str, end: str, replacement: str) -> None:
    text = read(path)
    start_index = text.find(start)
    if start_index < 0:
        raise SystemExit(f"{path}: start marker not found: {start!r}")
    end_index = text.find(end, start_index)
    if end_index < 0:
        raise SystemExit(f"{path}: end marker not found: {end!r}")
    write(path, text[:start_index] + replacement + text[end_index:])


def add_l10n(path: str, values: dict[str, str]) -> None:
    data = json.loads(read(path))
    for key, value in values.items():
        data[key] = value
    write(path, json.dumps(data, ensure_ascii=False, indent=2) + "\n")


write(
    "lib/features/journal/data/collection_repository.dart",
    r'''import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';

final class CollectionSummary {
  const CollectionSummary({required this.id, required this.title});

  final String id;
  final String title;
}

final class CollectionEntry {
  const CollectionEntry({
    required this.id,
    required this.type,
    required this.taskState,
    required this.content,
    required this.ordinal,
  });

  final String id;
  final JournalEntryType type;
  final JournalTaskState? taskState;
  final String content;
  final int ordinal;
}

final class CollectionReferenceEntry {
  const CollectionReferenceEntry({
    required this.id,
    required this.type,
    required this.taskState,
    required this.content,
    required this.ordinal,
  });

  final String id;
  final JournalEntryType type;
  final JournalTaskState? taskState;
  final String content;
  final int ordinal;
}

final class CollectionSnapshot {
  CollectionSnapshot({
    required this.id,
    required this.title,
    required List<CollectionEntry> entries,
    List<CollectionReferenceEntry> references = const [],
  }) : entries = List<CollectionEntry>.unmodifiable(entries),
       references = List<CollectionReferenceEntry>.unmodifiable(references);

  final String id;
  final String title;
  final List<CollectionEntry> entries;
  final List<CollectionReferenceEntry> references;
}

/// Focused read/write boundary for Bullet Journal Collections.
///
/// Reads query encrypted storage directly. Mutations continue through the
/// semantic [JournalService], which owns entry placement/reference invariants.
final class CollectionRepository {
  const CollectionRepository(this._database, this._journalService);

  final DaymarkDatabase _database;
  final JournalService _journalService;

  Future<List<CollectionSummary>> list() async {
    final rows = await _database.customSelect('''
      SELECT id, title
      FROM collections
      ORDER BY created_at, id
    ''').get();

    return <CollectionSummary>[
      for (final row in rows)
        CollectionSummary(
          id: row.read<String>('id'),
          title: row.read<String>('title'),
        ),
    ];
  }

  Future<String> create({required String title}) {
    return _journalService.createCollection(title: title);
  }

  Future<CollectionSnapshot> load(String collectionId) async {
    final collection = await _database
        .customSelect(
          'SELECT id, title FROM collections WHERE id = ?',
          variables: <Variable<Object>>[Variable.withString(collectionId)],
        )
        .getSingleOrNull();
    if (collection == null) {
      throw JournalNotFoundException('Collection', collectionId);
    }

    final ownedRows = await _database
        .customSelect(
          '''
          SELECT
            e.id,
            e.entry_type,
            e.task_state,
            e.content,
            p.ordinal
          FROM entry_placements p
          JOIN entries e ON e.id = p.entry_id
          WHERE p.collection_id = ?
          ORDER BY p.ordinal
          ''',
          variables: <Variable<Object>>[Variable.withString(collectionId)],
        )
        .get();

    final referenceRows = await _database
        .customSelect(
          '''
          SELECT
            e.id,
            e.entry_type,
            e.task_state,
            e.content,
            r.ordinal
          FROM collection_references r
          JOIN entries e ON e.id = r.entry_id
          WHERE r.collection_id = ?
          ORDER BY r.ordinal
          ''',
          variables: <Variable<Object>>[Variable.withString(collectionId)],
        )
        .get();

    return CollectionSnapshot(
      id: collection.read<String>('id'),
      title: collection.read<String>('title'),
      entries: <CollectionEntry>[
        for (final row in ownedRows)
          CollectionEntry(
            id: row.read<String>('id'),
            type: _entryTypeFromCode(row.read<String>('entry_type')),
            taskState: _taskStateFromCode(
              row.readNullable<String>('task_state'),
            ),
            content: row.read<String>('content'),
            ordinal: row.read<int>('ordinal'),
          ),
      ],
      references: <CollectionReferenceEntry>[
        for (final row in referenceRows)
          CollectionReferenceEntry(
            id: row.read<String>('id'),
            type: _entryTypeFromCode(row.read<String>('entry_type')),
            taskState: _taskStateFromCode(
              row.readNullable<String>('task_state'),
            ),
            content: row.read<String>('content'),
            ordinal: row.read<int>('ordinal'),
          ),
      ],
    );
  }

  Future<void> capture({
    required String collectionId,
    required JournalEntryType type,
    required String content,
  }) async {
    await _journalService.capture(
      type: type,
      content: content,
      owner: JournalCollectionOwner(collectionId),
    );
  }

  Future<void> reference({
    required String collectionId,
    required String entryId,
  }) {
    return _journalService.referenceInCollection(
      collectionId: collectionId,
      entryId: entryId,
    );
  }
}

JournalEntryType _entryTypeFromCode(String code) => switch (code) {
  'task' => JournalEntryType.task,
  'event' => JournalEntryType.event,
  'note' => JournalEntryType.note,
  _ => throw JournalInvariantException('Unknown persisted entry type: $code.'),
};

JournalTaskState? _taskStateFromCode(String? code) => switch (code) {
  null => null,
  'open' => JournalTaskState.open,
  'completed' => JournalTaskState.completed,
  'migrated' => JournalTaskState.migrated,
  'scheduled' => JournalTaskState.scheduled,
  'discarded' => JournalTaskState.discarded,
  _ => throw JournalInvariantException('Unknown persisted task state: $code.'),
};
''',
)

replace_once(
    "lib/core/session/journal_session.dart",
    '''  Future<void> migrateTaskToCollection({
    required String entryId,
    required String collectionId,
  }) {
''',
    '''  Future<void> referenceEntryInCollection({
    required String entryId,
    required String collectionId,
  }) {
    return run(
      () => collections.reference(
        collectionId: collectionId,
        entryId: entryId,
      ),
    );
  }

  Future<void> migrateTaskToCollection({
    required String entryId,
    required String collectionId,
  }) {
''',
)

write(
    "lib/features/journal/presentation/entry_collection_reference_dialog.dart",
    r'''import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class EntryCollectionReferenceDataSource {
  Future<List<CollectionSummary>> listCollections();

  Future<void> referenceEntry({
    required String entryId,
    required String collectionId,
  });
}

final Provider<EntryCollectionReferenceDataSource>
entryCollectionReferenceDataSourceProvider =
    Provider<EntryCollectionReferenceDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionEntryCollectionReferenceDataSource(session);
      }
      throw StateError(
        'Collection references require an unlocked journal session.',
      );
    });

final class _SessionEntryCollectionReferenceDataSource
    implements EntryCollectionReferenceDataSource {
  const _SessionEntryCollectionReferenceDataSource(this._session);

  final JournalSession _session;

  @override
  Future<List<CollectionSummary>> listCollections() {
    return _session.listCollections();
  }

  @override
  Future<void> referenceEntry({
    required String entryId,
    required String collectionId,
  }) {
    return _session.referenceEntryInCollection(
      entryId: entryId,
      collectionId: collectionId,
    );
  }
}

Future<String?> showEntryCollectionReferenceDialog({
  required BuildContext context,
  required EntryCollectionReferenceDataSource dataSource,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Future<List<CollectionSummary>> collectionsFuture = dataSource
      .listCollections();

  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.referenceEntryTitle),
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
''',
)

# Today: all chronological entry types can be referenced. Task-only actions stay
# limited to open Tasks.
replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    "import 'journal_activity_guard.dart';\n",
    "import 'entry_collection_reference_dialog.dart';\nimport 'journal_activity_guard.dart';\n",
)
text = read("lib/features/journal/presentation/today_screen.dart")
text = text.replace("_taskActionEntryId", "_entryActionId")
text = text.replace("_TaskAction", "_EntryAction")
text = text.replace("_applyTaskAction", "_applyEntryAction")
write("lib/features/journal/presentation/today_screen.dart", text)
replace_section(
    "lib/features/journal/presentation/today_screen.dart",
    "  Widget _buildEntryMarker(\n",
    "  Widget _buildComposer(",
    r'''  Widget _buildEntryMarker(
    BuildContext context,
    AppLocalizations l10n,
    DailyLogEntry entry,
  ) {
    if (_entryActionId == entry.id) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;
    final Text marker = Text(
      _entrySymbol(entry),
      textAlign: TextAlign.center,
      style: entry.taskState == JournalTaskState.discarded
          ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
          : markerStyle,
    );
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;

    return PopupMenuButton<_EntryAction>(
      enabled: _entryActionId == null,
      tooltip: l10n.entryActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyEntryAction(entry, action));
      },
      itemBuilder: (context) => [
        if (openTask)
          PopupMenuItem<_EntryAction>(
            value: _EntryAction.complete,
            child: Text(l10n.completeTask),
          ),
        if (openTask)
          PopupMenuItem<_EntryAction>(
            value: _EntryAction.migrate,
            child: Text(l10n.migrateTask),
          ),
        if (openTask)
          PopupMenuItem<_EntryAction>(
            value: _EntryAction.schedule,
            child: Text(l10n.scheduleTask),
          ),
        PopupMenuItem<_EntryAction>(
          value: _EntryAction.reference,
          child: Text(l10n.referenceEntry),
        ),
        if (openTask)
          PopupMenuItem<_EntryAction>(
            value: _EntryAction.discard,
            child: Text(l10n.discardTask),
          ),
      ],
      child: marker,
    );
  }

''',
)
replace_section(
    "lib/features/journal/presentation/today_screen.dart",
    "  Future<void> _applyEntryAction(\n",
    "  Future<void> _lock()",
    r'''  Future<void> _applyEntryAction(
    DailyLogEntry entry,
    _EntryAction action,
  ) async {
    if (_entryActionId != null) {
      return;
    }
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;
    if (action != _EntryAction.reference && !openTask) {
      return;
    }

    final DateTime actionDate = _today;
    String? migrationCollectionId;
    if (action == _EntryAction.migrate) {
      migrationCollectionId = await showTaskCollectionMigrationDialog(
        context: context,
        dataSource: ref.read(taskCollectionMigrationDataSourceProvider),
      );
      if (!mounted || migrationCollectionId == null) {
        return;
      }
    }

    String? referenceCollectionId;
    if (action == _EntryAction.reference) {
      referenceCollectionId = await showEntryCollectionReferenceDialog(
        context: context,
        dataSource: ref.read(entryCollectionReferenceDataSourceProvider),
      );
      if (!mounted || referenceCollectionId == null) {
        return;
      }
    }

    String? schedulePeriodStart;
    if (action == _EntryAction.schedule) {
      schedulePeriodStart = await showTaskScheduleDialog(
        context: context,
        anchor: actionDate,
      );
      if (!mounted || schedulePeriodStart == null) {
        return;
      }
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _entryActionId = entry.id);

    try {
      final TodayJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _EntryAction.complete:
          await dataSource.completeTask(entryId: entry.id);
          break;
        case _EntryAction.migrate:
          await ref
              .read(taskCollectionMigrationDataSourceProvider)
              .migrateTask(
                entryId: entry.id,
                collectionId: migrationCollectionId!,
              );
          break;
        case _EntryAction.schedule:
          await dataSource.scheduleTaskToFuture(
            entryId: entry.id,
            periodStart: schedulePeriodStart!,
          );
          break;
        case _EntryAction.reference:
          await ref
              .read(entryCollectionReferenceDataSourceProvider)
              .referenceEntry(
                entryId: entry.id,
                collectionId: referenceCollectionId!,
              );
          break;
        case _EntryAction.discard:
          await dataSource.discardTask(entryId: entry.id);
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMethodDate(_today));
        _entryActionId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedJournalError('entry action', error, stackTrace);
      if (!mounted) {
        return;
      }
      final String message = action == _EntryAction.reference
          ? l10n.referenceEntryFailed
          : l10n.taskActionFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() => _entryActionId = null);
    }
  }

''',
)
replace_once(
    "lib/features/journal/presentation/today_screen.dart",
    "enum _EntryAction { complete, migrate, schedule, discard }",
    "enum _EntryAction { complete, migrate, schedule, reference, discard }",
)

# Monthly: references are available for Calendar Events and every Task state.
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    "import 'journal_activity_guard.dart';\n",
    "import 'entry_collection_reference_dialog.dart';\nimport 'journal_activity_guard.dart';\n",
)
text = read("lib/features/journal/presentation/monthly_screen.dart")
text = text.replace("_taskActionEntryId", "_entryActionId")
text = text.replace("_MonthlyTaskAction", "_MonthlyEntryAction")
text = text.replace("_applyTaskAction", "_applyEntryAction")
write("lib/features/journal/presentation/monthly_screen.dart", text)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    '''                    JournalMonthlySection.calendar => _buildCalendar(
                      context,
                      snapshot.requireData,
                    ),
''',
    '''                    JournalMonthlySection.calendar => _buildCalendar(
                      context,
                      l10n,
                      snapshot.requireData,
                    ),
''',
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    '''  Widget _buildCalendar(BuildContext context, MonthlyLogSnapshot snapshot) {
''',
    '''  Widget _buildCalendar(
    BuildContext context,
    AppLocalizations l10n,
    MonthlyLogSnapshot snapshot,
  ) {
''',
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    '''                    for (final MonthlyLogEntry entry in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '○ ${entry.content}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
''',
    '''                    for (final MonthlyLogEntry entry in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: PopupMenuButton<_MonthlyEntryAction>(
                          enabled: _entryActionId == null,
                          tooltip: l10n.entryActions,
                          padding: EdgeInsets.zero,
                          onSelected: (action) {
                            unawaited(_applyEntryAction(entry, action));
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<_MonthlyEntryAction>(
                              value: _MonthlyEntryAction.reference,
                              child: Text(l10n.referenceEntry),
                            ),
                          ],
                          child: Text(
                            '○ ${entry.content}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
''',
)
replace_section(
    "lib/features/journal/presentation/monthly_screen.dart",
    "  Widget _buildTaskMarker(\n",
    "  Widget _buildComposer(",
    r'''  Widget _buildTaskMarker(
    BuildContext context,
    AppLocalizations l10n,
    MonthlyLogEntry entry,
  ) {
    if (_entryActionId == entry.id) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;
    final Text marker = Text(
      _taskSymbol(entry.taskState),
      textAlign: TextAlign.center,
      style: entry.taskState == JournalTaskState.discarded
          ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
          : markerStyle,
    );
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;

    return PopupMenuButton<_MonthlyEntryAction>(
      enabled: _entryActionId == null,
      tooltip: l10n.entryActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyEntryAction(entry, action));
      },
      itemBuilder: (context) => [
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.complete,
            child: Text(l10n.completeTask),
          ),
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.migrate,
            child: Text(l10n.migrateTask),
          ),
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.schedule,
            child: Text(l10n.scheduleTask),
          ),
        PopupMenuItem<_MonthlyEntryAction>(
          value: _MonthlyEntryAction.reference,
          child: Text(l10n.referenceEntry),
        ),
        if (openTask)
          PopupMenuItem<_MonthlyEntryAction>(
            value: _MonthlyEntryAction.discard,
            child: Text(l10n.discardTask),
          ),
      ],
      child: marker,
    );
  }

''',
)
replace_section(
    "lib/features/journal/presentation/monthly_screen.dart",
    "  Future<void> _applyEntryAction(\n",
    "  Future<void> _lock()",
    r'''  Future<void> _applyEntryAction(
    MonthlyLogEntry entry,
    _MonthlyEntryAction action,
  ) async {
    if (_entryActionId != null) {
      return;
    }
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;
    if (action != _MonthlyEntryAction.reference && !openTask) {
      return;
    }

    final DateTime actionMonth = _month;
    String? migrationCollectionId;
    if (action == _MonthlyEntryAction.migrate) {
      migrationCollectionId = await showTaskCollectionMigrationDialog(
        context: context,
        dataSource: ref.read(taskCollectionMigrationDataSourceProvider),
      );
      if (!mounted || migrationCollectionId == null) {
        return;
      }
    }

    String? referenceCollectionId;
    if (action == _MonthlyEntryAction.reference) {
      referenceCollectionId = await showEntryCollectionReferenceDialog(
        context: context,
        dataSource: ref.read(entryCollectionReferenceDataSourceProvider),
      );
      if (!mounted || referenceCollectionId == null) {
        return;
      }
    }

    String? schedulePeriodStart;
    if (action == _MonthlyEntryAction.schedule) {
      schedulePeriodStart = await showTaskScheduleDialog(
        context: context,
        anchor: actionMonth,
      );
      if (!mounted || schedulePeriodStart == null) {
        return;
      }
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _entryActionId = entry.id);

    try {
      final MonthlyJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _MonthlyEntryAction.complete:
          await dataSource.completeTask(entryId: entry.id);
          break;
        case _MonthlyEntryAction.migrate:
          await ref
              .read(taskCollectionMigrationDataSourceProvider)
              .migrateTask(
                entryId: entry.id,
                collectionId: migrationCollectionId!,
              );
          break;
        case _MonthlyEntryAction.schedule:
          await dataSource.scheduleTaskToFuture(
            entryId: entry.id,
            periodStart: schedulePeriodStart!,
          );
          break;
        case _MonthlyEntryAction.reference:
          await ref
              .read(entryCollectionReferenceDataSourceProvider)
              .referenceEntry(
                entryId: entry.id,
                collectionId: referenceCollectionId!,
              );
          break;
        case _MonthlyEntryAction.discard:
          await dataSource.discardTask(entryId: entry.id);
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotFuture = dataSource.load(formatJournalMonthStart(_month));
        _entryActionId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedMonthlyError('entry action', error, stackTrace);
      if (!mounted) {
        return;
      }
      final String message = action == _MonthlyEntryAction.reference
          ? l10n.referenceEntryFailed
          : l10n.taskActionFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() => _entryActionId = null);
    }
  }

''',
)
replace_once(
    "lib/features/journal/presentation/monthly_screen.dart",
    "enum _MonthlyEntryAction { complete, migrate, schedule, discard }",
    "enum _MonthlyEntryAction { complete, migrate, schedule, reference, discard }",
)

# Future: every visible entry can be referenced; terminal/non-Task entries expose
# only the reference action.
replace_once(
    "lib/features/journal/presentation/future_screen.dart",
    "import 'journal_activity_guard.dart';\n",
    "import 'entry_collection_reference_dialog.dart';\nimport 'journal_activity_guard.dart';\n",
)
text = read("lib/features/journal/presentation/future_screen.dart")
text = text.replace("_taskActionEntryId", "_entryActionId")
text = text.replace("_FutureTaskAction", "_FutureEntryAction")
text = text.replace("_applyTaskAction", "_applyEntryAction")
write("lib/features/journal/presentation/future_screen.dart", text)
replace_section(
    "lib/features/journal/presentation/future_screen.dart",
    "  Widget _buildEntryMarker(\n",
    "  Widget _buildComposer(",
    r'''  Widget _buildEntryMarker(
    BuildContext context,
    AppLocalizations l10n,
    FutureLogEntry entry,
  ) {
    if (_entryActionId == entry.id) {
      return const Center(
        child: SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;
    final Text marker = Text(
      _entrySymbol(entry),
      textAlign: TextAlign.center,
      style: entry.taskState == JournalTaskState.discarded
          ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
          : markerStyle,
    );
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;

    return PopupMenuButton<_FutureEntryAction>(
      enabled: _entryActionId == null,
      tooltip: l10n.entryActions,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        unawaited(_applyEntryAction(entry, action));
      },
      itemBuilder: (context) => [
        if (openTask)
          PopupMenuItem<_FutureEntryAction>(
            value: _FutureEntryAction.complete,
            child: Text(l10n.completeTask),
          ),
        PopupMenuItem<_FutureEntryAction>(
          value: _FutureEntryAction.reference,
          child: Text(l10n.referenceEntry),
        ),
        if (openTask)
          PopupMenuItem<_FutureEntryAction>(
            value: _FutureEntryAction.discard,
            child: Text(l10n.discardTask),
          ),
      ],
      child: marker,
    );
  }

''',
)
replace_section(
    "lib/features/journal/presentation/future_screen.dart",
    "  Future<void> _applyEntryAction(\n",
    "  Future<void> _lock()",
    r'''  Future<void> _applyEntryAction(
    FutureLogEntry entry,
    _FutureEntryAction action,
  ) async {
    if (_entryActionId != null) {
      return;
    }
    final bool openTask =
        entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open;
    if (action != _FutureEntryAction.reference && !openTask) {
      return;
    }

    String? referenceCollectionId;
    if (action == _FutureEntryAction.reference) {
      referenceCollectionId = await showEntryCollectionReferenceDialog(
        context: context,
        dataSource: ref.read(entryCollectionReferenceDataSourceProvider),
      );
      if (!mounted || referenceCollectionId == null) {
        return;
      }
    }

    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _entryActionId = entry.id);

    try {
      final FutureJournalDataSource dataSource = _dataSource();
      switch (action) {
        case _FutureEntryAction.complete:
          await dataSource.completeTask(entryId: entry.id);
          break;
        case _FutureEntryAction.reference:
          await ref
              .read(entryCollectionReferenceDataSourceProvider)
              .referenceEntry(
                entryId: entry.id,
                collectionId: referenceCollectionId!,
              );
          break;
        case _FutureEntryAction.discard:
          await dataSource.discardTask(entryId: entry.id);
          break;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshotsFuture = _loadSnapshots();
        _entryActionId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedFutureError('entry action', error, stackTrace);
      if (!mounted) {
        return;
      }
      final String message = action == _FutureEntryAction.reference
          ? l10n.referenceEntryFailed
          : l10n.taskActionFailed;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() => _entryActionId = null);
    }
  }

''',
)
replace_once(
    "lib/features/journal/presentation/future_screen.dart",
    "enum _FutureEntryAction { complete, discard }",
    "enum _FutureEntryAction { complete, reference, discard }",
)

# Collection rendering keeps owned content and references visually/domain-wise
# separate. References are deliberately read-only in this slice.
replace_once(
    "lib/features/journal/presentation/collections_screen.dart",
    '''            Expanded(
              child: collection.entries.isEmpty
                  ? Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(l10n.emptyCollection),
                    )
                  : ListView.separated(
                      itemCount: collection.entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) =>
                          _buildEntry(l10n, collection.entries[index]),
                    ),
            ),
''',
    '''            Expanded(child: _buildCollectionContent(l10n, collection)),
''',
)
replace_once(
    "lib/features/journal/presentation/collections_screen.dart",
    "  Widget _buildEntry(AppLocalizations l10n, CollectionEntry entry) {\n",
    r'''  Widget _buildCollectionContent(
    AppLocalizations l10n,
    CollectionSnapshot collection,
  ) {
    if (collection.entries.isEmpty && collection.references.isEmpty) {
      return Align(
        alignment: AlignmentDirectional.topStart,
        child: Text(l10n.emptyCollection),
      );
    }

    return ListView(
      children: [
        for (int index = 0; index < collection.entries.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == collection.entries.length - 1 ? 0 : 6,
            ),
            child: _buildEntry(l10n, collection.entries[index]),
          ),
        if (collection.references.isNotEmpty) ...[
          if (collection.entries.isNotEmpty) const SizedBox(height: 20),
          Text(
            l10n.collectionReferences,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          for (int index = 0; index < collection.references.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == collection.references.length - 1 ? 0 : 6,
              ),
              child: _buildReference(collection.references[index]),
            ),
        ],
      ],
    );
  }

  Widget _buildReference(CollectionReferenceEntry entry) {
    final bool discarded = entry.taskState == JournalTaskState.discarded;
    final TextStyle? contentStyle = Theme.of(context).textTheme.bodyLarge;
    final TextStyle? markerStyle = Theme.of(context).textTheme.titleMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            _entrySymbol(entry.type, entry.taskState),
            textAlign: TextAlign.center,
            style: discarded
                ? markerStyle?.copyWith(decoration: TextDecoration.lineThrough)
                : markerStyle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.content,
            style: discarded
                ? contentStyle?.copyWith(decoration: TextDecoration.lineThrough)
                : contentStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(AppLocalizations l10n, CollectionEntry entry) {
''',
)
replace_once(
    "lib/features/journal/presentation/collections_screen.dart",
    "      _entrySymbol(entry),\n",
    "      _entrySymbol(entry.type, entry.taskState),\n",
)
replace_section(
    "lib/features/journal/presentation/collections_screen.dart",
    "String _entrySymbol(CollectionEntry entry) => switch (entry.type) {\n",
    "\nvoid _reportUnexpectedCollectionsError(",
    r'''String _entrySymbol(
  JournalEntryType type,
  JournalTaskState? taskState,
) => switch (type) {
  JournalEntryType.task => switch (taskState) {
    JournalTaskState.completed => '×',
    JournalTaskState.migrated => '>',
    JournalTaskState.scheduled => '<',
    JournalTaskState.discarded => '•',
    JournalTaskState.open => '•',
    null => '•',
  },
  JournalEntryType.event => '○',
  JournalEntryType.note => '–',
};
''',
)

add_l10n(
    "lib/l10n/app_en.arb",
    {
        "entryActions": "Entry actions",
        "referenceEntry": "Reference",
        "referenceEntryTitle": "Reference in Collection",
        "referenceEntryFailed": "Could not add this Collection reference.",
        "collectionReferences": "References",
    },
)
add_l10n(
    "lib/l10n/app_pt.arb",
    {
        "entryActions": "Ações da entrada",
        "referenceEntry": "Referenciar",
        "referenceEntryTitle": "Referenciar em Coleção",
        "referenceEntryFailed": "Não foi possível adicionar esta referência à Coleção.",
        "collectionReferences": "Referências",
    },
)
add_l10n(
    "lib/l10n/app_pt_BR.arb",
    {
        "entryActions": "Ações da entrada",
        "referenceEntry": "Referenciar",
        "referenceEntryTitle": "Referenciar em Coleção",
        "referenceEntryFailed": "Não foi possível adicionar esta referência à Coleção.",
        "collectionReferences": "Referências",
    },
)

# Repository coverage: a reference must not become ownership or mutate Task state.
replace_once(
    "test/journal/collection_repository_test.dart",
    "  late CollectionRepository collections;\n  late _IdSequence ids;\n",
    "  late CollectionRepository collections;\n  late JournalService service;\n  late _IdSequence ids;\n",
)
replace_once(
    "test/journal/collection_repository_test.dart",
    "    final JournalService service = JournalService(\n",
    "    service = JournalService(\n",
)
replace_once(
    "test/journal/collection_repository_test.dart",
    "  test(\n    'unknown Collection rejects capture without partial entry write',\n",
    r'''  test('loads references separately without changing source ownership', () async {
    final String collectionId = await collections.create(title: 'Reading');
    final String dailyLogId = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-03',
    );
    final String entryId = await service.capture(
      type: JournalEntryType.task,
      content: 'Read linked article',
      owner: JournalLogOwner(logId: dailyLogId),
    );

    await collections.reference(
      collectionId: collectionId,
      entryId: entryId,
    );

    final CollectionSnapshot snapshot = await collections.load(collectionId);
    expect(snapshot.entries, isEmpty);
    expect(snapshot.references, hasLength(1));
    expect(snapshot.references.single.id, entryId);
    expect(snapshot.references.single.taskState, JournalTaskState.open);
    expect(snapshot.references.single.content, 'Read linked article');

    final placement = await database
        .customSelect(
          'SELECT log_id, collection_id FROM entry_placements WHERE entry_id = ?',
          variables: <Variable<Object>>[Variable.withString(entryId)],
        )
        .getSingle();
    expect(placement.read<String>('log_id'), dailyLogId);
    expect(placement.readNullable<String>('collection_id'), isNull);
  });

  test(
    'unknown Collection rejects capture without partial entry write',
''',
)

write(
    "test/session/collection_reference_session_test.dart",
    r'''import 'dart:io';

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
      'daymark-collection-reference-session-test-',
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

  test('Collection reference preserves source and survives lock/unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'collection reference journal',
    );
    final DailyLogSnapshot daily = await created.loadDailyLog('2026-09-03');
    await created.captureDailyLogEntry(
      logId: daily.logId,
      type: JournalEntryType.task,
      content: 'Keep original task',
    );
    final DailyLogSnapshot captured = await created.loadDailyLog('2026-09-03');
    final String entryId = captured.entries.single.id;
    final String collectionId = await created.createCollection(title: 'Project');

    await created.referenceEntryInCollection(
      entryId: entryId,
      collectionId: collectionId,
    );

    final DailyLogSnapshot sourceAfter = await created.loadDailyLog('2026-09-03');
    final CollectionSnapshot collectionAfter = await created.loadCollection(
      collectionId,
    );
    expect(sourceAfter.entries.single.id, entryId);
    expect(sourceAfter.entries.single.taskState, JournalTaskState.open);
    expect(collectionAfter.entries, isEmpty);
    expect(collectionAfter.references.single.id, entryId);
    expect(collectionAfter.references.single.taskState, JournalTaskState.open);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'collection reference journal',
    );
    final DailyLogSnapshot persistedSource = await reopened.loadDailyLog(
      '2026-09-03',
    );
    final CollectionSnapshot persistedCollection = await reopened.loadCollection(
      collectionId,
    );
    expect(persistedSource.entries.single.id, entryId);
    expect(persistedSource.entries.single.taskState, JournalTaskState.open);
    expect(persistedCollection.entries, isEmpty);
    expect(persistedCollection.references.single.id, entryId);
  });
}
''',
)

write(
    "test/journal/entry_collection_reference_screen_test.dart",
    r'''import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/entry_collection_reference_dialog.dart';
import 'package:daymark/features/journal/presentation/future_screen.dart';
import 'package:daymark/features/journal/presentation/monthly_screen.dart';
import 'package:daymark/features/journal/presentation/today_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Today Note can be referenced without changing its source', (
    tester,
  ) async {
    final _ReferenceDataSource references = _ReferenceDataSource();
    final _TodayJournal today = _TodayJournal();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todayJournalDataSourceProvider.overrideWithValue(today),
          entryCollectionReferenceDataSourceProvider.overrideWithValue(
            references,
          ),
        ],
        child: _app(const TodayScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('–'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reference'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(references.entryId, 'today-note');
    expect(references.collectionId, 'project');
    expect(today.entry.type, JournalEntryType.note);
    expect(today.entry.taskState, isNull);
    expect(find.text('–'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Monthly Calendar Event can be referenced without moving it', (
    tester,
  ) async {
    final _ReferenceDataSource references = _ReferenceDataSource();
    final _MonthlyJournal monthly = _MonthlyJournal();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          monthlyJournalDataSourceProvider.overrideWithValue(monthly),
          entryCollectionReferenceDataSourceProvider.overrideWithValue(
            references,
          ),
        ],
        child: _app(MonthlyScreen(initialMonth: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('○ Monthly event'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reference'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(references.entryId, 'monthly-event');
    expect(monthly.entry.calendarDate, '2026-09-03');
    expect(monthly.entry.taskState, isNull);
    expect(find.text('○ Monthly event'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Future Event can be referenced without changing Future ownership', (
    tester,
  ) async {
    final _ReferenceDataSource references = _ReferenceDataSource();
    final _FutureJournal future = _FutureJournal();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          futureJournalDataSourceProvider.overrideWithValue(future),
          entryCollectionReferenceDataSourceProvider.overrideWithValue(
            references,
          ),
        ],
        child: _app(FutureScreen(initialDate: DateTime(2026, 9, 3))),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('○'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reference'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Project'));
    await tester.pumpAndSettle();

    expect(references.entryId, 'future-event');
    expect(future.entry.type, JournalEntryType.event);
    expect(future.entry.taskState, isNull);
    expect(find.text('Future event'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });
}

MaterialApp _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

final class _ReferenceDataSource implements EntryCollectionReferenceDataSource {
  String? entryId;
  String? collectionId;

  @override
  Future<List<CollectionSummary>> listCollections() async => const [
    CollectionSummary(id: 'project', title: 'Project'),
  ];

  @override
  Future<void> referenceEntry({
    required String entryId,
    required String collectionId,
  }) async {
    this.entryId = entryId;
    this.collectionId = collectionId;
  }
}

final class _TodayJournal implements TodayJournalDataSource {
  final DailyLogEntry entry = const DailyLogEntry(
    id: 'today-note',
    type: JournalEntryType.note,
    taskState: null,
    content: 'Linked observation',
    ordinal: 0,
  );

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
  final MonthlyLogEntry entry = const MonthlyLogEntry(
    id: 'monthly-event',
    type: JournalEntryType.event,
    taskState: null,
    content: 'Monthly event',
    ordinal: 0,
    section: JournalMonthlySection.calendar,
    calendarDate: '2026-09-03',
  );

  @override
  Future<MonthlyLogSnapshot> load(String periodStart) async => MonthlyLogSnapshot(
    logId: 'monthly',
    periodStart: periodStart,
    calendarEntries: [entry],
    taskEntries: const [],
  );

  @override
  Future<void> captureCalendarEvent({
    required String logId,
    required String calendarDate,
    required String content,
  }) async {}

  @override
  Future<void> captureTask({
    required String logId,
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

final class _FutureJournal implements FutureJournalDataSource {
  final FutureLogEntry entry = const FutureLogEntry(
    id: 'future-event',
    type: JournalEntryType.event,
    taskState: null,
    content: 'Future event',
    ordinal: 0,
  );

  @override
  Future<FutureLogSnapshot> load(String periodStart) async => FutureLogSnapshot(
    logId: 'future-$periodStart',
    periodStart: periodStart,
    entries: periodStart == '2026-10-01' ? [entry] : const [],
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
  Future<void> discardTask({required String entryId}) async {}
}
''',
)

# Collection UI explicitly presents references separately and read-only.
replace_once(
    "test/journal/collections_screen_test.dart",
    "  testWidgets('Collection open Task can complete or discard', (tester) async {\n",
    r'''  testWidgets('Collection shows references separately as read-only', (
    tester,
  ) async {
    final _MemoryCollectionsJournal dataSource = _MemoryCollectionsJournal(
      seedReferences: <CollectionReferenceEntry>[
        const CollectionReferenceEntry(
          id: 'daily-note',
          type: JournalEntryType.note,
          taskState: null,
          content: 'Linked note',
          ordinal: 0,
        ),
      ],
    );
    await _pumpCollections(tester, dataSource);
    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pump();

    expect(find.text('References'), findsOneWidget);
    expect(find.text('Linked note'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);
    await tester.tap(find.text('–'));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<Object>), findsNothing);
  });

  testWidgets('Collection open Task can complete or discard', (tester) async {
''',
)
replace_once(
    "test/journal/collections_screen_test.dart",
    '''final class _MemoryCollectionsJournal implements CollectionsJournalDataSource {
  _MemoryCollectionsJournal({List<CollectionEntry>? seedEntries}) {
    if (seedEntries != null) {
      _collections.add(const CollectionSummary(id: 'work', title: 'Work'));
      _entries['work'] = List<CollectionEntry>.from(seedEntries);
    }
  }

  final List<CollectionSummary> _collections = <CollectionSummary>[];
  final Map<String, List<CollectionEntry>> _entries =
      <String, List<CollectionEntry>>{};
''',
    '''final class _MemoryCollectionsJournal implements CollectionsJournalDataSource {
  _MemoryCollectionsJournal({
    List<CollectionEntry>? seedEntries,
    List<CollectionReferenceEntry>? seedReferences,
  }) {
    if (seedEntries != null || seedReferences != null) {
      _collections.add(const CollectionSummary(id: 'work', title: 'Work'));
      _entries['work'] = List<CollectionEntry>.from(seedEntries ?? const []);
      _references['work'] = List<CollectionReferenceEntry>.from(
        seedReferences ?? const [],
      );
    }
  }

  final List<CollectionSummary> _collections = <CollectionSummary>[];
  final Map<String, List<CollectionEntry>> _entries =
      <String, List<CollectionEntry>>{};
  final Map<String, List<CollectionReferenceEntry>> _references =
      <String, List<CollectionReferenceEntry>>{};
''',
)
replace_once(
    "test/journal/collections_screen_test.dart",
    "    _entries[id] = <CollectionEntry>[];\n    return id;\n",
    "    _entries[id] = <CollectionEntry>[];\n    _references[id] = <CollectionReferenceEntry>[];\n    return id;\n",
)
replace_once(
    "test/journal/collections_screen_test.dart",
    '''    return CollectionSnapshot(
      id: collection.id,
      title: collection.title,
      entries: _entries[collectionId]!,
    );
''',
    '''    return CollectionSnapshot(
      id: collection.id,
      title: collection.title,
      entries: _entries[collectionId]!,
      references: _references[collectionId] ?? const [],
    );
''',
)

# Retained-tab regression specifically for externally added references.
replace_once(
    "test/journal/collections_activation_test.dart",
    "  });\n}\n\nfinal class _CollectionsDataSource implements CollectionsJournalDataSource {\n",
    r'''  });

  testWidgets('Collections refreshes references when reactivated', (
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
    expect(find.text('Linked elsewhere'), findsNothing);

    currentSection.value = 0;
    await tester.pump();
    dataSource.addReference();
    expect(find.text('Linked elsewhere'), findsNothing);

    currentSection.value = AppSectionScope.collectionsSectionIndex;
    await tester.pump();
    await tester.pump();
    expect(find.text('References'), findsOneWidget);
    expect(find.text('Linked elsewhere'), findsOneWidget);
  });
}

final class _CollectionsDataSource implements CollectionsJournalDataSource {
''',
)
replace_once(
    "test/journal/collections_activation_test.dart",
    "  final List<CollectionEntry> entries = [\n",
    "  final List<CollectionReferenceEntry> references = [];\n\n  final List<CollectionEntry> entries = [\n",
)
replace_once(
    "test/journal/collections_activation_test.dart",
    "  @override\n  Future<List<CollectionSummary>> list() async => const [\n",
    r'''  void addReference() {
    references.add(
      const CollectionReferenceEntry(
        id: 'linked',
        type: JournalEntryType.note,
        taskState: null,
        content: 'Linked elsewhere',
        ordinal: 0,
      ),
    );
  }

  @override
  Future<List<CollectionSummary>> list() async => const [
''',
)
replace_once(
    "test/journal/collections_activation_test.dart",
    '''  Future<CollectionSnapshot> load(String collectionId) async =>
      CollectionSnapshot(id: 'project', title: 'Project', entries: entries);
''',
    '''  Future<CollectionSnapshot> load(String collectionId) async =>
      CollectionSnapshot(
        id: 'project',
        title: 'Project',
        entries: entries,
        references: references,
      );
''',
)

print('PR #22 patch applied')
