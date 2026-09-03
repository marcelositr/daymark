import 'dart:io';

import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'daymark-task-movement-session-test-',
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

  test(
    'Today and Monthly Task scheduling preserves lineage across unlock',
    () async {
      final JournalSession created = await manager.create(
        masterPassword: 'persistent task scheduling journal',
      );

      final DailyLogSnapshot daily = await created.loadDailyLog('2026-09-03');
      await created.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.task,
        content: 'Plan November renewal',
      );
      final String dailySourceId = (await created.loadDailyLog('2026-09-03'))
          .entries
          .single
          .id;
      await created.scheduleTaskToFuture(
        entryId: dailySourceId,
        periodStart: '2026-11-01',
      );

      final MonthlyLogSnapshot monthly = await created.loadMonthlyLog(
        '2026-09-01',
      );
      await created.captureMonthlyTask(
        logId: monthly.logId,
        content: 'Book December trip',
      );
      final String monthlySourceId = (await created.loadMonthlyLog(
        '2026-09-01',
      ))
          .taskEntries
          .single
          .id;
      await created.scheduleTaskToFuture(
        entryId: monthlySourceId,
        periodStart: '2026-12-01',
      );

      await manager.lock();
      final JournalSession reopened = await manager.unlock(
        masterPassword: 'persistent task scheduling journal',
      );

      final DailyLogSnapshot reopenedDaily = await reopened.loadDailyLog(
        '2026-09-03',
      );
      expect(reopenedDaily.entries.single.content, 'Plan November renewal');
      expect(
        reopenedDaily.entries.single.taskState,
        JournalTaskState.scheduled,
      );

      final MonthlyLogSnapshot reopenedMonthly = await reopened.loadMonthlyLog(
        '2026-09-01',
      );
      expect(reopenedMonthly.taskEntries.single.content, 'Book December trip');
      expect(
        reopenedMonthly.taskEntries.single.taskState,
        JournalTaskState.scheduled,
      );

      final FutureLogSnapshot november = await reopened.loadFutureLog(
        '2026-11-01',
      );
      final FutureLogSnapshot december = await reopened.loadFutureLog(
        '2026-12-01',
      );
      expect(november.entries, hasLength(1));
      expect(november.entries.single.content, 'Plan November renewal');
      expect(november.entries.single.taskState, JournalTaskState.open);
      expect(december.entries, hasLength(1));
      expect(december.entries.single.content, 'Book December trip');
      expect(december.entries.single.taskState, JournalTaskState.open);

      final dailyLineage = await reopened.database
          .customSelect(
            '''
      SELECT destination_entry_id, kind
      FROM migrations
      WHERE source_entry_id = ?
      ''',
            variables: <Variable<Object>>[Variable.withString(dailySourceId)],
          )
          .getSingle();
      expect(dailyLineage.read<String>('kind'), 'scheduled');
      expect(
        dailyLineage.read<String>('destination_entry_id'),
        november.entries.single.id,
      );

      final monthlyLineage = await reopened.database
          .customSelect(
            '''
      SELECT destination_entry_id, kind
      FROM migrations
      WHERE source_entry_id = ?
      ''',
            variables: <Variable<Object>>[
              Variable.withString(monthlySourceId),
            ],
          )
          .getSingle();
      expect(monthlyLineage.read<String>('kind'), 'scheduled');
      expect(
        monthlyLineage.read<String>('destination_entry_id'),
        december.entries.single.id,
      );
    },
  );

  test(
    'Task scheduling rejects invalid sources before creating a destination',
    () async {
      final JournalSession session = await manager.create(
        masterPassword: 'task scheduling boundary journal',
      );
      final DailyLogSnapshot daily = await session.loadDailyLog('2026-09-03');

      await session.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.event,
        content: 'Not a Task',
      );
      await session.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.task,
        content: 'Already done',
      );

      final DailyLogSnapshot captured = await session.loadDailyLog(
        '2026-09-03',
      );
      final String eventId = captured.entries
          .singleWhere((entry) => entry.content == 'Not a Task')
          .id;
      final String completedTaskId = captured.entries
          .singleWhere((entry) => entry.content == 'Already done')
          .id;
      await session.completeTask(entryId: completedTaskId);

      expect(
        () => session.scheduleTaskToFuture(
          entryId: eventId,
          periodStart: '2026-11-01',
        ),
        throwsA(isA<JournalInvariantException>()),
      );
      expect(
        () => session.scheduleTaskToFuture(
          entryId: completedTaskId,
          periodStart: '2026-12-01',
        ),
        throwsA(isA<JournalInvariantException>()),
      );

      final futureCount = await session.database
          .customSelect(
            "SELECT COUNT(*) AS count FROM logs WHERE kind = 'future'",
          )
          .getSingle();
      expect(futureCount.read<int>('count'), 0);
    },
  );
}
