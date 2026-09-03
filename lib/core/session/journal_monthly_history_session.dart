import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/monthly_log_repository.dart';

/// Read-only access to persisted historical Monthly Logs through the serialized
/// unlocked journal session.
extension JournalMonthlyHistorySession on JournalSession {
  Future<MonthlyLogSnapshot?> findMonthlyLog(String periodStart) {
    return run(() => monthlyLog.find(periodStart));
  }
}
