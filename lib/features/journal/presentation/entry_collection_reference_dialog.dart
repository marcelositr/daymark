import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class EntryCollectionReferenceDataSource {
  Future<List<CollectionSummary>> listCollections();

  Future<void> referenceEntry({
    required String entryId,
    required String collectionId,
  });
}

final Provider<EntryCollectionReferenceDataSource>
entryCollectionReferenceDataSourceProvider =
    Provider<EntryCollectionReferenceDataSource>((ref) {
      final JournalAccessState access = ref
          .watch(journalSessionControllerProvider)
          .requireValue;
      if (access case JournalUnlocked(:final session)) {
        return _SessionEntryCollectionReferenceDataSource(session);
      }
      throw StateError(
        'Collection references require an unlocked journal session.',
      );
    });

final class _SessionEntryCollectionReferenceDataSource
    implements EntryCollectionReferenceDataSource {
  const _SessionEntryCollectionReferenceDataSource(this._session);

  final JournalSession _session;

  @override
  Future<List<CollectionSummary>> listCollections() {
    return _session.listCollections();
  }

  @override
  Future<void> referenceEntry({
    required String entryId,
    required String collectionId,
  }) {
    return _session.referenceEntryInCollection(
      entryId: entryId,
      collectionId: collectionId,
    );
  }
}

Future<String?> showEntryCollectionReferenceDialog({
  required BuildContext context,
  required EntryCollectionReferenceDataSource dataSource,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Future<List<CollectionSummary>> collectionsFuture = dataSource
      .listCollections();

  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.referenceEntryTitle),
      children: [
        FutureBuilder<List<CollectionSummary>>(
          future: collectionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(l10n.collectionsLoadFailed),
              );
            }

            final List<CollectionSummary> collections = snapshot.requireData;
            if (collections.isEmpty) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(l10n.emptyCollections),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final CollectionSummary collection in collections)
                  SimpleDialogOption(
                    onPressed: () => Navigator.of(context).pop(collection.id),
                    child: Text(collection.title),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
