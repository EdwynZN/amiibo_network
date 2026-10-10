// ignore test lint
// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/feature/collection/application/input/update_collection_input.dart';
import 'package:amiibo_network/feature/collection/infrastructure/configuration/configuration.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

void main() {
  late File dbFile;
  late AppDatabase db;
  late ProviderContainer container;

  setUpAll(() {
    final currDir = Directory.current;
    dbFile = File(p.join(currDir.path, 'test/collection/test.db'));
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase(dbFile, logStatements: false));
    container = ProviderContainer.test(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    /// Clear all data in the database after each test
    await db.batch((b) {
      b
        ..update(
          db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            opened: .new(0),
            boxed: .new(0),
            wishlist: .new(false),
          ),
        )
        ..update(
          db.amiiboBundleUserPreferences,
          AmiiboBundleUserPreferencesCompanion(opened: .new(0), boxed: .new(0)),
        );
    });
  });

  tearDown(() async {
    container.dispose();
    await db.batch((b) {
      b
        ..update(
          db.amiiboUserPreferences,
          AmiiboUserPreferencesCompanion(
            opened: .new(0),
            boxed: .new(0),
            wishlist: .new(false),
          ),
        )
        ..update(
          db.amiiboBundleUserPreferences,
          AmiiboBundleUserPreferencesCompanion(opened: .new(0), boxed: .new(0)),
        );
    });
  });

  test('test fetch single', () async {
    final db = container.listen(databaseProvider, (_, _) {}).read();

    final query = db.customSelect('''
      SELECT
        a.key,
        a.amiiboSeries,
        a.character,
        a.character,
        a.gameSeries,
        a.name,
        a.au,
        a.eu,
        a.jp,
        a.na,
        a.type,
        a.cardNumber,
        "amiibo_user_preferences"."boxed" AS boxed, 
        "amiibo_user_preferences"."opened" AS opened,
        "amiibo_user_preferences"."wishlist" AS wishlist,
        json_array("amiibo_images"."file_path") AS images,
        COALESCE (
          (
            SELECT json_array(
                json_object(
                  'id', "amiibo_bundle"."id", 
                  'amiiboIds', json_group_array("m"."amiibo_key"), 
                  'images', json_array("amiibo_bundle_images"."file_path"),
                  'boxed', "amiibo_bundle_user_preferences"."boxed", 
                  'opened', "amiibo_bundle_user_preferences"."opened"
                )
              )
              FROM "amiibo_bundle_relation" AS e
              JOIN "amiibo_bundle_relation" AS m ON "e"."amiibo_bundle_id" = "m"."amiibo_bundle_id" 
              JOIN "amiibo_bundle" ON "amiibo_bundle"."id" = "e"."amiibo_bundle_id" 
              LEFT OUTER JOIN "amiibo_bundle_user_preferences" ON "amiibo_bundle_user_preferences"."amiibo_bundle_id" = "amiibo_bundle"."id" 
              LEFT OUTER JOIN "amiibo_bundle_images" ON "amiibo_bundle_images"."amiibo_bundle_id" = "amiibo_bundle"."id"
              WHERE "e"."amiibo_key" = a.key
              GROUP BY "amiibo_bundle"."id"
              ORDER BY "amiibo_bundle"."id" ASC, "amiibo_bundle_images"."create_at" ASC
          ), '[]'
        ) as bundles
      FROM amiibo a
      LEFT OUTER JOIN "amiibo_user_preferences" ON "amiibo_user_preferences"."amiibo_key" = "a"."key"
      LEFT OUTER JOIN "amiibo_images" ON "amiibo_images"."amiibo_key" = "a"."key"
      WHERE "a"."key" = 850;
''');
    final result = await query.get();
    print(result.first.data);
  });

  test('read Amiibo DB', () async {
    final db = container.listen(databaseProvider, (_, _) {}).read();
    final useCase = container
        .listen(updateCollectionUseCaseProvider, (_, _) {})
        .read();
    await useCase.call(
      UpdateCollectionInput(
        clearAll: true,
        amiibos: [
          for (int i = 1; i <= 45; i++)
            CollectionAmiibo(
              id: i,
              attributes: switch (i % 3) {
                0 => .none(),
                1 => .owned(boxed: i % 6 == 0 ? 1 : 0, opened: 1),
                _ => .wished(),
              },
            ),
        ],
        bundles: [
          for (int i = 1; i <= 10; i++)
            CollectionAmiibo(
              id: i,
              attributes: switch (i % 3) {
                0 => .none(),
                1 => .owned(boxed: i % 6 == 0 ? 1 : 0, opened: 1),
                _ => .wished(),
              },
            ),
        ],
      ),
    );

    final amiibosQuery = await db.select(db.amiiboUserPreferences)
      ..limit(45)
      ..orderBy([(t) => OrderingTerm(expression: t.amiiboKey, mode: .asc)]);

    var amiibos = await amiibosQuery.get();
    expect(amiibos, hasLength(45));
    expect(amiibos.where((amiibo) => amiibo.wishlist), hasLength(15));
    expect(
      amiibos.where((amiibo) => amiibo.boxed > 0 || amiibo.opened > 0),
      hasLength(15),
    );
    expect(
      amiibos.where(
        (amiibo) => !amiibo.wishlist && amiibo.boxed <= 0 && amiibo.opened <= 0,
      ),
      hasLength(15),
    );

    final bundlesQuery = await db.select(db.amiiboBundleUserPreferences)
      ..limit(10)
      ..orderBy([
        (t) => OrderingTerm(expression: t.amiiboBundleId, mode: .asc),
      ]);

    var bundles = await bundlesQuery.get();
    expect(bundles, hasLength(10));
    expect(
      bundles.where((amiibo) => amiibo.boxed > 0 || amiibo.opened > 0),
      hasLength(4),
    );
    expect(
      bundles.where((amiibo) => amiibo.boxed <= 0 && amiibo.opened <= 0),
      hasLength(6),
    );

    await useCase.call(
      UpdateCollectionInput(
        clearAll: true,
        amiibos: [
          for (int i = 1; i <= 45; i++)
            CollectionAmiibo(id: i, attributes: .wished()),
        ],
        bundles: [
          for (int i = 1; i <= 10; i++)
            CollectionAmiibo(id: i, attributes: .none()),
        ],
      ),
    );

    amiibos = await amiibosQuery.get();
    expect(amiibos, hasLength(45));
    expect(amiibos.where((amiibo) => amiibo.wishlist), hasLength(45));
    expect(
      amiibos.where((amiibo) => amiibo.boxed > 0 || amiibo.opened > 0),
      hasLength(0),
    );
    expect(
      amiibos.where(
        (amiibo) => !amiibo.wishlist && amiibo.boxed <= 0 && amiibo.opened <= 0,
      ),
      hasLength(0),
    );

    bundles = await bundlesQuery.get();
    expect(bundles, hasLength(10));
    expect(
      bundles.where((amiibo) => amiibo.boxed > 0 || amiibo.opened > 0),
      hasLength(0),
    );
    expect(
      bundles.where((amiibo) => amiibo.boxed <= 0 && amiibo.opened <= 0),
      hasLength(10),
    );
  });
}
