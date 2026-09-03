import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/features/journal/presentation/collections_screen.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates opens and captures entries in a Collection', (
    tester,
  ) async {
    final _MemoryCollectionsJournal dataSource = _MemoryCollectionsJournal();
    await _pumpCollections(tester, dataSource);

    expect(find.text('No Collections yet.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Radio projects');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.pump();

    expect(find.text('Radio projects'), findsOneWidget);
    await tester.tap(find.text('Radio projects'));
    await tester.pump();
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Build antenna');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.pump();

    expect(find.text('Build antenna'), findsOneWidget);
    expect(find.text('•'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Collection shows references separately as read-only', (
    tester,
  ) async {
    final _MemoryCollectionsJournal dataSource = _MemoryCollectionsJournal(
      seedReferences: <CollectionReferenceEntry>[
        const CollectionReferenceEntry(
          id: 'daily-note',
          type: JournalEntryType.note,
          taskState: null,
          content: 'Linked note',
          ordinal: 0,
        ),
      ],
    );
    await _pumpCollections(tester, dataSource);
    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pump();

    expect(find.text('References'), findsOneWidget);
    expect(find.text('Linked note'), findsOneWidget);
    expect(find.text('–'), findsOneWidget);
    await tester.tap(find.text('–'));
    await tester.pumpAndSettle();
    expect(find.byType(PopupMenuItem<Object>), findsNothing);
  });

  testWidgets('Collection open Task can complete or discard', (tester) async {
    final _MemoryCollectionsJournal dataSource = _MemoryCollectionsJournal(
      seedEntries: <CollectionEntry>[
        const CollectionEntry(
          id: 'task-1',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'First task',
          ordinal: 0,
        ),
        const CollectionEntry(
          id: 'task-2',
          type: JournalEntryType.task,
          taskState: JournalTaskState.open,
          content: 'Second task',
          ordinal: 1,
        ),
      ],
    );
    await _pumpCollections(tester, dataSource);
    await tester.tap(find.text('Work'));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('•').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pump();
    await tester.pump();
    expect(find.text('×'), findsOneWidget);

    await tester.tap(find.text('•'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pump();
    await tester.pump();

    final Text content = tester.widget<Text>(find.text('Second task'));
    expect(content.style?.decoration, TextDecoration.lineThrough);
  });
}

Future<void> _pumpCollections(
  WidgetTester tester,
  _MemoryCollectionsJournal dataSource,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        collectionsJournalDataSourceProvider.overrideWithValue(dataSource),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CollectionsScreen()),
      ),
    ),
  );
  await tester.pump();
}

final class _MemoryCollectionsJournal implements CollectionsJournalDataSource {
  _MemoryCollectionsJournal({
    List<CollectionEntry>? seedEntries,
    List<CollectionReferenceEntry>? seedReferences,
  }) {
    if (seedEntries != null || seedReferences != null) {
      _collections.add(const CollectionSummary(id: 'work', title: 'Work'));
      _entries['work'] = List<CollectionEntry>.from(seedEntries ?? const []);
      _references['work'] = List<CollectionReferenceEntry>.from(
        seedReferences ?? const [],
      );
    }
  }

  final List<CollectionSummary> _collections = <CollectionSummary>[];
  final Map<String, List<CollectionEntry>> _entries =
      <String, List<CollectionEntry>>{};
  final Map<String, List<CollectionReferenceEntry>> _references =
      <String, List<CollectionReferenceEntry>>{};

  @override
  Future<List<CollectionSummary>> list() async =>
      List<CollectionSummary>.unmodifiable(_collections);

  @override
  Future<String> create({required String title}) async {
    final String id = 'collection-${_collections.length + 1}';
    _collections.add(CollectionSummary(id: id, title: title));
    _entries[id] = <CollectionEntry>[];
    _references[id] = <CollectionReferenceEntry>[];
    return id;
  }

  @override
  Future<CollectionSnapshot> load(String collectionId) async {
    final CollectionSummary collection = _collections.singleWhere(
      (item) => item.id == collectionId,
    );
    return CollectionSnapshot(
      id: collection.id,
      title: collection.title,
      entries: _entries[collectionId]!,
      references: _references[collectionId] ?? const [],
    );
  }

  @override
  Future<void> capture({
    required String collectionId,
    required JournalEntryType type,
    required String content,
  }) async {
    final List<CollectionEntry> entries = _entries[collectionId]!;
    entries.add(
      CollectionEntry(
        id: 'entry-${entries.length + 1}',
        type: type,
        taskState: type == JournalEntryType.task ? JournalTaskState.open : null,
        content: content,
        ordinal: entries.length,
      ),
    );
  }

  @override
  Future<void> completeTask({required String entryId}) async {
    _transition(entryId, JournalTaskState.completed);
  }

  @override
  Future<void> discardTask({required String entryId}) async {
    _transition(entryId, JournalTaskState.discarded);
  }

  void _transition(String entryId, JournalTaskState state) {
    for (final List<CollectionEntry> entries in _entries.values) {
      final int index = entries.indexWhere((entry) => entry.id == entryId);
      if (index < 0) continue;
      final CollectionEntry source = entries[index];
      entries[index] = CollectionEntry(
        id: source.id,
        type: source.type,
        taskState: state,
        content: source.content,
        ordinal: source.ordinal,
      );
      return;
    }
    throw StateError('Missing task.');
  }
}
