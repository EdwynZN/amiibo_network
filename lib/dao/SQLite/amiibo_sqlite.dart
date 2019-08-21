import '../dao.dart';
import '../../model/amiibo_local_db.dart';
import '../../data/database.dart';
import 'package:sqflite/sqflite.dart';

class AmiiboSQLite implements Dao<AmiiboLocalDB, String, AmiiboDB>{
  static ConnectionFactory connectionFactory = ConnectionFactory();

  Future<AmiiboLocalDB> fetchAll() async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('amiibo',
      orderBy: 'CASE WHEN type = "Figure" THEN 1 '
        'WHEN type = "Yarn" THEN 2 ELSE 3 END, na DESC');
    return entityFromList(maps);
  }//type DESC, na DESC, name

  Future<List<String>> fetchDistinct(String name, String column, String condition) async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query(name, distinct: true,
      columns: [column],
      where: 'type $condition ?',
      whereArgs: ["Card"],
      orderBy: column);
    return List<String>.from(maps.map((x) => x['amiiboSeries']));
  }

  Future<List<String>> fetchLimit(String name, int limit) async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('amiibo', distinct: true,
      columns: ['name'],
      where: 'character LIKE ? OR name LIKE ?',
      whereArgs: [name, name],
      limit: limit);
    return List<String>.from(maps.map((x) => x['name']));
  }

  Future<LastUpdateDB> lastUpdate() async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('date',
      columns: ['lastUpdated'],
      where: 'id = 1');
    if (maps.length > 0) return LastUpdateDB.fromMap(maps.first);
    return null;
  }

  Future<String> favoriteTheme() async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('date',
      columns: ['lastUpdated'],
      where: 'id = 2');
    if (maps.length > 0) return maps.first['lastUpdated'].toString();
    return 'Auto';
  }

  Future<void> updateTheme(String theme) async{
    Database _db = await connectionFactory.database;
    return await _db.transaction((tx) async{
      tx.rawInsert('''REPLACE INTO date
        VALUES(2, ?)''', [theme]);
    });
  }

  Future<void> updateTime(LastUpdateDB map) async{
    Database _db = await connectionFactory.database;
    return await _db.transaction((tx) async{
      tx.rawInsert('''REPLACE INTO date
        VALUES(1, ?)''', [map?.lastUpdated?.toIso8601String()]);
    });
  }

  Future<AmiiboLocalDB> fetchByColumn(String column, String name) async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('amiibo',
      where: '$column LIKE ?',
      whereArgs: [name],
      orderBy: 'na DESC');
    return entityFromList(maps);
  }

  Future<List<Map<String, dynamic>>> fetchSum(String column, String name,
    bool all, bool group) async{
    Database _db = await connectionFactory.database;
    List<Map<String,dynamic>> result = await _db.query('amiibo',
        columns: [
          if(group) 'amiiboSeries',
          'count(1) AS Total',
          'count(case WHEN wishlist=1 then 1 end) AS Wished',
          'count(case WHEN owned=1 then 1 end) AS Owned'
        ],
        where: all ? null : '$column LIKE ?',
        whereArgs: all ? null : [name],
        groupBy: group ? 'amiiboSeries' : null
    );
    return result;
  }

  Future<AmiiboDB> fetchByKey(String key) async{
    Database _db = await connectionFactory.database;
    List<Map<String, dynamic>> maps = await _db.query('amiibo',
      where: 'key = ?',
      whereArgs: [key]);
    if(maps.length > 0) return AmiiboDB.fromMap(maps.first);
    return null;
  }

  Future<void> insertAll(AmiiboLocalDB list, String name) async{
    Database _db = await connectionFactory.database;
    final batch = _db.batch();
    for (var query in list.amiibo) {
      batch.execute('''INSERT OR REPLACE INTO amiibo
      VALUES(?,?,?,?,?,?,?,?,?,?,?,
      (SELECT wishlist FROM amiibo WHERE key = ?),
      (SELECT owned FROM amiibo WHERE key = ?)
      );
      ''',
      [query.key,query.id,query.amiiboSeries,query.character,query.gameSeries,
      query.name,query.au,query.eu,query.jp,query.na,query.type,
      query.key,query.key]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> insertImport(AmiiboLocalDB list) async{
    Database _db = await connectionFactory.database;
    final batch = _db.batch();
    for (var query in list.amiibo) {
      batch.execute('''UPDATE amiibo
        SET wishlist = ?, owned = ?
        WHERE ${query.key != null ? 'key' : 'id'} = ?;
      ''',
      [query.wishlist, query.owned, query.key ?? query.id]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> insert(AmiiboDB map, String name) async{
    Database _db = await connectionFactory.database;
    final batch = _db.batch();
    batch.execute('''INSERT OR REPLACE INTO amiibo
      VALUES(?,?,?,?,?,?,?,?,?,?,?,
      (SELECT wishlist FROM amiibo WHERE key = ?),
      (SELECT owned FROM amiibo WHERE key = ?)
      );
      ''',
      [map.key,map.id,map.amiiboSeries,map.character,map.gameSeries,
      map.name,map.au,map.eu,map.jp,map.na,map.type,
      map.key,map.key]);
    batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> update(AmiiboDB map, String name) async{
    Database _db = await connectionFactory.database;
    await _db.transaction((tx) async{
      tx.update(name, map.toMap(),
        where: 'key = ?',
        whereArgs: [map.key]);
    });
  }

  Future<void> updateAll(String name, Map<String,dynamic> map,
      {String category, String columnCategory}) async{
      Database _db = await connectionFactory.database;
      await _db.transaction((tx) async {
        tx.update(name, map,
          where: category != null ? '$columnCategory LIKE ?' : null,
          whereArgs: category != null ? [category] : null);
      });
  }

  Future<void> remove({String name, String column, String value}) async{
    Database _db = await connectionFactory.database;
    await _db.transaction((tx) async{
      tx.delete(name,
        where: '$column = ?',
        whereArgs: [value]);
    });
  }
}