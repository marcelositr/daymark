import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../crypto/journal_key_material.dart';
import '../crypto/security_exception.dart';
import 'daymark_database.dart';

abstract final class EncryptedDaymarkDatabase {
  static Future<DaymarkDatabase> createNew({
    required File file,
    required JournalKeyMaterial keyMaterial,
  }) async {
    if (file.existsSync()) {
      throw const JournalDatabaseOpenException(
        'Refusing to create a journal over an existing file.',
      );
    }

    return _open(file: file, keyMaterial: keyMaterial, existing: false);
  }

  static Future<DaymarkDatabase> openExisting({
    required File file,
    required JournalKeyMaterial keyMaterial,
  }) async {
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw const JournalDatabaseOpenException(
        'The encrypted journal file does not exist or is empty.',
      );
    }

    return _open(file: file, keyMaterial: keyMaterial, existing: true);
  }

  /// Creates a transactionally consistent encrypted SQLite snapshot.
  ///
  /// SQLite's online backup API copies logical pages through the configured
  /// cipher instead of copying a potentially changing database file byte for
  /// byte. The destination uses the same raw journal key material and remains
  /// independently encrypted at rest.
  static Future<void> createSnapshot({
    required File sourceFile,
    required File destinationFile,
    required JournalKeyMaterial keyMaterial,
  }) async {
    if (!sourceFile.existsSync() || sourceFile.lengthSync() == 0) {
      throw const JournalDatabaseOpenException(
        'The encrypted journal file does not exist or is empty.',
      );
    }
    if (destinationFile.existsSync()) {
      throw const JournalDatabaseOpenException(
        'Refusing to create an encrypted snapshot over an existing file.',
      );
    }
    if (keyMaterial.isDestroyed) {
      throw StateError('Journal key material has been destroyed.');
    }

    final Uint8List rawKeyMaterial = keyMaterial.serialize();
    final String rawKeyHex = _toHex(rawKeyMaterial);
    rawKeyMaterial.fillRange(0, rawKeyMaterial.length, 0);

    Database? sourceDatabase;
    Database? destinationDatabase;

    try {
      sourceDatabase = sqlite3.open(
        sourceFile.path,
        mode: OpenMode.readOnly,
      );
      _configureEncryptedDatabase(
        sourceDatabase,
        rawKeyHex: rawKeyHex,
        existing: true,
      );

      destinationDatabase = sqlite3.open(destinationFile.path);
      _configureEncryptedDatabase(
        destinationDatabase,
        rawKeyHex: rawKeyHex,
        existing: false,
      );

      await for (final double _ in sourceDatabase.backup(
        destinationDatabase,
      )) {}

      // Prove that the completed snapshot can be authenticated and read before
      // handing it to the backup container layer.
      destinationDatabase.select('SELECT count(*) FROM sqlite_master;');
    } on DaymarkSecurityException {
      rethrow;
    } on SqliteException {
      throw const JournalDatabaseOpenException(
        'Encrypted journal snapshot creation failed.',
      );
    } finally {
      destinationDatabase?.close();
      sourceDatabase?.close();

      if (destinationFile.existsSync() && destinationFile.lengthSync() == 0) {
        destinationFile.deleteSync();
      }
    }
  }

  /// Validates an encrypted database without returning an application session.
  ///
  /// This is intentionally read-only and is used by restore staging before any
  /// working journal files are replaced.
  static void validateExisting({
    required File file,
    required JournalKeyMaterial keyMaterial,
    required int expectedSchemaVersion,
  }) {
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw const JournalDatabaseOpenException(
        'The encrypted journal file does not exist or is empty.',
      );
    }
    if (keyMaterial.isDestroyed) {
      throw StateError('Journal key material has been destroyed.');
    }
    if (expectedSchemaVersion < 1) {
      throw ArgumentError.value(
        expectedSchemaVersion,
        'expectedSchemaVersion',
        'Schema versions start at 1.',
      );
    }

    final Uint8List rawKeyMaterial = keyMaterial.serialize();
    final String rawKeyHex = _toHex(rawKeyMaterial);
    rawKeyMaterial.fillRange(0, rawKeyMaterial.length, 0);

    final Database database = sqlite3.open(file.path, mode: OpenMode.readOnly);

    try {
      _configureEncryptedDatabase(
        database,
        rawKeyHex: rawKeyHex,
        existing: true,
      );

      if (database.userVersion != expectedSchemaVersion) {
        throw JournalDatabaseOpenException(
          'Encrypted journal schema version ${database.userVersion} does not '
          'match expected version $expectedSchemaVersion.',
        );
      }

      final ResultSet integrityRows = database.select('PRAGMA integrity_check;');
      if (integrityRows.length != 1 ||
          integrityRows.first['integrity_check'] != 'ok') {
        throw const JournalDatabaseOpenException(
          'Encrypted journal integrity validation failed.',
        );
      }

      final ResultSet foreignKeyRows = database.select(
        'PRAGMA foreign_key_check;',
      );
      if (foreignKeyRows.isNotEmpty) {
        throw const JournalDatabaseOpenException(
          'Encrypted journal foreign-key validation failed.',
        );
      }
    } on DaymarkSecurityException {
      rethrow;
    } on SqliteException {
      throw const JournalDatabaseOpenException(
        'Encrypted journal validation failed.',
      );
    } finally {
      database.close();
    }
  }

  static Future<DaymarkDatabase> _open({
    required File file,
    required JournalKeyMaterial keyMaterial,
    required bool existing,
  }) async {
    if (keyMaterial.isDestroyed) {
      throw StateError('Journal key material has been destroyed.');
    }

    final Uint8List rawKeyMaterial = keyMaterial.serialize();
    final String rawKeyHex = _toHex(rawKeyMaterial);
    rawKeyMaterial.fillRange(0, rawKeyMaterial.length, 0);

    final Database rawDatabase = sqlite3.open(file.path);

    try {
      _configureEncryptedDatabase(
        rawDatabase,
        rawKeyHex: rawKeyHex,
        existing: existing,
      );

      final DaymarkDatabase database = DaymarkDatabase(
        NativeDatabase.opened(rawDatabase),
      );

      // Force Drift to run its open lifecycle before returning. In particular,
      // createNew must finish schema creation instead of returning a database
      // whose onCreate callback has not executed yet.
      await database.customSelect('SELECT 1').get();

      return database;
    } on DaymarkSecurityException {
      rawDatabase.close();
      rethrow;
    } catch (_) {
      rawDatabase.close();
      rethrow;
    }
  }

  static void _configureEncryptedDatabase(
    Database database, {
    required String rawKeyHex,
    required bool existing,
  }) {
    _requireEncryptedSqlite(database);
    database.execute("PRAGMA cipher = 'chacha20';");
    database.execute("PRAGMA key = 'raw:$rawKeyHex';");

    try {
      // PRAGMA key intentionally does not prove that a key is correct.
      // A real read forces SQLite3MultipleCiphers to authenticate/decrypt.
      database.select('SELECT count(*) FROM sqlite_master;');
      database.select("SELECT sqlite3mc_config('cipher');");
    } on SqliteException {
      if (existing) {
        throw const JournalUnlockException();
      }
      throw const JournalDatabaseOpenException(
        'Encrypted journal initialization failed.',
      );
    }
  }

  static void _requireEncryptedSqlite(Database database) {
    final ResultSet rows = database.select('PRAGMA cipher;');
    if (rows.isEmpty) {
      throw const EncryptedDatabaseUnavailableException();
    }
  }
}

String _toHex(List<int> bytes) {
  final StringBuffer result = StringBuffer();
  for (final int byte in bytes) {
    result.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return result.toString();
}
