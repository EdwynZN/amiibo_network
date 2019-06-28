import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ConnectionFactory {
  static const String _databaseName = "Amiibo.db";
  static const int _databaseVersion = 1;
  Database _database;

  ConnectionFactory._();
  static final ConnectionFactory _instance = ConnectionFactory._();
  factory ConnectionFactory() => _instance;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  close() async{
    if(_database.isOpen) await _database.close();
  }

  _initDB() async {
    String documentsDir = await getDatabasesPath();
    String path = join(documentsDir, _databaseName);

    return await openDatabase(path, version: _databaseVersion, onOpen: (db) async {
    }, onCreate: (Database db, int version) async {
        await db.transaction((tx) async{
          await tx.execute('''
          CREATE TABLE IF NOT EXISTS amiibo (
            id TEXT PRIMARY KEY NOT NULL,
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
        await tx.execute('''CREATE TABLE IF NOT EXISTS date (
            id TEXT PRIMARY KEY,
            lastUpdated TEXT
          );
          ''');
        });
      },
    );
  }
}