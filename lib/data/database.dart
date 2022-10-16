import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/preferences_constants.dart';

const String _amiiboTable = '''
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
  ''';

void _onCreate(Database db, int version) async {
  await db.transaction((tx) async {
    await tx.execute(_amiiboTable);
  });
}

void _onUpgrade(Database db, int oldVersion, int newVersion) async {
  print('Old DB: $oldVersion | New DB: $newVersion');
  if (oldVersion < 2) {
    await db.transaction((tx) async {
      await tx.execute('ALTER TABLE amiibo RENAME TO _amiibo_old;');
      await tx.execute('''
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
          owned INTEGER
        ); 
      ''');
      await tx.execute('''INSERT INTO
          amiibo(id, amiiboSeries, character, gameSeries, character,
            name, au, eu, jp, na, type, wishlist, owned)
          SELECT id, amiiboSeries, character, gameSeries, character, 
            name, au, eu, jp, na, type, wishlist, owned
          FROM _amiibo_old ORDER BY id;
        ''');
      await tx.execute('DROP TABLE _amiibo_old;');
    });
  }
  if (oldVersion < 3) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> table;
    await db.transaction((tx) async {
      table = await tx.rawQuery('SELECT * FROM date;');
      table.forEach((date) {
        if (date['id'] == '1')
          prefs.setString(sharedDateDB, date['lastUpdated']);
        if (date['id'] == '2')
          prefs.setString(sharedOldTheme, date['lastUpdated']);
      });
      await tx.execute('DROP TABLE date;');
    });
  }
  if (oldVersion < 4) {
    await db.transaction((tx) async {
      await tx.execute('ALTER TABLE amiibo RENAME TO _amiibo_old;');
      await tx.execute('''
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
      await tx.execute('''INSERT INTO
          amiibo(key, id, amiiboSeries, character, gameSeries, character,
            name, au, eu, jp, na, type, wishlist, owned)
          SELECT key, id, amiiboSeries, character, gameSeries, character, 
            name, au, eu, jp, na, type, wishlist, owned
          FROM _amiibo_old ORDER BY id;
        ''');
      await tx.execute('DROP TABLE _amiibo_old;');
    });
  }
}

class ConnectionFactory {
  static const String _databaseName = "Amiibo.db";
  static const int _databaseVersion = 4;
  Database? _database;

  ConnectionFactory._();
  static final ConnectionFactory _instance = ConnectionFactory._();
  factory ConnectionFactory() => _instance;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  Future<void> close() async {
    if (_database!.isOpen) await _database!.close();
  }

  _initDB() async {
    String documentsDir = await getDatabasesPath();
    String path = join(documentsDir, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion,
        onOpen: (db) => null,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }
}
