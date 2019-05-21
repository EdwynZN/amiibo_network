import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';

class ConnectionFactory {
  static final String _databaseName = "Amiibo.db";
  static final int _databaseVersion = 1;
  SqfliteAdapter _adapter;

  ConnectionFactory._();
  static final ConnectionFactory _instance = ConnectionFactory._();
  factory ConnectionFactory() => _instance;

  Future<SqfliteAdapter> get adapter async {
    if (_adapter != null) return _adapter;
    _adapter = await _initAdapter();
    return _adapter;
  }

  close() async{
    if(_adapter.connection.isOpen) {
      _adapter.close();
      _adapter = null;
    }
  }

  _initAdapter() async{
    final String documentsDir = await getDatabasesPath();
    final String path = join(documentsDir, _databaseName);
    _adapter = SqfliteAdapter(path, version: _databaseVersion);
    //print(path);
    await _adapter.connect();

    //_createAmiiboTable();
    //_createDateTable();

    return _adapter;
  }

  /*Database _database;

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
  */
}