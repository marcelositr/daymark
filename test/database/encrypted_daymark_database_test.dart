import 'dart:convert';
import 'dart:io';

import 'package:daymark/core/crypto/journal_key_material.dart';
import 'package:daymark/core/crypto/security_exception.dart';
import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/core/database/encrypted_daymark_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory tempDirectory;
  late File journalFile;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync('daymark-security-test-');
    journalFile = File('${tempDirectory.path}/journal.daymark');
  });

  tearDown(() {
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test('creates and reopens a journal with the same random key material', () async {
    final JournalKeyMaterial keyMaterial = JournalKeyMaterial.generate();
    const String sensitiveText = 'TEST-SECRET-access-key-location-7391';

    try {
      DaymarkDatabase database = await EncryptedDaymarkDatabase.createNew(
        file: journalFile,
        keyMaterial: keyMaterial,
      );

      await database.customStatement('''
        INSERT INTO entries (
          id, entry_type, task_state, content, created_at, updated_at
        ) VALUES (
          '00000000-0000-7000-8000-000000000701',
          'note', NULL, ?, 1, 1
        )
      ''', <Object>[sensitiveText]);
      await database.close();

      expect(journalFile.existsSync(), isTrue);
      expect(journalFile.lengthSync(), greaterThan(0));
      expect(_fileContainsUtf8(journalFile, sensitiveText), isFalse);
      expect(_fileStartsWithSqliteHeader(journalFile), isFalse);

      database = await EncryptedDaymarkDatabase.openExisting(
        file: journalFile,
        keyMaterial: keyMaterial,
      );
      final List<QueryRow> rows = await database.customSelect(
        'SELECT content FROM entries WHERE id = ?',
        variables: const <Variable<Object>>[
          Variable<String>('00000000-0000-7000-8000-000000000701'),
        ],
      ).get();

      expect(rows.single.read<String>('content'), sensitiveText);
      await database.close();
    } finally {
      keyMaterial.destroy();
    }
  });

  test('wrong journal key cannot open an existing encrypted journal', () async {
    final JournalKeyMaterial correctKey = JournalKeyMaterial.generate();
    final JournalKeyMaterial wrongKey = JournalKeyMaterial.generate();

    try {
      final DaymarkDatabase database = await EncryptedDaymarkDatabase.createNew(
        file: journalFile,
        keyMaterial: correctKey,
      );
      await database.close();

      await expectLater(
        EncryptedDaymarkDatabase.openExisting(
          file: journalFile,
          keyMaterial: wrongKey,
        ),
        throwsA(isA<JournalUnlockException>()),
      );
    } finally {
      correctKey.destroy();
      wrongKey.destroy();
    }
  });

  test('unkeyed SQLite access cannot read an encrypted journal', () async {
    final JournalKeyMaterial keyMaterial = JournalKeyMaterial.generate();

    try {
      final DaymarkDatabase database = await EncryptedDaymarkDatabase.createNew(
        file: journalFile,
        keyMaterial: keyMaterial,
      );
      await database.close();

      final Database unkeyed = sqlite3.open(journalFile.path);
      try {
        expect(
          () => unkeyed.select('SELECT name FROM sqlite_master'),
          throwsA(isA<SqliteException>()),
        );
      } finally {
        unkeyed.close();
      }
    } finally {
      keyMaterial.destroy();
    }
  });

  test('schema constraints remain active through encrypted persistence', () async {
    final JournalKeyMaterial keyMaterial = JournalKeyMaterial.generate();

    try {
      final DaymarkDatabase database = await EncryptedDaymarkDatabase.createNew(
        file: journalFile,
        keyMaterial: keyMaterial,
      );

      expect(
        () => database.customStatement('''
          INSERT INTO entries (
            id, entry_type, task_state, content, created_at, updated_at
          ) VALUES (
            '00000000-0000-7000-8000-000000000702',
            'event', 'completed', 'invalid event', 1, 1
          )
        '''),
        throwsA(isA<SqliteException>()),
      );

      await database.close();
    } finally {
      keyMaterial.destroy();
    }
  });
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
