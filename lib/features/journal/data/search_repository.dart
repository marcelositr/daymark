import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';

enum SearchOwnerKind { log, collection }

final class JournalSearchResult {
  const JournalSearchResult({
    required this.entryId,
    required this.type,
    required this.taskState,
    required this.content,
    required this.ownerKind,
    required this.ownerId,
    required this.updatedAtUtcMicros,
    this.logKind,
    this.periodStart,
    this.collectionTitle,
    this.monthlySection,
    this.monthlyCalendarDate,
  });

  final String entryId;
  final JournalEntryType type;
  final JournalTaskState? taskState;
  final String content;
  final SearchOwnerKind ownerKind;
  final String ownerId;
  final int updatedAtUtcMicros;
  final JournalLogKind? logKind;
  final String? periodStart;
  final String? collectionTitle;
  final JournalMonthlySection? monthlySection;
  final String? monthlyCalendarDate;
}

/// Read-only local search over existing journal Entries.
///
/// Search never creates an Index item, duplicates Entry content, or changes
/// ownership/state. Results describe the Entry's real owning placement so the
/// presentation can show method-native context.
final class JournalSearchRepository {
  const JournalSearchRepository(this._database);

  final DaymarkDatabase _database;

  Future<List<JournalSearchResult>> search(
    String rawQuery, {
    int limit = 100,
  }) async {
    final String query = rawQuery.trim();
    if (query.isEmpty) {
      return const <JournalSearchResult>[];
    }
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }

    final rows = await _database.customSelect(
      '''
      SELECT
        e.id,
        e.entry_type,
        e.task_state,
        e.content,
        e.updated_at,
        p.log_id,
        p.collection_id,
        p.monthly_section,
        p.monthly_calendar_date,
        l.kind AS log_kind,
        l.period_start,
        c.title AS collection_title
      FROM entries AS e
      INNER JOIN entry_placements AS p ON p.entry_id = e.id
      LEFT JOIN logs AS l ON l.id = p.log_id
      LEFT JOIN collections AS c ON c.id = p.collection_id
      WHERE instr(lower(e.content), lower(?)) > 0
      ORDER BY e.updated_at DESC, e.id
      LIMIT ?
      ''',
      variables: <Variable<Object>>[
        Variable.withString(query),
        Variable.withInt(limit),
      ],
    ).get();

    return rows.map((row) {
      final String? logId = row.readNullable<String>('log_id');
      final String? collectionId = row.readNullable<String>('collection_id');
      if ((logId == null) == (collectionId == null)) {
        throw const JournalInvariantException(
          'Search result Entry must have exactly one owner.',
        );
      }

      return JournalSearchResult(
        entryId: row.read<String>('id'),
        type: _entryTypeFromCode(row.read<String>('entry_type')),
        taskState: _taskStateFromCode(
          row.readNullable<String>('task_state'),
        ),
        content: row.read<String>('content'),
        ownerKind: logId != null
            ? SearchOwnerKind.log
            : SearchOwnerKind.collection,
        ownerId: logId ?? collectionId!,
        updatedAtUtcMicros: row.read<int>('updated_at'),
        logKind: logId == null
            ? null
            : _logKindFromCode(row.read<String>('log_kind')),
        periodStart: row.readNullable<String>('period_start'),
        collectionTitle: row.readNullable<String>('collection_title'),
        monthlySection: _monthlySectionFromCode(
          row.readNullable<String>('monthly_section'),
        ),
        monthlyCalendarDate: row.readNullable<String>(
          'monthly_calendar_date',
        ),
      );
    }).toList(growable: false);
  }
}

JournalEntryType _entryTypeFromCode(String value) => switch (value) {
  'task' => JournalEntryType.task,
  'event' => JournalEntryType.event,
  'note' => JournalEntryType.note,
  _ => throw JournalInvariantException('Unknown entry type: $value.'),
};

JournalTaskState? _taskStateFromCode(String? value) => switch (value) {
  null => null,
  'open' => JournalTaskState.open,
  'completed' => JournalTaskState.completed,
  'migrated' => JournalTaskState.migrated,
  'scheduled' => JournalTaskState.scheduled,
  'discarded' => JournalTaskState.discarded,
  _ => throw JournalInvariantException('Unknown task state: $value.'),
};

JournalLogKind _logKindFromCode(String value) => switch (value) {
  'daily' => JournalLogKind.daily,
  'monthly' => JournalLogKind.monthly,
  'future' => JournalLogKind.future,
  _ => throw JournalInvariantException('Unknown log kind: $value.'),
};

JournalMonthlySection? _monthlySectionFromCode(String? value) => switch (value) {
  null => null,
  'calendar' => JournalMonthlySection.calendar,
  'tasks' => JournalMonthlySection.tasks,
  _ => throw JournalInvariantException('Unknown Monthly section: $value.'),
};
