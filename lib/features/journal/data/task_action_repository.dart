import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';

/// Focused persistence boundary for terminal task-state transitions.
///
/// Migration and scheduling remain in `JournalRepository` because they create a
/// destination Entry and lineage edge. Completion and discard are single-entry
/// state transitions, but still validate the persisted entry before mutation.
final class TaskActionRepository {
  TaskActionRepository(
    this._database, {
    int Function()? nowUtcMicros,
  }) : _nowUtcMicros = nowUtcMicros ?? _defaultNowUtcMicros;

  final DaymarkDatabase _database;
  final int Function() _nowUtcMicros;

  Future<void> complete(String entryId) {
    return _transitionOpenTask(entryId, JournalTaskState.completed);
  }

  Future<void> discard(String entryId) {
    return _transitionOpenTask(entryId, JournalTaskState.discarded);
  }

  Future<void> _transitionOpenTask(
    String entryId,
    JournalTaskState destinationState,
  ) {
    assert(
      destinationState == JournalTaskState.completed ||
          destinationState == JournalTaskState.discarded,
    );

    return _database.transaction(() async {
      final row = await _database
          .customSelect(
            '''
            SELECT entry_type, task_state
            FROM entries
            WHERE id = ?
            ''',
            variables: <Variable<Object>>[Variable.withString(entryId)],
          )
          .getSingleOrNull();

      if (row == null) {
        throw JournalNotFoundException('Entry', entryId);
      }

      final String entryType = row.read<String>('entry_type');
      final String? taskState = row.readNullable<String>('task_state');
      if (entryType != JournalEntryType.task.code) {
        throw const JournalInvariantException(
          'Only Tasks can be completed or discarded.',
        );
      }
      if (taskState != JournalTaskState.open.code) {
        throw const JournalInvariantException(
          'Only an open Task can be completed or discarded.',
        );
      }

      await _database.customStatement(
        '''
        UPDATE entries
        SET task_state = ?, updated_at = ?
        WHERE id = ?
        ''',
        <Object>[destinationState.code, _now(), entryId],
      );
    });
  }

  int _now() {
    final int value = _nowUtcMicros();
    if (value < 0) {
      throw StateError('UTC microsecond clock returned a negative instant.');
    }
    return value;
  }
}

int _defaultNowUtcMicros() => DateTime.now().toUtc().microsecondsSinceEpoch;
