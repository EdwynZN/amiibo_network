// ignore test lint
// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:amiibo_network/app/configuration/data_providers.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalDB creation and update', () {
    late Directory tempDir;
    late File dbFile;
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('db_test_');
      dbFile = File(p.join(tempDir.path, 'test.db'));
      db = AppDatabase(NativeDatabase(dbFile));

      container = ProviderContainer.test(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() {
      container.dispose();
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      rootBundle.clear();
    });

    testWidgets('create DB', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await tester.runAsync(() async {
        SharedPreferences.setMockInitialValues({});
        final updateSevice = container
            .listen(updateServiceProvider, (_, _) {})
            .read();

        await updateSevice.createDB();

        final db = container.listen(databaseProvider, (_, _) {}).read();

        await db.amiiboDao;
      });
    });
  });

  group('LocalDB queries', () {
    late File dbFile;
    late AppDatabase db;
    late ProviderContainer container;

    setUpAll(() {
      final currDir = Directory.current;
      dbFile = File(p.join(currDir.path, 'test.db'));
    });

    setUp(() async {
      db = AppDatabase(NativeDatabase(dbFile, logStatements: false));
      container = ProviderContainer.test(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('read Amiibo DB', () async {
      final db = container.listen(databaseProvider, (_, _) {}).read();

      final type = await db.amiiboDao.fetchByKeyTest(857);
      print(
        Map<String, dynamic>.of(type?.rawData.data ?? {})
          ..removeWhere((key, value) {
            return !key.startsWith('b.');
          }),
      );
    });
  });
}
