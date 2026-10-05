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
