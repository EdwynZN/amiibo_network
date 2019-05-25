import '../dao.dart';
import '../../model/amiibo_local_db.dart';
import '../../data/database.dart';
import 'package:sqflite/sqflite.dart';

class AmiiboSQLite implements Dao<AmiiboLocalDB, String, AmiiboDB>{
  static ConnectionFactory connectionFactory = ConnectionFactory();

  Future<AmiiboLocalDB> fetchAll() async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query('amiibo',
      orderBy: 'type DESC, jp DESC, name');
    return entityFromList(maps);
  }

  Future<List<String>> fetchDistinct(String name, String column) async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query(name, distinct: true,
      columns: [column],
      orderBy: column);
    return List<String>.from(maps.map((x) => x['amiiboSeries']));
  }

  Future<List<String>> fetchLimit(String name, int limit) async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query('amiibo', distinct: true,
      columns: ['name'],
      where: 'character LIKE ? OR name LIKE ?',
      whereArgs: [name, name],
      limit: limit);
    return List<String>.from(maps.map((x) => x['name']));
  }

  Future<LastUpdateDB> lastUpdate() async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query('date',
      columns: ['lastUpdated'],
      where: 'id = 1');
    if (maps.length > 0) {
      return LastUpdateDB.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateTime(LastUpdateDB map) async{
    Database _adapter = await connectionFactory.database;
    return await _adapter.transaction((tx) async{
      tx.rawInsert('''REPLACE INTO date
        VALUES(1, ?)''', [map?.lastUpdated?.toIso8601String()]);
    });
  }

  Future<AmiiboLocalDB> fetchByColumn(String column, String name) async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query('amiibo',
      where: '$column LIKE ?',
      whereArgs: [name],
      orderBy: 'jp DESC, name DESC');
    return entityFromList(maps);
  }

  Future<AmiiboDB> fetchById(String id) async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query('amiibo',
      where: 'id = ?',
      whereArgs: [id]);
    if(maps.length > 0) return AmiiboDB.fromDB(maps.first);
    return null;
  }

  Future<AmiiboLocalDB> findNew() async{
    Database _adapter = await connectionFactory.database;
    List<Map> maps = await _adapter.query('amiibo',
      where: 'brandNew = 0 OR brandNew IS NULL',
      orderBy: 'jp DESC, name DESC');
    return entityFromList(maps);
  }

  Future<void> insertAll(AmiiboLocalDB list, String name) async{
    Database _adapter = await connectionFactory.database;
    final batch = _adapter.batch();
    for (var query in list.amiibo) {
      batch.execute('''INSERT OR REPLACE INTO amiibo
      VALUES(?,?,?,?,?,?,?,?,?,?,
      (SELECT wishlist FROM amiibo WHERE id = ?),
      (SELECT owned FROM amiibo WHERE id = ?),
      (SELECT brandNew FROM amiibo WHERE id = ?)
      );
      ''',
      [query.id,query.amiiboSeries,query.character,query.gameSeries,
      query.name,query.au,query.eu,query.jp,query.na,query.type,
      query.id,query.id,query.id,]);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> insert(AmiiboDB map, String name) async{
    Database _adapter = await connectionFactory.database;
    final batch = _adapter.batch();
    batch.execute('''INSERT OR REPLACE INTO amiibo
      VALUES(?,?,?,?,?,?,?,?,?,?,
      (SELECT wishlist FROM amiibo WHERE id = ?),
      (SELECT owned FROM amiibo WHERE id = ?),
      (SELECT brandNew FROM amiibo WHERE id = ?)
      );
      ''',
      [map.id,map.amiiboSeries,map.character,map.gameSeries,
      map.name,map.au,map.eu,map.jp,map.na,map.type,
      map.id,map.id,map.id,]);
    batch.commit(noResult: true, continueOnError: true);
  }

  Future<void> update(AmiiboDB map, String name) async{
    Database _adapter = await connectionFactory.database;
    await _adapter.transaction((tx) async{
      tx.update(name, map.toMap(),
        where: 'id = ?',
        whereArgs: [map.id]);
    });
  }

  Future<void> updateAll(String name, String column,
    String value, {String category, String columnCategory}) async{
      Database _adapter = await connectionFactory.database;
      await _adapter.transaction((tx) async {
        tx.update(name, {column : value},
          where: category != null ? '$columnCategory LIKE ?' : null,
          whereArgs: category != null ? [category] : null);
      });
  }

  Future<void> remove({String name, String column, String value}) async{
    Database _adapter = await connectionFactory.database;
    await _adapter.transaction((tx) async{
      tx.delete(name,
        where: '$column = ?',
        whereArgs: [value]);
    });
  }
}