import 'dart:async';

import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/features/journal/domain/journal_domain.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'journal_activity_guard.dart';

abstract interface class CollectionsJournalDataSource {
  Future<List<CollectionSummary>> list();

  Future<String> create({required String title});

  Future<CollectionSnapshot> load(String collectionId);

  Future<void> capture({
    required String collectionId,
    required JournalEntryType type,
    required String content,
  });

  Future<void> completeTask({required String entryId});

  Future<void> discardTask({required String entryId});
}

final Provider<CollectionsJournalDataSource> collectionsJournalDataSourceProvider =
    Provider<CollectionsJournalDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionCollectionsJournalDataSource(session);
      }
      throw StateError('Collections requires an unlocked journal session.');
    });

final class _SessionCollectionsJournalDataSource
    implements CollectionsJournalDataSource {
  const _SessionCollectionsJournalDataSource(this._session);

  final JournalSession _session;

  @override
  Future<List<CollectionSummary>> list() => _session.listCollections();

  @override
  Future<String> create({required String title}) {
    return _session.createCollection(title: title);
  }

  @override
  Future<CollectionSnapshot> load(String collectionId) {
    return _session.loadCollection(collectionId);
  }

  @override
  Future<void> capture({
    required String collectionId,
    required JournalEntryType type,
    required String content,
  }) {
    return _session.captureCollectionEntry(
      collectionId: collectionId,
      type: type,
      content: content,
    );
  }

  @override
  Future<void> completeTask({required String entryId}) {
    return _session.completeTask(entryId: entryId);
  }

  @override
  Future<void> discardTask({required String entryId}) {
    return _session.discardTask(entryId: entryId);
  }
}

class CollectionsScreen extends ConsumerStatefulWidget {
  const CollectionsScreen({super.key});

  @override
  ConsumerState<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends ConsumerState<CollectionsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _entryController = TextEditingController();

  late Future<List<CollectionSummary>> _collectionsFuture;
  Future<CollectionSnapshot>? _collectionFuture;
  String? _selectedCollectionId;
  JournalEntryType _entryType = JournalEntryType.task;
  bool _saving = false;
  String? _taskActionEntryId;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _dataSource().list();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: _selectedCollectionId == null
            ? _buildCollectionList(l10n)
            : _buildCollection(l10n),
      ),
    );
  }

  Widget _buildCollectionList(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.collections,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              onPressed: _lock,
              tooltip: l10n.lockJournal,
              icon: const Icon(Icons.lock_outline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<CollectionSummary>>(
            future: _collectionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Center(child: Text(l10n.collectionsLoadFailed));
              }
              final collections = snapshot.requireData;
              if (collections.isEmpty) {
                return Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Text(l10n.emptyCollections),
                );
              }
              return ListView.separated(
                itemCount: collections.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final CollectionSummary collection = collections[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(collection.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _saving ? null : () => _open(collection.id),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _titleController,
                enabled: !_saving,
                onChanged: (_) => JournalActivityGuard.recordActivity(context),
                decoration: InputDecoration(
                  hintText: l10n.collectionTitleHint,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _saving ? null : _createCollection,
              tooltip: l10n.createCollection,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollection(AppLocalizations l10n) {
    return FutureBuilder<CollectionSnapshot>(
      future: _collectionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text(l10n.collectionLoadFailed));
        }
        final CollectionSnapshot collection = snapshot.requireData;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _saving ? null : _backToList,
                  tooltip: l10n.backToCollections,
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Text(
                    collection.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _lock,
                  tooltip: l10n.lockJournal,
                  icon: const Icon(Icons.lock_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: collection.entries.isEmpty
                  ? Align(
                      alignment: AlignmentDirectional.topStart,
                      child: Text(l10n.emptyCollection),
                    )
                  : ListView.separated(
                      itemCount: collection.entries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) =>
                          _buildEntry(l10n, collection.entries[index]),
                    ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<JournalEntryType>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: JournalEntryType.task,
                  label: Text(l10n.entryTask),
                ),
                ButtonSegment(
                  value: JournalEntryType.event,
                  label: Text(l10n.entryEvent),
                ),
                ButtonSegment(
                  value: JournalEntryType.note,
                  label: Text(l10n.entryNote),
                ),
              ],
              selected: <JournalEntryType>{_entryType},
              onSelectionChanged: _saving
                  ? null
                  : (selection) => setState(() => _entryType = selection.single),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _entryController,
                    enabled: !_saving,
                    minLines: 1,
                    maxLines: 4,
                    onChanged: (_) => JournalActivityGuard.recordActivity(context),
                    decoration: InputDecoration(
                      hintText: l10n.collectionEntryHint,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _saving ? null : _capture,
                  tooltip: l10n.addEntry,
                  icon: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEntry(AppLocalizations l10n, CollectionEntry entry) {
    final TextStyle? style = Theme.of(context).textTheme.bodyLarge;
    final bool discarded = entry.taskState == JournalTaskState.discarded;
    final Text marker = Text(
      _entrySymbol(entry),
      style: discarded
          ? Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(decoration: TextDecoration.lineThrough)
          : Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.center,
    );

    Widget leading = marker;
    if (entry.type == JournalEntryType.task &&
        entry.taskState == JournalTaskState.open) {
      leading = PopupMenuButton<_CollectionTaskAction>(
        enabled: _taskActionEntryId == null,
        tooltip: l10n.taskActions,
        padding: EdgeInsets.zero,
        onSelected: (action) => unawaited(_applyTaskAction(entry, action)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _CollectionTaskAction.complete,
            child: Text(l10n.completeTask),
          ),
          PopupMenuItem(
            value: _CollectionTaskAction.discard,
            child: Text(l10n.discardTask),
          ),
        ],
        child: marker,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 28, child: leading),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.content,
            style: discarded
                ? style?.copyWith(decoration: TextDecoration.lineThrough)
                : style,
          ),
        ),
      ],
    );
  }

  CollectionsJournalDataSource _dataSource() {
    return ref.read(collectionsJournalDataSourceProvider);
  }

  void _open(String collectionId) {
    setState(() {
      _selectedCollectionId = collectionId;
      _collectionFuture = _dataSource().load(collectionId);
    });
  }

  void _backToList() {
    setState(() {
      _selectedCollectionId = null;
      _collectionFuture = null;
      _collectionsFuture = _dataSource().list();
    });
  }

  Future<void> _createCollection() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty || _saving) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await _dataSource().create(title: title);
      if (!mounted) return;
      _titleController.clear();
      setState(() {
        _collectionsFuture = _dataSource().list();
        _saving = false;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedCollectionsError('create', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.createCollectionFailed)));
      setState(() => _saving = false);
    }
  }

  Future<void> _capture() async {
    final String content = _entryController.text.trim();
    final String? collectionId = _selectedCollectionId;
    if (content.isEmpty || collectionId == null || _saving) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await _dataSource().capture(
        collectionId: collectionId,
        type: _entryType,
        content: content,
      );
      if (!mounted) return;
      _entryController.clear();
      setState(() {
        _collectionFuture = _dataSource().load(collectionId);
        _saving = false;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedCollectionsError('capture', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saveEntryFailed)));
      setState(() => _saving = false);
    }
  }

  Future<void> _applyTaskAction(
    CollectionEntry entry,
    _CollectionTaskAction action,
  ) async {
    final String? collectionId = _selectedCollectionId;
    if (collectionId == null || _taskActionEntryId != null) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _taskActionEntryId = entry.id);
    try {
      switch (action) {
        case _CollectionTaskAction.complete:
          await _dataSource().completeTask(entryId: entry.id);
        case _CollectionTaskAction.discard:
          await _dataSource().discardTask(entryId: entry.id);
      }
      if (!mounted) return;
      setState(() {
        _collectionFuture = _dataSource().load(collectionId);
        _taskActionEntryId = null;
      });
    } catch (error, stackTrace) {
      _reportUnexpectedCollectionsError('task action', error, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.taskActionFailed)));
      setState(() => _taskActionEntryId = null);
    }
  }

  Future<void> _lock() async {
    try {
      await ref.read(journalSessionControllerProvider.notifier).lock();
    } catch (error, stackTrace) {
      _reportUnexpectedCollectionsError('lock', error, stackTrace);
    }
  }
}

enum _CollectionTaskAction { complete, discard }

String _entrySymbol(CollectionEntry entry) => switch (entry.type) {
  JournalEntryType.task => switch (entry.taskState) {
    JournalTaskState.completed => '×',
    JournalTaskState.migrated => '>',
    JournalTaskState.scheduled => '<',
    JournalTaskState.discarded => '•',
    JournalTaskState.open => '•',
    null => '•',
  },
  JournalEntryType.event => '○',
  JournalEntryType.note => '–',
};

void _reportUnexpectedCollectionsError(
  String operation,
  Object error,
  StackTrace stackTrace,
) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FlutterError(
        'Collections $operation failed (${error.runtimeType}).',
      ),
      stack: stackTrace,
      library: 'daymark',
    ),
  );
}
