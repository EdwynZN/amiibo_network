import 'dart:io';

import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'drift_database.g.dart';

final databaseProvider = Provider((ref) => AppDatabase());

@DriftDatabase(
  //tables: [AmiiboTable, AmiiboUserPreferencesTable],
  daos: [AmiiboDao],
  include: const {'amiibo_tables.drift'},
)
class AppDatabase extends _$AppDatabase {
  static const String _databaseName = "Amiibo.db";

  AppDatabase() : super(_openConnection(AppDatabase._databaseName));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        await customStatement('PRAGMA foreign_keys = OFF');
        if (from < 2) {
          await transaction(() async {
            await customStatement('ALTER TABLE amiibo RENAME TO _amiibo_old;');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS amiibo(
                key INTEGER PRIMARY KEY AUTOINCREMENT,
                id TEXT,
                amiiboSeries TEXT NOT NULL,
                character TEXT NOT NULL,
                gameSeries TEXT NOT NULL,
                name TEXT NOT NULL,
                au TEXT,
                eu TEXT,
                jp TEXT,
                na TEXT,
                type TEXT NOT NULL,
                wishlist INTEGER,
                owned INTEGER;
              )
            ''');
            await customStatement('''INSERT INTO
                amiibo(id, amiiboSeries, character, gameSeries, character,
                  name, au, eu, jp, na, type, wishlist, owned)
                SELECT id, amiiboSeries, character, gameSeries, character, 
                  name, au, eu, jp, na, type, wishlist, owned
                FROM _amiibo_old ORDER BY id;
              ''');
            await customStatement('DROP TABLE _amiibo_old;');
          });
        }
        if (from < 3) {
          // we added the priority property in the change from version 1 or 2
          // to version 3
          //await m.addColumn(todos, todos.priority);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          List<Map<String, dynamic>> table;
          await transaction(() async {
            table = await customSelect('SELECT * FROM date;')
                .map((p0) => p0.data)
                .get();
            table.forEach((date) {
              if (date['id'] == '1')
                prefs.setString(sharedDateDB, date['lastUpdated']);
              if (date['id'] == '2')
                prefs.setString(sharedOldTheme, date['lastUpdated']);
            });
            await customStatement('DROP TABLE date;');
          });
        }
        if (from < 4) {
          await transaction(() async {
            await customStatement('ALTER TABLE amiibo RENAME TO _amiibo_old;');
            await customStatement('''
              CREATE TABLE IF NOT EXISTS amiibo(
                key INTEGER PRIMARY KEY AUTOINCREMENT,
                id TEXT,
                amiiboSeries TEXT NOT NULL,
                character TEXT NOT NULL,
                gameSeries TEXT NOT NULL,
                name TEXT NOT NULL,
                au TEXT,
                eu TEXT,
                jp TEXT,
                na TEXT,
                type TEXT NOT NULL,
                cardNumber INTEGER,
                wishlist INTEGER,
                owned INTEGER
              );
            ''');
            await customStatement('''INSERT INTO
                amiibo(key, id, amiiboSeries, character, gameSeries, character,
                  name, au, eu, jp, na, type, wishlist, owned)
                SELECT key, id, amiiboSeries, character, gameSeries, character, 
                  name, au, eu, jp, na, type, wishlist, owned
                FROM _amiibo_old ORDER BY id;
              ''');
            await customStatement('DROP TABLE _amiibo_old;');
          });
        }
        if (from < 5) {
          await transaction(() async {
            await customStatement('ALTER TABLE amiibo RENAME TO _amiibo_old;');
            await m.createAll();
            await customInsert('''INSERT INTO
                amiibo(key, id, amiiboSeries, character, gameSeries, character,
                  name, au, eu, jp, na, type)
                SELECT key, id, amiiboSeries, character, gameSeries, character, 
                  name, au, eu, jp, na, type
                FROM _amiibo_old ORDER BY id;
              ''');
            await customInsert('''INSERT OR REPLACE INTO 
                amiibo_user_preferences(amiibo_key, opened, boxed, wishlist)
                SELECT key, owned, 0, wishlist FROM _amiibo_old ORDER BY id;
              ''');
            await customStatement('DROP TABLE _amiibo_old;');
          });
        }
      },
    );
  }
}

LazyDatabase _openConnection(String databaseName) {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    String documentsDir = await getDatabasesPath();
    final file = File(join(documentsDir, databaseName));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
