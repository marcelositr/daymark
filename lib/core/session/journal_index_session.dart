import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/index_repository.dart';

/// Serialized Index operations that remain valid only while the journal is
/// unlocked.
extension JournalIndexSession on JournalSession {
  Future<List<IndexItem>> listIndexItems() {
    return run(() => IndexRepository(database).list());
  }

  Future<List<IndexCandidate>> listIndexCandidates() {
    return run(() => IndexRepository(database).candidates());
  }

  Future<void> addLogToIndex(String logId) {
    return run(() => IndexRepository(database).addLog(logId));
  }

  Future<void> addCollectionToIndex(String collectionId) {
    return run(() => IndexRepository(database).addCollection(collectionId));
  }
}
