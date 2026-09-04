import 'package:daymark/features/journal/data/index_repository.dart';
import 'package:daymark/features/journal/data/search_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/source_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Search maps every owner kind to its exact journal source', () {
    expect(
      sourceLocationForSearchResult(
        const JournalSearchResult(
          entryId: 'daily-entry',
          type: JournalEntryType.note,
          taskState: null,
          content: 'Daily',
          ownerKind: SearchOwnerKind.log,
          ownerId: 'daily-log',
          updatedAtUtcMicros: 1,
          logKind: JournalLogKind.daily,
          periodStart: '2026-09-03',
        ),
      ),
      '/daily/2026-09-03',
    );

    expect(
      sourceLocationForSearchResult(
        const JournalSearchResult(
          entryId: 'monthly-entry',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Monthly',
          ownerKind: SearchOwnerKind.log,
          ownerId: 'monthly-log',
          updatedAtUtcMicros: 1,
          logKind: JournalLogKind.monthly,
          periodStart: '2026-09-01',
          monthlySection: JournalMonthlySection.tasks,
        ),
      ),
      '/monthly/2026-09-01?section=tasks',
    );

    expect(
      sourceLocationForSearchResult(
        const JournalSearchResult(
          entryId: 'future-entry',
          type: JournalEntryType.event,
          taskState: null,
          content: 'Future',
          ownerKind: SearchOwnerKind.log,
          ownerId: 'future-log',
          updatedAtUtcMicros: 1,
          logKind: JournalLogKind.future,
          periodStart: '2026-10-01',
        ),
      ),
      '/future/2026-10-01',
    );

    expect(
      sourceLocationForSearchResult(
        const JournalSearchResult(
          entryId: 'collection-entry',
          type: JournalEntryType.note,
          taskState: null,
          content: 'Collection',
          ownerKind: SearchOwnerKind.collection,
          ownerId: 'collection-1',
          updatedAtUtcMicros: 1,
          collectionTitle: 'Radio',
        ),
      ),
      '/collections/collection-1',
    );
  });

  test('Index maps persisted structures to their source routes', () {
    expect(
      sourceLocationForIndexItem(
        const IndexItem(
          id: 'index-1',
          ordinal: 0,
          targetKind: IndexTargetKind.log,
          targetId: 'monthly-log',
          logKind: JournalLogKind.monthly,
          periodStart: '2026-09-01',
        ),
      ),
      '/monthly/2026-09-01',
    );

    expect(
      sourceLocationForIndexItem(
        const IndexItem(
          id: 'index-2',
          ordinal: 1,
          targetKind: IndexTargetKind.collection,
          targetId: 'collection-1',
          collectionTitle: 'Radio',
        ),
      ),
      '/collections/collection-1',
    );
  });
}
