// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:daymark/core/database/daymark_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = DaymarkDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v1 to v2 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldJournalMetadataData = <v1.JournalMetadataData>[];
    final expectedNewJournalMetadataData = <v2.JournalMetadataData>[];

    final oldLogsData = <v1.LogsData>[];
    final expectedNewLogsData = <v2.LogsData>[];

    final oldCollectionsData = <v1.CollectionsData>[];
    final expectedNewCollectionsData = <v2.CollectionsData>[];

    final oldEntriesData = <v1.EntriesData>[];
    final expectedNewEntriesData = <v2.EntriesData>[];

    final oldEntryPlacementsData = <v1.EntryPlacementsData>[];
    final expectedNewEntryPlacementsData = <v2.EntryPlacementsData>[];

    final oldMigrationsData = <v1.MigrationsData>[];
    final expectedNewMigrationsData = <v2.MigrationsData>[];

    final oldCollectionReferencesData = <v1.CollectionReferencesData>[];
    final expectedNewCollectionReferencesData = <v2.CollectionReferencesData>[];

    final oldSignifiersData = <v1.SignifiersData>[];
    final expectedNewSignifiersData = <v2.SignifiersData>[];

    final oldEntrySignifiersData = <v1.EntrySignifiersData>[];
    final expectedNewEntrySignifiersData = <v2.EntrySignifiersData>[];

    final oldIndexItemsData = <v1.IndexItemsData>[];
    final expectedNewIndexItemsData = <v2.IndexItemsData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: DaymarkDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.journalMetadata, oldJournalMetadataData);
        batch.insertAll(oldDb.logs, oldLogsData);
        batch.insertAll(oldDb.collections, oldCollectionsData);
        batch.insertAll(oldDb.entries, oldEntriesData);
        batch.insertAll(oldDb.entryPlacements, oldEntryPlacementsData);
        batch.insertAll(oldDb.migrations, oldMigrationsData);
        batch.insertAll(
          oldDb.collectionReferences,
          oldCollectionReferencesData,
        );
        batch.insertAll(oldDb.signifiers, oldSignifiersData);
        batch.insertAll(oldDb.entrySignifiers, oldEntrySignifiersData);
        batch.insertAll(oldDb.indexItems, oldIndexItemsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewJournalMetadataData,
          await newDb.select(newDb.journalMetadata).get(),
        );
        expect(expectedNewLogsData, await newDb.select(newDb.logs).get());
        expect(
          expectedNewCollectionsData,
          await newDb.select(newDb.collections).get(),
        );
        expect(expectedNewEntriesData, await newDb.select(newDb.entries).get());
        expect(
          expectedNewEntryPlacementsData,
          await newDb.select(newDb.entryPlacements).get(),
        );
        expect(
          expectedNewMigrationsData,
          await newDb.select(newDb.migrations).get(),
        );
        expect(
          expectedNewCollectionReferencesData,
          await newDb.select(newDb.collectionReferences).get(),
        );
        expect(
          expectedNewSignifiersData,
          await newDb.select(newDb.signifiers).get(),
        );
        expect(
          expectedNewEntrySignifiersData,
          await newDb.select(newDb.entrySignifiers).get(),
        );
        expect(
          expectedNewIndexItemsData,
          await newDb.select(newDb.indexItems).get(),
        );
      },
    );
  });
}
