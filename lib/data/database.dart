import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';

class ConnectionFactory {
  static const String _databaseName = "Amiibo.db";
  static const int _databaseVersion = 1;

  ConnectionFactory._();
  static final ConnectionFactory _instance = ConnectionFactory._();
  factory ConnectionFactory() => _instance;

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    String documentsDir = await getDatabasesPath();
    String path = join(documentsDir, _databaseName);
    print(path);

    return await openDatabase(path, version: _databaseVersion, onOpen: (db) async {
    }, onCreate: (Database db, int version) async {
      await db.execute('''
				CREATE TABLE IF NOT EXISTS amiibo (
				  id TEXT PRIMARY KEY,
					amiiboSeries TEXT,
          character TEXT,
          gameSeries TEXT,
          image TEXT,
          name TEXT,
          au TEXT,
          eu TEXT,
          jp TEXT,
          na TEXT,
          type TEXT,
          wishlist INTEGER,
          owned INTEGER
				);
			''');
      print("CREATED TABLE");
    });
  }

}