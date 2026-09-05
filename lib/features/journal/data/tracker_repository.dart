import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

enum TrackerLifecycle { planned, active, completed, ended }

final class TrackerRecord {
  const TrackerRecord({
    required this.id,
    required this.title,
    required this.startDate,
    required this.plannedEndDate,
    required this.endedDate,
    required this.colorSlot,
    required this.marks,
  });

  final String id;
  final String title;
  final String startDate;
  final String plannedEndDate;
  final String? endedDate;
  final int colorSlot;
  final Map<String, int> marks;

  String get effectiveEndDate => endedDate ?? plannedEndDate;

  bool isActiveOn(String methodDate) {
    return methodDate.compareTo(startDate) >= 0 &&
        methodDate.compareTo(effectiveEndDate) <= 0;
  }

  bool hasExplicitMark(String methodDate) => marks.containsKey(methodDate);

  int valueOn(String methodDate) {
    if (!isActiveOn(methodDate)) {
      throw JournalInvariantException(
        'Tracker value requested outside the active period.',
      );
    }
    return marks[methodDate] ?? 0;
  }

  TrackerLifecycle lifecycleOn(String methodDate) {
    if (methodDate.compareTo(startDate) < 0) {
      return TrackerLifecycle.planned;
    }
    if (endedDate != null && methodDate.compareTo(endedDate!) > 0) {
      return TrackerLifecycle.ended;
    }
    if (methodDate.compareTo(plannedEndDate) > 0) {
      return TrackerLifecycle.completed;
    }
    return TrackerLifecycle.active;
  }
}

final class TrackerMonthSnapshot {
  const TrackerMonthSnapshot({
    required this.periodStart,
    required this.daysInMonth,
    required this.trackers,
  });

  final String periodStart;
  final int daysInMonth;
  final List<TrackerRecord> trackers;
}

final class TrackerRepository {
  TrackerRepository(
    this._database, {
    String Function()? idGenerator,
    int Function()? nowUtcMicros,
  }) : _idGenerator = idGenerator ?? const Uuid().v7,
       _nowUtcMicros =
           nowUtcMicros ?? (() => DateTime.now().toUtc().microsecondsSinceEpoch);

  final DaymarkDatabase _database;
  final String Function() _idGenerator;
  final int Function() _nowUtcMicros;

  Future<TrackerMonthSnapshot> loadMonth(String periodStart) async {
    final DateTime month = _requireMonthStart(periodStart);
    final String monthEnd = _formatDate(
      DateTime(month.year, month.month + 1, 0),
    );
    final List<QueryRow> rows = await _database.customSelect(
      '''
      SELECT id, title, start_date, planned_end_date, ended_date, color_slot
      FROM trackers
      WHERE start_date <= ?
        AND COALESCE(ended_date, planned_end_date) >= ?
      ORDER BY color_slot, start_date, created_at, id
      ''',
      variables: <Variable>[
        Variable<String>(monthEnd),
        Variable<String>(periodStart),
      ],
    ).get();

    final List<TrackerRecord> trackers = <TrackerRecord>[];
    for (final QueryRow row in rows) {
      trackers.add(
        await _recordFromRow(
          row,
          marksFrom: periodStart,
          marksThrough: monthEnd,
        ),
      );
    }

    return TrackerMonthSnapshot(
      periodStart: periodStart,
      daysInMonth: DateTime(month.year, month.month + 1, 0).day,
      trackers: trackers,
    );
  }

  Future<List<TrackerRecord>> loadForDay(String methodDate) async {
    _requireMethodDate(methodDate);
    final List<QueryRow> rows = await _database.customSelect(
      '''
      SELECT id, title, start_date, planned_end_date, ended_date, color_slot
      FROM trackers
      WHERE start_date <= ?
        AND COALESCE(ended_date, planned_end_date) >= ?
      ORDER BY color_slot, created_at, id
      ''',
      variables: <Variable>[
        Variable<String>(methodDate),
        Variable<String>(methodDate),
      ],
    ).get();

    final List<TrackerRecord> trackers = <TrackerRecord>[];
    for (final QueryRow row in rows) {
      trackers.add(
        await _recordFromRow(
          row,
          marksFrom: methodDate,
          marksThrough: methodDate,
        ),
      );
    }
    return trackers;
  }

  Future<String> create({
    required String title,
    required String startDate,
    required String plannedEndDate,
  }) async {
    final String normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const JournalInvariantException('Tracker title cannot be empty.');
    }
    _requireMethodDate(startDate);
    _requireMethodDate(plannedEndDate);
    if (plannedEndDate.compareTo(startDate) < 0) {
      throw const JournalInvariantException(
        'Tracker end date cannot be before its start date.',
      );
    }

    return _database.transaction(() async {
      final List<QueryRow> occupiedRows = await _database.customSelect(
        '''
        SELECT DISTINCT color_slot
        FROM trackers
        WHERE start_date <= ?
          AND COALESCE(ended_date, planned_end_date) >= ?
        ''',
        variables: <Variable>[
          Variable<String>(plannedEndDate),
          Variable<String>(startDate),
        ],
      ).get();
      final Set<int> occupied = <int>{
        for (final QueryRow row in occupiedRows) row.read<int>('color_slot'),
      };
      final int? colorSlot = _firstAvailableSlot(occupied);
      if (colorSlot == null) {
        throw const JournalInvariantException(
          'At most five Trackers may overlap on the same period.',
        );
      }

      final String id = _idGenerator();
      final int now = _nowUtcMicros();
      await _database.customStatement(
        '''
        INSERT INTO trackers (
          id,
          title,
          start_date,
          planned_end_date,
          ended_date,
          color_slot,
          created_at,
          updated_at
        ) VALUES (?, ?, ?, ?, NULL, ?, ?, ?)
        ''',
        <Object?>[
          id,
          normalizedTitle,
          startDate,
          plannedEndDate,
          colorSlot,
          now,
          now,
        ],
      );
      return id;
    });
  }

  Future<void> setMark({
    required String trackerId,
    required String methodDate,
    required int? value,
  }) async {
    _requireMethodDate(methodDate);
    if (value != null && value != 1 && value != -1) {
      throw const JournalInvariantException(
        'Tracker marks are explicit +1 or -1 only.',
      );
    }

    await _database.transaction(() async {
      final QueryRow tracker = await _requireTracker(trackerId);
      final String startDate = tracker.read<String>('start_date');
      final String plannedEndDate = tracker.read<String>('planned_end_date');
      final String? endedDate = tracker.readNullable<String>('ended_date');
      final String effectiveEndDate = endedDate ?? plannedEndDate;
      if (methodDate.compareTo(startDate) < 0 ||
          methodDate.compareTo(effectiveEndDate) > 0) {
        throw const JournalInvariantException(
          'A Tracker mark must belong to its active period.',
        );
      }

      if (value == null) {
        await _database.customStatement(
          'DELETE FROM tracker_marks WHERE tracker_id = ? AND method_date = ?',
          <Object?>[trackerId, methodDate],
        );
        return;
      }

      final int now = _nowUtcMicros();
      await _database.customStatement(
        '''
        INSERT INTO tracker_marks (
          tracker_id,
          method_date,
          value,
          created_at,
          updated_at
        ) VALUES (?, ?, ?, ?, ?)
        ON CONFLICT (tracker_id, method_date) DO UPDATE SET
          value = excluded.value,
          updated_at = excluded.updated_at
        ''',
        <Object?>[trackerId, methodDate, value, now, now],
      );
    });
  }

  Future<void> endEarly({
    required String trackerId,
    required String methodDate,
  }) async {
    _requireMethodDate(methodDate);
    await _database.transaction(() async {
      final QueryRow tracker = await _requireTracker(trackerId);
      final String startDate = tracker.read<String>('start_date');
      final String plannedEndDate = tracker.read<String>('planned_end_date');
      final String? endedDate = tracker.readNullable<String>('ended_date');

      if (endedDate != null) {
        if (endedDate == methodDate) {
          return;
        }
        throw const JournalInvariantException('Tracker is already ended.');
      }
      if (methodDate.compareTo(startDate) < 0 ||
          methodDate.compareTo(plannedEndDate) >= 0) {
        throw const JournalInvariantException(
          'Early end must be inside the Tracker period and before planned end.',
        );
      }

      final int now = _nowUtcMicros();
      await _database.customStatement(
        'UPDATE trackers SET ended_date = ?, updated_at = ? WHERE id = ?',
        <Object?>[methodDate, now, trackerId],
      );
      await _database.customStatement(
        'DELETE FROM tracker_marks WHERE tracker_id = ? AND method_date > ?',
        <Object?>[trackerId, methodDate],
      );
    });
  }

  Future<QueryRow> _requireTracker(String trackerId) async {
    final List<QueryRow> rows = await _database.customSelect(
      '''
      SELECT id, title, start_date, planned_end_date, ended_date, color_slot
      FROM trackers
      WHERE id = ?
      LIMIT 1
      ''',
      variables: <Variable>[Variable<String>(trackerId)],
    ).get();
    if (rows.isEmpty) {
      throw JournalNotFoundException('Tracker', trackerId);
    }
    return rows.single;
  }

  Future<TrackerRecord> _recordFromRow(
    QueryRow row, {
    required String marksFrom,
    required String marksThrough,
  }) async {
    final String id = row.read<String>('id');
    final List<QueryRow> markRows = await _database.customSelect(
      '''
      SELECT method_date, value
      FROM tracker_marks
      WHERE tracker_id = ?
        AND method_date >= ?
        AND method_date <= ?
      ORDER BY method_date
      ''',
      variables: <Variable>[
        Variable<String>(id),
        Variable<String>(marksFrom),
        Variable<String>(marksThrough),
      ],
    ).get();

    return TrackerRecord(
      id: id,
      title: row.read<String>('title'),
      startDate: row.read<String>('start_date'),
      plannedEndDate: row.read<String>('planned_end_date'),
      endedDate: row.readNullable<String>('ended_date'),
      colorSlot: row.read<int>('color_slot'),
      marks: <String, int>{
        for (final QueryRow mark in markRows)
          mark.read<String>('method_date'): mark.read<int>('value'),
      },
    );
  }

  int? _firstAvailableSlot(Set<int> occupied) {
    for (int slot = 0; slot < 5; slot++) {
      if (!occupied.contains(slot)) {
        return slot;
      }
    }
    return null;
  }

  DateTime _requireMonthStart(String value) {
    final DateTime date = _requireMethodDate(value);
    if (date.day != 1) {
      throw const JournalInvariantException(
        'Tracker month period must use the first day of the month.',
      );
    }
    return date;
  }

  DateTime _requireMethodDate(String value) {
    if (value.length != 10) {
      throw const JournalInvariantException('Invalid method date.');
    }
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null || _formatDate(parsed) != value) {
      throw const JournalInvariantException('Invalid method date.');
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }
}
