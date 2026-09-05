import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/features/journal/data/tracker_repository.dart';

extension JournalTrackerSession on JournalSession {
  Future<TrackerMonthSnapshot> loadTrackerMonth(String periodStart) {
    return run(() => TrackerRepository(database).loadMonth(periodStart));
  }

  Future<List<TrackerRecord>> loadTrackersForDay(String methodDate) {
    return run(() => TrackerRepository(database).loadForDay(methodDate));
  }

  Future<String> createTracker({
    required String title,
    required String startDate,
    required String plannedEndDate,
  }) {
    return run(
      () => TrackerRepository(database).create(
        title: title,
        startDate: startDate,
        plannedEndDate: plannedEndDate,
      ),
    );
  }

  Future<void> setTrackerMark({
    required String trackerId,
    required String methodDate,
    required int? value,
  }) {
    return run(
      () => TrackerRepository(database)
          .setMark(trackerId: trackerId, methodDate: methodDate, value: value),
    );
  }

  Future<void> endTrackerEarly({
    required String trackerId,
    required String methodDate,
  }) {
    return run(
      () =>
          TrackerRepository(database)
              .endEarly(trackerId: trackerId, methodDate: methodDate),
    );
  }
}
