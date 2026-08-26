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
  group('LocalDB updated and queries', () {
    late Directory tempDir;
    late File dbFile;
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() async {
      // 1. Create a real test database file in a temp directory
      tempDir = Directory.systemTemp.createTempSync('pondo_db_test_');
      dbFile = File(p.join(tempDir.path, 'pondo_test.db'));
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
}
