import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/future_log_repository.dart';

/// Read-only access to an exact persisted Future Log month through the
/// serialized unlocked journal session.
extension JournalFutureHistorySession on JournalSession {
  Future<FutureLogSnapshot?> findFutureLog(String periodStart) {
    return run(() => futureLog.find(periodStart));
  }
}
