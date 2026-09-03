import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/index_repository.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late JournalService service;
  late IndexRepository index;
  late _IdSequence ids;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    ids = _IdSequence();
    service = JournalService(
      JournalRepository(
        database,
        idGenerator: ids.next,
        nowUtcMicros: () => 1_000_000,
      ),
    );
    index = IndexRepository(
      database,
      idGenerator: ids.next,
      nowUtcMicros: () => 2_000_000,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('preserves deliberate Index insertion order across target types', () async {
    final String dailyId = await service.createLog(
      kind: JournalLogKind.daily,
      periodStart: '2026-09-03',
    );
    final String monthlyId = await service.createLog(
      kind: JournalLogKind.monthly,
      periodStart: '2026-09-01',
    );
    final String collectionId = await service.createCollection(
      title: 'Radio',
    );

    await index.addCollection(collectionId);
    await index.addLog(monthlyId);
    await index.addLog(dailyId);

    final List<IndexItem> items = await index.list();

    expect(items, hasLength(3));
    expect(items.map((item) => item.ordinal), <int>[0, 1, 2]);
    expect(items[0].targetKind, IndexTargetKind.collection);
    expect(items[0].collectionTitle, 'Radio');
    expect(items[1].targetKind, IndexTargetKind.log);
    expect(items[1].logKind, JournalLogKind.monthly);
    expect(items[1].periodStart, '2026-09-01');
    expect(items[2].logKind, JournalLogKind.daily);
    expect(items[2].periodStart, '2026-09-03');
  });

  test('candidates exclude structures already present in the Index', () async {
    final String futureId = await service.createLog(
      kind: JournalLogKind.future,
      periodStart: '2026-10-01',
    );
    final String collectionId = await service.createCollection(
      title: 'Trip',
    );

    await index.addLog(futureId);

    final List<IndexCandidate> candidates = await index.candidates();

    expect(candidates, hasLength(1));
    expect(candidates.single.targetKind, IndexTargetKind.collection);
    expect(candidates.single.targetId, collectionId);
    expect(candidates.single.collectionTitle, 'Trip');
  });

  test('rejects duplicate and unknown targets without partial Index rows', () async {
    final String collectionId = await service.createCollection(
      title: 'Reading',
    );
    await index.addCollection(collectionId);

    expect(
      () => index.addCollection(collectionId),
      throwsA(isA<JournalInvariantException>()),
    );
    expect(
      () => index.addLog('00000000-0000-7000-8000-999999999999'),
      throwsA(isA<JournalNotFoundException>()),
    );

    final row = await database
        .customSelect('SELECT COUNT(*) AS count FROM index_items')
        .getSingle();
    expect(row.read<int>('count'), 1);
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
