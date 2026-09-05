import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/data/tracker_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late TrackerRepository repository;
  late _IdSequence ids;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    ids = _IdSequence();
    repository = TrackerRepository(
      database,
      idGenerator: ids.next,
      nowUtcMicros: () => 1_000_000,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('absence is zero while explicit marks are only +1 or -1', () async {
    final String trackerId = await repository.create(
      title: 'Devocional',
      startDate: '2026-09-01',
      plannedEndDate: '2026-09-30',
    );

    TrackerRecord tracker = (await repository.loadForDay('2026-09-04')).single;
    expect(tracker.valueOn('2026-09-04'), 0);
    expect(tracker.hasExplicitMark('2026-09-04'), isFalse);

    await repository.setMark(
      trackerId: trackerId,
      methodDate: '2026-09-04',
      value: 1,
    );
    tracker = (await repository.loadForDay('2026-09-04')).single;
    expect(tracker.valueOn('2026-09-04'), 1);
    expect(tracker.hasExplicitMark('2026-09-04'), isTrue);

    await repository.setMark(
      trackerId: trackerId,
      methodDate: '2026-09-04',
      value: null,
    );
    tracker = (await repository.loadForDay('2026-09-04')).single;
    expect(tracker.valueOn('2026-09-04'), 0);
    expect(tracker.hasExplicitMark('2026-09-04'), isFalse);

    await repository.setMark(
      trackerId: trackerId,
      methodDate: '2026-09-04',
      value: -1,
    );
    tracker = (await repository.loadForDay('2026-09-04')).single;
    expect(tracker.valueOn('2026-09-04'), -1);
  });

  test('rejects a sixth overlapping Tracker and reuses a free slot later', () async {
    for (int index = 0; index < 5; index++) {
      final String id = await repository.create(
        title: 'Tracker ${index + 1}',
        startDate: '2026-09-01',
        plannedEndDate: '2026-09-30',
      );
      final TrackerRecord record = (await repository.loadForDay(
        '2026-09-15',
      )).singleWhere((TrackerRecord tracker) => tracker.id == id);
      expect(record.colorSlot, index);
    }

    expect(
      () => repository.create(
        title: 'Tracker 6',
        startDate: '2026-09-15',
        plannedEndDate: '2026-09-20',
      ),
      throwsA(isA<JournalInvariantException>()),
    );

    final String october = await repository.create(
      title: 'October',
      startDate: '2026-10-01',
      plannedEndDate: '2026-10-31',
    );
    final TrackerRecord octoberRecord = (await repository.loadForDay(
      '2026-10-01',
    )).singleWhere((TrackerRecord tracker) => tracker.id == october);
    expect(octoberRecord.colorSlot, 0);
  });

  test('ending early preserves earlier history and removes later marks', () async {
    final String trackerId = await repository.create(
      title: 'Read',
      startDate: '2026-09-01',
      plannedEndDate: '2026-09-30',
    );
    await repository.setMark(
      trackerId: trackerId,
      methodDate: '2026-09-10',
      value: 1,
    );
    await repository.setMark(
      trackerId: trackerId,
      methodDate: '2026-09-20',
      value: -1,
    );

    await repository.endEarly(
      trackerId: trackerId,
      methodDate: '2026-09-15',
    );

    final TrackerMonthSnapshot month = await repository.loadMonth('2026-09-01');
    final TrackerRecord tracker = month.trackers.single;
    expect(tracker.endedDate, '2026-09-15');
    expect(tracker.marks['2026-09-10'], 1);
    expect(tracker.marks.containsKey('2026-09-20'), isFalse);
    expect(tracker.lifecycleOn('2026-09-16'), TrackerLifecycle.ended);
    expect(await repository.loadForDay('2026-09-16'), isEmpty);
  });

  test('month snapshot includes only Trackers intersecting the month', () async {
    await repository.create(
      title: 'August only',
      startDate: '2026-08-01',
      plannedEndDate: '2026-08-31',
    );
    await repository.create(
      title: 'Cross month',
      startDate: '2026-08-20',
      plannedEndDate: '2026-09-10',
    );
    await repository.create(
      title: 'September',
      startDate: '2026-09-05',
      plannedEndDate: '2026-09-25',
    );

    final TrackerMonthSnapshot snapshot = await repository.loadMonth(
      '2026-09-01',
    );
    expect(snapshot.daysInMonth, 30);
    expect(
      snapshot.trackers.map((TrackerRecord tracker) => tracker.title).toSet(),
      <String>{'Cross month', 'September'},
    );
  });

  test('rejects marks outside the active period', () async {
    final String trackerId = await repository.create(
      title: 'Finite',
      startDate: '2026-09-10',
      plannedEndDate: '2026-09-20',
    );

    expect(
      () => repository.setMark(
        trackerId: trackerId,
        methodDate: '2026-09-09',
        value: 1,
      ),
      throwsA(isA<JournalInvariantException>()),
    );
    expect(
      () => repository.setMark(
        trackerId: trackerId,
        methodDate: '2026-09-21',
        value: -1,
      ),
      throwsA(isA<JournalInvariantException>()),
    );
  });
}

final class _IdSequence {
  int _value = 1;

  String next() {
    final String suffix = _value.toString().padLeft(12, '0');
    _value++;
    return '00000000-0000-7000-8000-$suffix';
  }
}
