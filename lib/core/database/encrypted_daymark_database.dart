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
      _requireEncryptedSqlite(rawDatabase);
      rawDatabase.execute("PRAGMA cipher = 'chacha20';");
      rawDatabase.execute("PRAGMA key = 'raw:$rawKeyHex';");

      try {
        // PRAGMA key intentionally does not prove that a key is correct.
        // A real read forces SQLite3MultipleCiphers to authenticate/decrypt.
        rawDatabase.select('SELECT count(*) FROM sqlite_master;');
        rawDatabase.select("SELECT sqlite3mc_config('cipher');");
      } on SqliteException {
        if (existing) {
          throw const JournalUnlockException();
        }
        throw const JournalDatabaseOpenException(
          'Encrypted journal initialization failed.',
        );
      }

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
