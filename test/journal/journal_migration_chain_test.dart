import 'package:daymark/core/database/daymark_database.dart';
import 'package:daymark/features/journal/application/journal_service.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('repeated migration forms A to B to C lineage', () async {
    final DaymarkDatabase database = DaymarkDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    final _IdSequence ids = _IdSequence();
    final JournalService service = JournalService(
      JournalRepository(
        database,
        idGenerator: ids.next,
        nowUtcMicros: () => 2_000_000,
      ),
    );

    try {
      final String daily = await service.createLog(
        kind: JournalLogKind.daily,
        periodStart: '2026-09-02',
      );
      final String october = await service.createLog(
        kind: JournalLogKind.monthly,
        periodStart: '2026-10-01',
      );
      final String november = await service.createLog(
        kind: JournalLogKind.monthly,
        periodStart: '2026-11-01',
      );
      final String a = await service.capture(
        type: JournalEntryType.task,
        content: 'Carry this forward deliberately',
        owner: JournalLogOwner(logId: daily),
      );
      final String b = await service.migrate(
        sourceEntryId: a,
        destinationOwner: JournalLogOwner(
          logId: october,
          monthlySection: JournalMonthlySection.tasks,
        ),
      );
      final String c = await service.migrate(
        sourceEntryId: b,
        destinationOwner: JournalLogOwner(
          logId: november,
          monthlySection: JournalMonthlySection.tasks,
        ),
      );

      final rows = await database.customSelect('''
        SELECT source_entry_id, destination_entry_id, kind
        FROM migrations
        ORDER BY id
      ''').get();

      expect(rows, hasLength(2));
      expect(rows[0].read<String>('source_entry_id'), a);
      expect(rows[0].read<String>('destination_entry_id'), b);
      expect(rows[0].read<String>('kind'), 'migrated');
      expect(rows[1].read<String>('source_entry_id'), b);
      expect(rows[1].read<String>('destination_entry_id'), c);
      expect(rows[1].read<String>('kind'), 'migrated');
    } finally {
      await database.close();
    }
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
