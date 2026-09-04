import 'dart:async';
import 'dart:io';

import 'package:daymark/core/backup/encrypted_backup_service.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/crypto/security_exception.dart';
import 'package:daymark/core/session/journal_files.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late JournalFiles files;
  late JournalSessionManager manager;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('daymark-session-test-');
    files = JournalFiles(directory);
    final KeyEnvelopeService keyEnvelopeService = KeyEnvelopeService(
      parameters: Argon2Parameters.test,
    );
    manager = JournalSessionManager(
      files: files,
      keyEnvelopeService: keyEnvelopeService,
      backupService: EncryptedBackupService(
        keyEnvelopeService: keyEnvelopeService,
      ),
    );
  });

  tearDown(() async {
    await manager.dispose();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  test(
    'create, lock, and unlock own the encrypted session lifecycle',
    () async {
      expect(await manager.inspect(), isA<JournalNeedsCreation>());

      final JournalSession created = await manager.create(
        masterPassword: 'correct horse battery staple',
      );

      expect(created.isClosed, isFalse);
      expect(await files.databaseFile.exists(), isTrue);
      expect(await files.keyEnvelopeFile.exists(), isTrue);
      expect(await files.creatingKeyEnvelopeFile.exists(), isFalse);
      expect(await manager.inspect(), isA<JournalUnlocked>());

      await manager.lock();
      expect(created.isClosed, isTrue);
      expect(await manager.inspect(), isA<JournalLocked>());

      final JournalSession reopened = await manager.unlock(
        masterPassword: 'correct horse battery staple',
      );
      expect(reopened.isClosed, isFalse);
      expect(await manager.inspect(), isA<JournalUnlocked>());
    },
  );

  test('Daily Log entries persist across lock and unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'persistent journal password',
    );
    final DailyLogSnapshot initial = await created.loadDailyLog('2026-09-02');

    await created.captureDailyLogEntry(
      logId: initial.logId,
      type: JournalEntryType.task,
      content: 'Persist this task',
    );
    await created.captureDailyLogEntry(
      logId: initial.logId,
      type: JournalEntryType.note,
      content: 'Persist this note',
    );

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'persistent journal password',
    );
    final DailyLogSnapshot loaded = await reopened.loadDailyLog('2026-09-02');

    expect(loaded.entries.map((entry) => entry.content), <String>[
      'Persist this task',
      'Persist this note',
    ]);
    expect(loaded.entries.first.taskState, JournalTaskState.open);
    expect(loaded.entries.last.taskState, isNull);
  });

  test('Monthly Log entries persist across lock and unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'persistent monthly journal',
    );
    final MonthlyLogSnapshot initial = await created.loadMonthlyLog(
      '2026-09-01',
    );

    await created.captureMonthlyCalendarEvent(
      logId: initial.logId,
      calendarDate: '2026-09-15',
      content: 'Dentist',
    );
    await created.captureMonthlyTask(
      logId: initial.logId,
      content: 'Renew documents',
    );

    final MonthlyLogSnapshot captured = await created.loadMonthlyLog(
      '2026-09-01',
    );
    await created.completeTask(entryId: captured.taskEntries.single.id);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'persistent monthly journal',
    );
    final MonthlyLogSnapshot loaded = await reopened.loadMonthlyLog(
      '2026-09-01',
    );

    expect(loaded.calendarEntries.single.content, 'Dentist');
    expect(loaded.calendarEntries.single.calendarDate, '2026-09-15');
    expect(loaded.taskEntries.single.content, 'Renew documents');
    expect(loaded.taskEntries.single.taskState, JournalTaskState.completed);
  });

  test('Task terminal states persist across lock and unlock', () async {
    final JournalSession created = await manager.create(
      masterPassword: 'persistent task states',
    );
    final DailyLogSnapshot initial = await created.loadDailyLog('2026-09-02');

    await created.captureDailyLogEntry(
      logId: initial.logId,
      type: JournalEntryType.task,
      content: 'Complete me',
    );
    await created.captureDailyLogEntry(
      logId: initial.logId,
      type: JournalEntryType.task,
      content: 'Discard me',
    );

    final DailyLogSnapshot captured = await created.loadDailyLog('2026-09-02');
    await created.completeTask(entryId: captured.entries[0].id);
    await created.discardTask(entryId: captured.entries[1].id);

    await manager.lock();
    final JournalSession reopened = await manager.unlock(
      masterPassword: 'persistent task states',
    );
    final DailyLogSnapshot loaded = await reopened.loadDailyLog('2026-09-02');

    expect(loaded.entries[0].taskState, JournalTaskState.completed);
    expect(loaded.entries[1].taskState, JournalTaskState.discarded);
  });

  test('empty master passwords are rejected before journal creation', () async {
    expect(manager.create(masterPassword: ''), throwsA(isA<ArgumentError>()));
    expect(await manager.inspect(), isA<JournalNeedsCreation>());
  });

  test('wrong password fails closed and leaves the journal locked', () async {
    await manager.create(masterPassword: 'right password');
    await manager.lock();

    expect(
      manager.unlock(masterPassword: 'wrong password'),
      throwsA(isA<JournalUnlockException>()),
    );

    expect(await manager.inspect(), isA<JournalLocked>());

    final JournalSession reopened = await manager.unlock(
      masterPassword: 'right password',
    );
    expect(reopened.isClosed, isFalse);
  });

  test('empty password cannot attempt an existing journal unlock', () async {
    await manager.create(masterPassword: 'right password');
    await manager.lock();

    expect(manager.unlock(masterPassword: ''), throwsA(isA<ArgumentError>()));
    expect(await manager.inspect(), isA<JournalLocked>());
  });

  test('lock waits for an in-flight journal operation before close', () async {
    final JournalSession session = await manager.create(
      masterPassword: 'serialized operations',
    );
    final Completer<void> operationStarted = Completer<void>();
    final Completer<void> allowOperationToFinish = Completer<void>();

    final Future<void> operation = session.run(() async {
      operationStarted.complete();
      await allowOperationToFinish.future;
    });
    await operationStarted.future;

    final Future<void> lock = manager.lock();
    await Future<void>.delayed(Duration.zero);
    expect(session.isClosed, isFalse);

    allowOperationToFinish.complete();
    await operation;
    await lock;

    expect(session.isClosed, isTrue);
    expect(await manager.inspect(), isA<JournalLocked>());
  });

  test('unlocked journal can create a portable encrypted backup', () async {
    const String password = 'backup lifecycle password';
    final JournalSession session = await manager.create(
      masterPassword: password,
    );
    final DailyLogSnapshot daily = await session.loadDailyLog('2026-09-04');
    await session.captureDailyLogEntry(
      logId: daily.logId,
      type: JournalEntryType.note,
      content: 'Before the backup',
    );

    final File backupFile = File(
      '${directory.path}${Platform.pathSeparator}journal.daymark-backup',
    );
    await manager.createBackup(
      backupFile: backupFile,
      masterPassword: password,
    );

    expect(await backupFile.exists(), isTrue);
    expect(await backupFile.length(), greaterThan(0));
    expect(await manager.inspect(), isA<JournalUnlocked>());
  });

  test('backup rejects a password that does not match the live journal', () async {
    await manager.create(masterPassword: 'right backup password');
    final File backupFile = File(
      '${directory.path}${Platform.pathSeparator}wrong-password.daymark-backup',
    );

    await expectLater(
      manager.createBackup(
        backupFile: backupFile,
        masterPassword: 'wrong backup password',
      ),
      throwsA(isA<BackupAuthenticationException>()),
    );
    expect(await backupFile.exists(), isFalse);
    expect(await manager.inspect(), isA<JournalUnlocked>());
  });

  test(
    'locked restore replaces the journal only with the backup snapshot',
    () async {
      const String password = 'restore lifecycle password';
      final JournalSession session = await manager.create(
        masterPassword: password,
      );
      final DailyLogSnapshot daily = await session.loadDailyLog('2026-09-04');
      await session.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.note,
        content: 'Included in backup',
      );

      final File backupFile = File(
        '${directory.path}${Platform.pathSeparator}restore.daymark-backup',
      );
      await manager.createBackup(
        backupFile: backupFile,
        masterPassword: password,
      );

      await session.captureDailyLogEntry(
        logId: daily.logId,
        type: JournalEntryType.note,
        content: 'Created after backup',
      );
      await manager.lock();

      final JournalSession restored = await manager.restoreBackup(
        backupFile: backupFile,
        masterPassword: password,
      );
      final DailyLogSnapshot restoredDaily = await restored.loadDailyLog(
        '2026-09-04',
      );

      expect(restoredDaily.entries.map((entry) => entry.content), <String>[
        'Included in backup',
      ]);
      expect(await manager.inspect(), isA<JournalUnlocked>());
    },
  );

  test(
    'restore is rejected while the destination journal is unlocked',
    () async {
      const String password = 'unlocked restore password';
      await manager.create(masterPassword: password);
      final File backupFile = File(
        '${directory.path}${Platform.pathSeparator}unlocked.daymark-backup',
      );
      await manager.createBackup(
        backupFile: backupFile,
        masterPassword: password,
      );

      await expectLater(
        manager.restoreBackup(backupFile: backupFile, masterPassword: password),
        throwsA(isA<StateError>()),
      );
      expect(await manager.inspect(), isA<JournalUnlocked>());
    },
  );

  test(
    'inspect cleans committed restore rollback residue before unlock',
    () async {
      await manager.create(masterPassword: 'recovery inspection password');
      await manager.lock();

      final File rollbackDatabase = File(
        '${files.databaseFile.path}.restore-rollback',
      );
      final File rollbackEnvelope = File(
        '${files.keyEnvelopeFile.path}.restore-rollback',
      );
      await rollbackDatabase.writeAsBytes(const <int>[1], flush: true);
      await rollbackEnvelope.writeAsString('{"stale":true}', flush: true);

      expect(await manager.inspect(), isA<JournalLocked>());
      expect(await rollbackDatabase.exists(), isFalse);
      expect(await rollbackEnvelope.exists(), isFalse);
    },
  );

  test('incomplete journal file sets are never treated as creatable', () async {
    await files.ensureDirectory();
    await files.databaseFile.writeAsBytes(const <int>[1, 2, 3], flush: true);

    expect(await manager.inspect(), isA<JournalStorageProblem>());
    expect(
      manager.create(masterPassword: 'do not overwrite'),
      throwsA(isA<StateError>()),
    );
    expect(await files.databaseFile.readAsBytes(), const <int>[1, 2, 3]);
  });
}
