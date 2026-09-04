import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/daily_log_repository.dart';

/// Read-only access to persisted historical Daily Logs through the serialized
/// unlocked journal session.
extension JournalDailyHistorySession on JournalSession {
  Future<DailyLogSnapshot?> findDailyLog(String methodDate) {
    return run(() => dailyLog.find(methodDate));
  }
}
