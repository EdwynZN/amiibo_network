import 'package:amiibo_network/data/drift_sqlite/source/affiliation_link_dao.dart';
import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'drift_database.g.dart';

final databaseProvider = Provider((ref) => AppDatabase());

@DriftDatabase(
  //tables: [AmiiboTable, AmiiboUserPreferencesTable],
  daos: [AmiiboDao, AffiliationLinkDao],
  include: const {'amiibo_tables.drift', 'affiliation_tables.drift'},
)
class AppDatabase extends _$AppDatabase {
  static const String _databaseName = "Amiibo.db";

  AppDatabase() : super(_openExecuter(AppDatabase._databaseName));

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        if (kDebugMode) {
          // This check pulls in a fair amount of code that's not needed
          // anywhere else, so we recommend only doing it in debug builds.
          await validateDatabaseSchema();
        }
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
            await customStatement('''INSERT INTO
                amiibo(key, id, amiiboSeries, character, gameSeries, character,
                  name, au, eu, jp, na, type)
                SELECT key, id, amiiboSeries, character, gameSeries, character, 
                  name, au, eu, jp, na, type
                FROM _amiibo_old ORDER BY id;
              ''');
            await customStatement('''INSERT OR REPLACE INTO 
                amiibo_user_preferences(amiibo_key, opened, boxed, wishlist)
                SELECT key, owned, 0, wishlist FROM _amiibo_old ORDER BY id;
              ''');
            await customStatement('DROP TABLE _amiibo_old;');
          });
        }
        if (from == 5 && to == 6) {
          await transaction(() async {
            await customStatement(
                'ALTER TABLE amiibo_user_preferences RENAME TO _amiibo_user_preferences_old;');
            await m.createAll();
            await customStatement('''INSERT OR REPLACE INTO 
                amiibo_user_preferences(key, amiibo_key, opened, boxed, wishlist)
                SELECT
                  key,
                  amiibo_key,
                  opened,
                  boxed,
                  CASE
                    WHEN wishlist = '1' OR wishlist = 1 THEN 1
                    ELSE 0
                  END AS wishlist
                FROM _amiibo_user_preferences_old ORDER BY amiibo_key;
              ''');
            await customStatement('DROP TABLE _amiibo_user_preferences_old;');
          });
        }
        if (from == 6) {
          await m.createTable(country);
          await m.createTable(affiliationLink);
        }
      },
    );
  }
}

QueryExecutor _openExecuter(String databaseName) {
  return SqfliteQueryExecutor.inDatabaseFolder(path: databaseName);
  // the LazyDatabase util lets us find the right location for the file async.
  /* return LazyDatabase(() async {
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
  }); */
}
