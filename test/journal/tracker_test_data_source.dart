import 'package:daymark/features/journal/data/tracker_repository.dart';
import 'package:daymark/features/journal/presentation/tracker_data_source.dart';

final class EmptyTrackerDataSource implements TrackerDataSource {
  const EmptyTrackerDataSource();

  @override
  Future<TrackerMonthSnapshot> loadMonth(String periodStart) async {
    final DateTime month = DateTime.parse(periodStart);
    return TrackerMonthSnapshot(
      periodStart: periodStart,
      daysInMonth: DateTime(month.year, month.month + 1, 0).day,
      trackers: const <TrackerRecord>[],
    );
  }

  @override
  Future<List<TrackerRecord>> loadForDay(String methodDate) async =>
      const <TrackerRecord>[];

  @override
  Future<String> create({
    required String title,
    required String startDate,
    required String plannedEndDate,
  }) async {
    throw StateError('Unexpected Tracker creation in presentation test.');
  }

  @override
  Future<void> setMark({
    required String trackerId,
    required String methodDate,
    required int? value,
  }) async {
    throw StateError('Unexpected Tracker mark write in presentation test.');
  }

  @override
  Future<void> endEarly({
    required String trackerId,
    required String methodDate,
  }) async {
    throw StateError('Unexpected Tracker end in presentation test.');
  }
}
