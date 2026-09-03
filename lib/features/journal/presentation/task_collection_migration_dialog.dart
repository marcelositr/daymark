import 'package:daymark/features/journal/data/collection_repository.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Future<String?> showTaskCollectionMigrationDialog({
  required BuildContext context,
  required List<CollectionSummary> collections,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l10n.collections),
      children: collections.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(l10n.emptyCollections),
              ),
            ]
          : [
              for (final CollectionSummary collection in collections)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(collection.id),
                  child: Text(collection.title),
                ),
            ],
    ),
  );
}
