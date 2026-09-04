import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/search_repository.dart';

/// Read-only Search access through the serialized unlocked journal session.
extension JournalSearchSession on JournalSession {
  Future<List<JournalSearchResult>> searchJournal(String query) {
    return run(() => JournalSearchRepository(database).search(query));
  }
}
