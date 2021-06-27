import '../dao.dart';
import '../../data/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:amiibo_network/model/amiibo.dart';

class AmiiboSQLite implements Dao<Amiibo?, int> {
  static ConnectionFactory connectionFactory = ConnectionFactory();

  Future<void> initDB() async => await connectionFactory.database;

  Future<List<Amiibo>> fetchAll([String? orderBy = 'na']) async {
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> list =
        await _db.query('amiibo', orderBy: orderBy);
    return list
        .map((dynamic i) => Amiibo.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchDistinct(String name, List<String>? column,
      String? where, List<Object>? args, String? orderBy) async {
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query(
      name,
      distinct: true,
      columns: column,
      where: where,
      whereArgs: args,
      orderBy: orderBy,
    );
    return List<String>.from(maps.map((x) => x['amiiboSeries']));
  }

  Future<List<String>> fetchLimit(String? where, List<dynamic>? args, int limit,
      [String column = 'name']) async {
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('amiibo',
        distinct: true,
        columns: [column],
        where: where,
        whereArgs: args,
        limit: limit);
    return List<String>.from(maps.map((x) => x[column]));
  }

  Future<List<Amiibo>> fetchByColumn(String? where, List<dynamic>? args,
      [String? orderBy]) async {
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> list = await _db.query(
      'amiibo',
      where: where,
      whereArgs: args,
      orderBy: orderBy ?? 'na',
    );
    return list
        .map((dynamic i) => Amiibo.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchSum(
      String? where, List<dynamic>? args, bool group) async {
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> result = await _db.query('amiibo',
        columns: [
          if (group) 'amiiboSeries',
          'count(1) AS Total',
          'count(case WHEN wishlist=1 then 1 end) AS Wished',
          'count(case WHEN owned=1 then 1 end) AS Owned'
        ],
        where: where,
        whereArgs: args,
        groupBy: group ? 'amiiboSeries' : null);
    return result;
  }

  Future<Amiibo?> fetchByKey(int key) async {
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps =
        await _db.query('amiibo', where: 'key = ?', whereArgs: [key]);
    if (maps.length > 0) return Amiibo.fromJson(maps.first);
    return null;
  }

  Future<void> insertAll(List<Amiibo?> list, String name) async {
    Database _db = await connectionFactory.database;
    final batch = _db.batch();
    for (Amiibo? query in list) {
      batch.execute('''INSERT OR REPLACE INTO amiibo
      VALUES(?,?,?,?,?,?,?,?,?,?,?,
      (SELECT wishlist FROM amiibo WHERE key = ?),
      (SELECT owned FROM amiibo WHERE key = ?)
      );
      ''', [
        query!.key,
        query.id,
        query.amiiboSeries,
        query.character,
        query.gameSeries,
        query.name,
        query.au,
        query.eu,
        query.jp,
        query.na,
        query.type,
        query.key,
        query.key
      ]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> insertImport(List<Amiibo> list) async {
    Database _db = await connectionFactory.database;
    final batch = _db.batch();
    for (var query in list) {
      batch.execute('''UPDATE amiibo
        SET wishlist = ?, owned = ?
        WHERE key = ?;
      ''', [query.wishlist, query.owned, query.key]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> insert(Amiibo? map, String name) async {
    Database _db = await connectionFactory.database;
    final batch = _db.batch();
    batch.execute('''INSERT OR REPLACE INTO amiibo
      VALUES(?,?,?,?,?,?,?,?,?,?,?,
      (SELECT wishlist FROM amiibo WHERE key = ?),
      (SELECT owned FROM amiibo WHERE key = ?)
      );
      ''', [
      map!.key,
      map.id,
      map.amiiboSeries,
      map.character,
      map.gameSeries,
      map.name,
      map.au,
      map.eu,
      map.jp,
      map.na,
      map.type,
      map.key,
      map.key
    ]);
    batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> update(Amiibo? map, String name) async {
    Database _db = await connectionFactory.database;
    await _db.transaction((tx) async {
      tx.update(name, map!.toJson(), where: 'key = ?', whereArgs: [map.key]);
    });
  }

  Future<void> updateAll(String name, Map<String, dynamic> map,
      {String? category, String? columnCategory}) async {
    Database _db = await connectionFactory.database;
    await _db.transaction((tx) async {
      tx.update(name, map,
          where: category != null ? '$columnCategory LIKE ?' : null,
          whereArgs: category != null ? [category] : null);
    });
  }

  Future<void> remove({String? name, String? column, String? value}) async {
    Database _db = await connectionFactory.database;
    await _db.transaction((tx) async {
      tx.delete(name!, where: '$column = ?', whereArgs: [value]);
    });
  }
}
