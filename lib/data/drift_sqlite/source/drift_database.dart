import 'dart:io';

import 'package:amiibo_network/data/drift_sqlite/source/amiibo_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'drift_database.g.dart';

final databaseProvider = Provider((ref) => AppDatabase());

/* class AmiiboTable extends Table {
  IntColumn get key => integer().autoIncrement()();
  TextColumn get tag => text().named('id').nullable()();
  TextColumn get amiiboSeries => text()();
  TextColumn get character => text()();
  TextColumn get gameSeries => text()();
  TextColumn get name => text()();
  TextColumn get au => text()();
  TextColumn get eu => text()();
  TextColumn get jp => text()();
  TextColumn get na => text()();
  TextColumn get type => text().nullable()();
  IntColumn get cardNumber => integer().nullable()();
}

class AmiiboUserPreferencesTable extends Table {
  IntColumn get key => integer().autoIncrement()();
  IntColumn get amiiboTableKey =>
      integer().named('amiibo_key').references(AmiiboTable, #key).unique()();
  IntColumn get boxed => integer().withDefault(const Constant(0))();
  IntColumn get opened => integer().withDefault(const Constant(0))();
  BoolColumn get wishlist => boolean().withDefault(const Constant(false))();
} */

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
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // we added the dueDate property in the change from version 1 to
          // version 2
          //await m.addColumn(todos, todos.dueDate);
        }
        if (from < 3) {
          // we added the priority property in the change from version 1 or 2
          // to version 3
          //await m.addColumn(todos, todos.priority);
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
