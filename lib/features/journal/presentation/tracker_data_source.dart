import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/core/session/journal_tracker_session.dart';
import 'package:daymark/features/journal/data/tracker_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class TrackerDataSource {
  Future<TrackerMonthSnapshot> loadMonth(String periodStart);

  Future<List<TrackerRecord>> loadForDay(String methodDate);

  Future<String> create({
    required String title,
    required String startDate,
    required String plannedEndDate,
  });

  Future<void> setMark({
    required String trackerId,
    required String methodDate,
    required int? value,
  });

  Future<void> endEarly({
    required String trackerId,
    required String methodDate,
  });
}

final Provider<TrackerDataSource> trackerDataSourceProvider =
    Provider<TrackerDataSource>((Ref ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionTrackerDataSource(session);
      }
      throw StateError('Trackers require an unlocked journal session.');
    });

final class _SessionTrackerDataSource implements TrackerDataSource {
  const _SessionTrackerDataSource(this._session);

  final dynamic _session;

  @override
  Future<TrackerMonthSnapshot> loadMonth(String periodStart) {
    return _session.loadTrackerMonth(periodStart) as Future<TrackerMonthSnapshot>;
  }

  @override
  Future<List<TrackerRecord>> loadForDay(String methodDate) {
    return _session.loadTrackersForDay(methodDate) as Future<List<TrackerRecord>>;
  }

  @override
  Future<String> create({
    required String title,
    required String startDate,
    required String plannedEndDate,
  }) {
    return _session.createTracker(
          title: title,
          startDate: startDate,
          plannedEndDate: plannedEndDate,
        )
        as Future<String>;
  }

  @override
  Future<void> setMark({
    required String trackerId,
    required String methodDate,
    required int? value,
  }) {
    return _session.setTrackerMark(
          trackerId: trackerId,
          methodDate: methodDate,
          value: value,
        )
        as Future<void>;
  }

  @override
  Future<void> endEarly({
    required String trackerId,
    required String methodDate,
  }) {
    return _session.endTrackerEarly(
          trackerId: trackerId,
          methodDate: methodDate,
        )
        as Future<void>;
  }
}
