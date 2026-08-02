// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;

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
            final db = AppDatabase(schema.newConnection());
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
  test('migration from v7 to v8 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldCountryData = <v7.CountryData>[];
    final expectedNewCountryData = <v8.CountryData>[];

    final oldAffiliationLinkData = <v7.AffiliationLinkData>[];
    final expectedNewAffiliationLinkData = <v8.AffiliationLinkData>[];

    final oldAmiiboData = <v7.AmiiboData>[];
    final expectedNewAmiiboData = <v8.AmiiboData>[];

    final oldAmiiboUserPreferencesData = <v7.AmiiboUserPreferencesData>[];
    final expectedNewAmiiboUserPreferencesData =
        <v8.AmiiboUserPreferencesData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 7,
      newVersion: 8,
      createOld: v7.DatabaseAtV7.new,
      createNew: v8.DatabaseAtV8.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.country, oldCountryData);
        batch.insertAll(oldDb.affiliationLink, oldAffiliationLinkData);
        batch.insertAll(oldDb.amiibo, oldAmiiboData);
        batch.insertAll(
          oldDb.amiiboUserPreferences,
          oldAmiiboUserPreferencesData,
        );
      },
      validateItems: (newDb) async {
        expect(expectedNewCountryData, await newDb.select(newDb.country).get());
        expect(
          expectedNewAffiliationLinkData,
          await newDb.select(newDb.affiliationLink).get(),
        );
        expect(expectedNewAmiiboData, await newDb.select(newDb.amiibo).get());
        expect(
          expectedNewAmiiboUserPreferencesData,
          await newDb.select(newDb.amiiboUserPreferences).get(),
        );
      },
    );
  });
}
