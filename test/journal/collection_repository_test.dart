import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DaymarkDatabase database;
  late CollectionRepository collections;
  late _IdSequence ids;

  setUp(() {
    database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    ids = _IdSequence();
    final JournalService service = JournalService(
      JournalRepository(
        database,
        idGenerator: ids.next,
        nowUtcMicros: () => 1_000_000,
      ),
    );
    collections = CollectionRepository(database, service);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and lists Collections in deliberate order', () async {
    await collections.create(title: 'Books');
    await collections.create(title: 'Garden');

    final result = await collections.list();

    expect(result, hasLength(2));
    expect(result[0].title, 'Books');
    expect(result[1].title, 'Garden');
  });

  test('captures Task Event and Note as Collection-owned entries', () async {
    final String id = await collections.create(title: 'Trip');

    await collections.capture(
      collectionId: id,
      type: JournalEntryType.task,
      content: 'Pack radio',
    );
    await collections.capture(
      collectionId: id,
      type: JournalEntryType.event,
      content: 'Train at 08:00',
    );
    await collections.capture(
      collectionId: id,
      type: JournalEntryType.note,
      content: 'Platform 4',
    );

    final CollectionSnapshot snapshot = await collections.load(id);

    expect(snapshot.title, 'Trip');
    expect(snapshot.entries, hasLength(3));
    expect(snapshot.entries[0].type, JournalEntryType.task);
    expect(snapshot.entries[0].taskState, JournalTaskState.open);
    expect(snapshot.entries[1].type, JournalEntryType.event);
    expect(snapshot.entries[1].taskState, isNull);
    expect(snapshot.entries[2].type, JournalEntryType.note);
    expect(snapshot.entries[2].taskState, isNull);

    final placementCount = await database
        .customSelect(
          'SELECT COUNT(*) AS count FROM entry_placements WHERE collection_id = ?',
          variables: <Variable<Object>>[Variable.withString(id)],
        )
        .getSingle();
    expect(placementCount.read<int>('count'), 3);
  });

  test('unknown Collection rejects capture without partial entry write', () async {
    expect(
      () => collections.capture(
        collectionId: '00000000-0000-7000-8000-999999999999',
        type: JournalEntryType.note,
        content: 'Must not persist',
      ),
      throwsA(isA<JournalNotFoundException>()),
    );

    final count = await database
        .customSelect('SELECT COUNT(*) AS count FROM entries')
        .getSingle();
    expect(count.read<int>('count'), 0);
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
