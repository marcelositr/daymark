import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';

final class DailyLogEntry {
  const DailyLogEntry({
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

final class DailyLogSnapshot {
  DailyLogSnapshot({
    required this.logId,
    required this.methodDate,
    required List<DailyLogEntry> entries,
  }) : entries = List<DailyLogEntry>.unmodifiable(entries);

  final String logId;
  final String methodDate;
  final List<DailyLogEntry> entries;
}

/// Focused read/write boundary for Daily Logs.
///
/// Reads query encrypted storage directly. Historical lookup is deliberately
/// non-creating. Mutations continue through the semantic [JournalService] so
/// ownership and task-state invariants remain in the already-reviewed journal
/// repository layer.
final class DailyLogRepository {
  const DailyLogRepository(this._database, this._journalService);

  final DaymarkDatabase _database;
  final JournalService _journalService;

  Future<DailyLogSnapshot> loadOrCreate(String methodDate) async {
    validateJournalMethodDate(methodDate);

    String? logId = await _findDailyLogId(methodDate);
    if (logId == null) {
      try {
        logId = await _journalService.createLog(
          kind: JournalLogKind.daily,
          periodStart: methodDate,
        );
      } on JournalInvariantException {
        // A concurrent request may have created the same Daily Log between the
        // read above and the transaction. Re-read once and preserve any other
        // invariant failure.
        logId = await _findDailyLogId(methodDate);
        if (logId == null) {
          rethrow;
        }
      }
    }

    return _loadSnapshot(logId: logId, methodDate: methodDate);
  }

  Future<DailyLogSnapshot?> find(String methodDate) async {
    validateJournalMethodDate(methodDate);

    final String? logId = await _findDailyLogId(methodDate);
    if (logId == null) {
      return null;
    }
    return _loadSnapshot(logId: logId, methodDate: methodDate);
  }

  Future<void> capture({
    required String logId,
    required JournalEntryType type,
    required String content,
  }) async {
    await _journalService.capture(
      type: type,
      content: content,
      owner: JournalLogOwner(logId: logId),
    );
  }

  Future<DailyLogSnapshot> _loadSnapshot({
    required String logId,
    required String methodDate,
  }) async {
    return DailyLogSnapshot(
      logId: logId,
      methodDate: methodDate,
      entries: await _loadEntries(logId),
    );
  }

  Future<String?> _findDailyLogId(String methodDate) async {
    final row = await _database
        .customSelect(
          '''
          SELECT id
          FROM logs
          WHERE kind = 'daily' AND period_start = ?
          ''',
          variables: <Variable<Object>>[Variable.withString(methodDate)],
        )
        .getSingleOrNull();
    return row?.read<String>('id');
  }

  Future<List<DailyLogEntry>> _loadEntries(String logId) async {
    final rows = await _database
        .customSelect(
          '''
          SELECT e.id, e.entry_type, e.task_state, e.content, p.ordinal
          FROM entry_placements p
          JOIN entries e ON e.id = p.entry_id
          WHERE p.log_id = ?
          ORDER BY p.ordinal
          ''',
          variables: <Variable<Object>>[Variable.withString(logId)],
        )
        .get();

    return <DailyLogEntry>[
      for (final row in rows)
        DailyLogEntry(
          id: row.read<String>('id'),
          type: _entryTypeFromCode(row.read<String>('entry_type')),
          taskState: _taskStateFromCode(row.readNullable<String>('task_state')),
          content: row.read<String>('content'),
          ordinal: row.read<int>('ordinal'),
        ),
    ];
  }
}

String formatJournalMethodDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

void validateJournalMethodDate(String value) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw JournalInvariantException('Invalid method date: $value.');
  }
  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null || formatJournalMethodDate(parsed) != value) {
    throw JournalInvariantException('Invalid method date: $value.');
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
