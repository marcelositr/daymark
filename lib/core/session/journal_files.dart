import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persistent files that make up the single local Daymark journal used by the
/// initial product flow.
///
/// The encrypted database and the authenticated key envelope are intentionally
/// separate files. Neither is useful on its own, and incomplete pairs are
/// treated as a storage problem instead of being overwritten automatically.
final class JournalFiles {
  const JournalFiles(this.directory);

  final Directory directory;

  File get databaseFile => File(
    '${directory.path}${Platform.pathSeparator}journal.sqlite3',
  );

  File get keyEnvelopeFile => File(
    '${directory.path}${Platform.pathSeparator}journal.key-envelope.json',
  );

  File get creatingKeyEnvelopeFile => File('${keyEnvelopeFile.path}.creating');

  Future<void> ensureDirectory() async {
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  static Future<JournalFiles> forApplication() async {
    return JournalFiles(await getApplicationSupportDirectory());
  }
}
