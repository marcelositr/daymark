import 'dart:convert';
import 'dart:io';

import 'package:daymark/core/backup/encrypted_backup_service.dart';
import 'package:daymark/core/crypto/journal_key_material.dart';
import 'package:daymark/core/crypto/key_envelope.dart';
import 'package:daymark/core/crypto/security_exception.dart';
import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/core/database/encrypted_daymark_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String masterPassword = 'correct horse battery staple';
  const String sourceEntryId = '00000000-0000-7000-8000-000000000801';
  const String targetEntryId = '00000000-0000-7000-8000-000000000802';
  const String sensitiveText = 'BACKUP-SECRET-journal-content-4815';
  const String existingText = 'EXISTING-JOURNAL-MUST-SURVIVE';

  late Directory tempDirectory;
  late KeyEnvelopeService keyEnvelopeService;
  late EncryptedBackupService backupService;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync('daymark-backup-test-');
    keyEnvelopeService = KeyEnvelopeService(parameters: Argon2Parameters.test);
    backupService = EncryptedBackupService(
      keyEnvelopeService: keyEnvelopeService,
    );
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('portable backup restores after the source in-memory key is gone', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File backupFile = File('${tempDirectory.path}/source.daymark-backup');
    final File restoredDatabase = File(
      '${tempDirectory.path}/restored.daymark',
    );
    final File restoredEnvelope = File(
      '${tempDirectory.path}/restored.key-envelope.json',
    );

    try {
      await backupService.createBackup(
        journalFile: source.databaseFile,
        backupFile: backupFile,
        keyMaterial: source.keyMaterial,
        encodedKeyEnvelope: source.encodedEnvelope,
        masterPassword: masterPassword,
      );

      expect(backupFile.existsSync(), isTrue);
      expect(_fileContainsUtf8(backupFile, sensitiveText), isFalse);
      expect(_fileStartsWithSqliteHeader(backupFile), isFalse);

      source.keyMaterial.destroy();

      await backupService.restoreBackup(
        backupFile: backupFile,
        destinationJournalFile: restoredDatabase,
        destinationKeyEnvelopeFile: restoredEnvelope,
        masterPassword: masterPassword,
      );

      expect(await restoredEnvelope.readAsString(), source.encodedEnvelope);

      final JournalKeyMaterial restoredKey = await keyEnvelopeService.unwrap(
        masterPassword: masterPassword,
        encodedEnvelope: await restoredEnvelope.readAsString(),
      );
      try {
        expect(
          await _readEntry(
            databaseFile: restoredDatabase,
            keyMaterial: restoredKey,
            entryId: sourceEntryId,
          ),
          sensitiveText,
        );
      } finally {
        restoredKey.destroy();
      }
    } finally {
      source.keyMaterial.destroy();
    }
  });

  test('wrong backup password leaves an existing journal untouched', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final _JournalFixture target = await _createJournal(
      directory: tempDirectory,
      name: 'target',
      entryId: targetEntryId,
      content: existingText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File backupFile = File('${tempDirectory.path}/source.daymark-backup');

    try {
      await backupService.createBackup(
        journalFile: source.databaseFile,
        backupFile: backupFile,
        keyMaterial: source.keyMaterial,
        encodedKeyEnvelope: source.encodedEnvelope,
        masterPassword: masterPassword,
      );

      await expectLater(
        backupService.restoreBackup(
          backupFile: backupFile,
          destinationJournalFile: target.databaseFile,
          destinationKeyEnvelopeFile: target.envelopeFile,
          masterPassword: 'wrong password',
        ),
        throwsA(isA<BackupAuthenticationException>()),
      );

      expect(await target.envelopeFile.readAsString(), target.encodedEnvelope);
      expect(
        await _readEntry(
          databaseFile: target.databaseFile,
          keyMaterial: target.keyMaterial,
          entryId: targetEntryId,
        ),
        existingText,
      );
    } finally {
      source.keyMaterial.destroy();
      target.keyMaterial.destroy();
    }
  });

  test('tampered backup fails authentication before replacing a journal', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final _JournalFixture target = await _createJournal(
      directory: tempDirectory,
      name: 'target',
      entryId: targetEntryId,
      content: existingText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File backupFile = File('${tempDirectory.path}/source.daymark-backup');

    try {
      await backupService.createBackup(
        journalFile: source.databaseFile,
        backupFile: backupFile,
        keyMaterial: source.keyMaterial,
        encodedKeyEnvelope: source.encodedEnvelope,
        masterPassword: masterPassword,
      );

      final List<int> bytes = backupFile.readAsBytesSync();
      final int tamperOffset =
          bytes.length - EncryptedBackupService.macLength - 64;
      expect(tamperOffset, greaterThan(36));
      bytes[tamperOffset] ^= 0x01;
      backupFile.writeAsBytesSync(bytes, flush: true);

      await expectLater(
        backupService.restoreBackup(
          backupFile: backupFile,
          destinationJournalFile: target.databaseFile,
          destinationKeyEnvelopeFile: target.envelopeFile,
          masterPassword: masterPassword,
        ),
        throwsA(isA<BackupAuthenticationException>()),
      );

      expect(await target.envelopeFile.readAsString(), target.encodedEnvelope);
      expect(
        await _readEntry(
          databaseFile: target.databaseFile,
          keyMaterial: target.keyMaterial,
          entryId: targetEntryId,
        ),
        existingText,
      );
    } finally {
      source.keyMaterial.destroy();
      target.keyMaterial.destroy();
    }
  });

  test('truncated backup fails before restore staging', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File backupFile = File('${tempDirectory.path}/source.daymark-backup');
    final File destinationDatabase = File(
      '${tempDirectory.path}/destination.daymark',
    );
    final File destinationEnvelope = File(
      '${tempDirectory.path}/destination.key-envelope.json',
    );

    try {
      await backupService.createBackup(
        journalFile: source.databaseFile,
        backupFile: backupFile,
        keyMaterial: source.keyMaterial,
        encodedKeyEnvelope: source.encodedEnvelope,
        masterPassword: masterPassword,
      );

      final List<int> bytes = backupFile.readAsBytesSync();
      backupFile.writeAsBytesSync(bytes.sublist(0, bytes.length - 1));

      await expectLater(
        backupService.restoreBackup(
          backupFile: backupFile,
          destinationJournalFile: destinationDatabase,
          destinationKeyEnvelopeFile: destinationEnvelope,
          masterPassword: masterPassword,
        ),
        throwsA(isA<BackupFormatException>()),
      );
      expect(destinationDatabase.existsSync(), isFalse);
      expect(destinationEnvelope.existsSync(), isFalse);
    } finally {
      source.keyMaterial.destroy();
    }
  });

  test('unsupported backup format version is rejected explicitly', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File backupFile = File('${tempDirectory.path}/source.daymark-backup');

    try {
      await backupService.createBackup(
        journalFile: source.databaseFile,
        backupFile: backupFile,
        keyMaterial: source.keyMaterial,
        encodedKeyEnvelope: source.encodedEnvelope,
        masterPassword: masterPassword,
      );

      final List<int> bytes = backupFile.readAsBytesSync();
      bytes[16] = 0;
      bytes[17] = 0;
      bytes[18] = 0;
      bytes[19] = 2;
      backupFile.writeAsBytesSync(bytes, flush: true);

      await expectLater(
        backupService.restoreBackup(
          backupFile: backupFile,
          destinationJournalFile: File('${tempDirectory.path}/new.daymark'),
          destinationKeyEnvelopeFile: File(
            '${tempDirectory.path}/new.key-envelope.json',
          ),
          masterPassword: masterPassword,
        ),
        throwsA(isA<BackupCompatibilityException>()),
      );
    } finally {
      source.keyMaterial.destroy();
    }
  });

  test('backup creation rejects an envelope for a different journal key', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final JournalKeyMaterial unrelatedKey = JournalKeyMaterial.generate();
    final String unrelatedEnvelope = await keyEnvelopeService.wrap(
      masterPassword: masterPassword,
      keyMaterial: unrelatedKey,
    );

    try {
      await expectLater(
        backupService.createBackup(
          journalFile: source.databaseFile,
          backupFile: File('${tempDirectory.path}/invalid.daymark-backup'),
          keyMaterial: source.keyMaterial,
          encodedKeyEnvelope: unrelatedEnvelope,
          masterPassword: masterPassword,
        ),
        throwsA(isA<BackupAuthenticationException>()),
      );
    } finally {
      unrelatedKey.destroy();
      source.keyMaterial.destroy();
    }
  });

  test('in-process interrupted commit restores the previous journal pair', () async {
    final _JournalFixture source = await _createJournal(
      directory: tempDirectory,
      name: 'source',
      entryId: sourceEntryId,
      content: sensitiveText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final _JournalFixture target = await _createJournal(
      directory: tempDirectory,
      name: 'target',
      entryId: targetEntryId,
      content: existingText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File backupFile = File('${tempDirectory.path}/source.daymark-backup');

    try {
      await backupService.createBackup(
        journalFile: source.databaseFile,
        backupFile: backupFile,
        keyMaterial: source.keyMaterial,
        encodedKeyEnvelope: source.encodedEnvelope,
        masterPassword: masterPassword,
      );

      final EncryptedBackupService interruptedService = EncryptedBackupService(
        keyEnvelopeService: keyEnvelopeService,
        restoreCommitHook: (RestoreCommitPhase phase) {
          if (phase == RestoreCommitPhase.afterDatabaseInstalled) {
            throw StateError('simulated restore interruption');
          }
        },
      );

      await expectLater(
        interruptedService.restoreBackup(
          backupFile: backupFile,
          destinationJournalFile: target.databaseFile,
          destinationKeyEnvelopeFile: target.envelopeFile,
          masterPassword: masterPassword,
        ),
        throwsA(isA<BackupRestoreException>()),
      );

      expect(await target.envelopeFile.readAsString(), target.encodedEnvelope);
      expect(
        await _readEntry(
          databaseFile: target.databaseFile,
          keyMaterial: target.keyMaterial,
          entryId: targetEntryId,
        ),
        existingText,
      );
      _expectNoRestoreResidue(target.databaseFile, target.envelopeFile);
    } finally {
      source.keyMaterial.destroy();
      target.keyMaterial.destroy();
    }
  });

  test('startup recovery aborts a process-interrupted restore', () async {
    final _JournalFixture target = await _createJournal(
      directory: tempDirectory,
      name: 'target',
      entryId: targetEntryId,
      content: existingText,
      password: masterPassword,
      keyEnvelopeService: keyEnvelopeService,
    );
    final File rollbackDatabase = File(
      '${target.databaseFile.path}.restore-rollback',
    );
    final File rollbackEnvelope = File(
      '${target.envelopeFile.path}.restore-rollback',
    );
    final File transactionMarker = File(
      '${target.databaseFile.path}.restore-transaction',
    );

    try {
      await target.databaseFile.rename(rollbackDatabase.path);
      await target.envelopeFile.rename(rollbackEnvelope.path);
      await target.databaseFile.writeAsBytes(<int>[1, 2, 3, 4], flush: true);
      await transactionMarker.writeAsString(
        jsonEncode(<String, Object>{
          'format': 'daymark-restore-transaction',
          'version': 1,
          'hadExistingJournal': true,
        }),
        flush: true,
      );

      await backupService.recoverInterruptedRestore(
        destinationJournalFile: target.databaseFile,
        destinationKeyEnvelopeFile: target.envelopeFile,
      );

      expect(await target.envelopeFile.readAsString(), target.encodedEnvelope);
      expect(
        await _readEntry(
          databaseFile: target.databaseFile,
          keyMaterial: target.keyMaterial,
          entryId: targetEntryId,
        ),
        existingText,
      );
      _expectNoRestoreResidue(target.databaseFile, target.envelopeFile);
    } finally {
      target.keyMaterial.destroy();
    }
  });
}

final class _JournalFixture {
  const _JournalFixture({
    required this.databaseFile,
    required this.envelopeFile,
    required this.keyMaterial,
    required this.encodedEnvelope,
  });

  final File databaseFile;
  final File envelopeFile;
  final JournalKeyMaterial keyMaterial;
  final String encodedEnvelope;
}

Future<_JournalFixture> _createJournal({
  required Directory directory,
  required String name,
  required String entryId,
  required String content,
  required String password,
  required KeyEnvelopeService keyEnvelopeService,
}) async {
  final File databaseFile = File('${directory.path}/$name.daymark');
  final File envelopeFile = File('${directory.path}/$name.key-envelope.json');
  final JournalKeyMaterial keyMaterial = JournalKeyMaterial.generate();

  final DaymarkDatabase database = await EncryptedDaymarkDatabase.createNew(
    file: databaseFile,
    keyMaterial: keyMaterial,
  );
  try {
    await database.customStatement(
      '''
      INSERT INTO entries (
        id, entry_type, task_state, content, created_at, updated_at
      ) VALUES (?, 'note', NULL, ?, 1, 1)
      ''',
      <Object>[entryId, content],
    );
  } finally {
    await database.close();
  }

  final String encodedEnvelope = await keyEnvelopeService.wrap(
    masterPassword: password,
    keyMaterial: keyMaterial,
  );
  await envelopeFile.writeAsString(encodedEnvelope, flush: true);

  return _JournalFixture(
    databaseFile: databaseFile,
    envelopeFile: envelopeFile,
    keyMaterial: keyMaterial,
    encodedEnvelope: encodedEnvelope,
  );
}

Future<String> _readEntry({
  required File databaseFile,
  required JournalKeyMaterial keyMaterial,
  required String entryId,
}) async {
  final DaymarkDatabase database = await EncryptedDaymarkDatabase.openExisting(
    file: databaseFile,
    keyMaterial: keyMaterial,
  );
  try {
    final rows = await database.customSelect(
      'SELECT content FROM entries WHERE id = ?',
      variables: <Variable<Object>>[Variable<Object>(entryId)],
    ).get();
    return rows.single.read<String>('content');
  } finally {
    await database.close();
  }
}

void _expectNoRestoreResidue(File databaseFile, File envelopeFile) {
  for (final String suffix in <String>[
    '.restore-staged',
    '.restore-rollback',
    '.restore-transaction',
  ]) {
    expect(File('${databaseFile.path}$suffix').existsSync(), isFalse);
  }
  for (final String suffix in <String>[
    '.restore-staged',
    '.restore-rollback',
  ]) {
    expect(File('${envelopeFile.path}$suffix').existsSync(), isFalse);
  }
}

bool _fileContainsUtf8(File file, String text) {
  final List<int> haystack = file.readAsBytesSync();
  final List<int> needle = utf8.encode(text);

  if (needle.isEmpty || needle.length > haystack.length) {
    return false;
  }

  for (int offset = 0; offset <= haystack.length - needle.length; offset++) {
    bool matches = true;
    for (int index = 0; index < needle.length; index++) {
      if (haystack[offset + index] != needle[index]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      return true;
    }
  }

  return false;
}

bool _fileStartsWithSqliteHeader(File file) {
  const String sqliteHeader = 'SQLite format 3\u0000';
  final List<int> bytes = file.readAsBytesSync();
  final List<int> header = utf8.encode(sqliteHeader);

  if (bytes.length < header.length) {
    return false;
  }

  for (int index = 0; index < header.length; index++) {
    if (bytes[index] != header[index]) {
      return false;
    }
  }
  return true;
}
