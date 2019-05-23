import '../dao.dart';
import '../../model/amiibo_local_db.dart';
import '../../data/database.dart';
import 'package:jaguar_query_sqflite/jaguar_query_sqflite.dart';

class AmiiboImplement implements Dao<AmiiboLocalDB, String, AmiiboDB>{
  static ConnectionFactory connection = ConnectionFactory();

  Future<void> createTables() async{
    SqfliteAdapter _adapter = await connection.adapter;
    final Create tableAmiibo = Create("amiibo", ifNotExists: true)
      .addPrimaryStr('id')
      .addStr('amiiboSeries')
      .addStr('character')
      .addStr('gameSeries', length: 30)
      .addStr('name')
      .addStr('au', isNullable: true)
      .addStr('eu', isNullable: true)
      .addStr('jp', isNullable: true)
      .addStr('na', isNullable: true)
      .addStr('type')
      .addInt('wishlist', isNullable: true)
      .addInt('owned', isNullable: true)
      .addInt('brandNew', isNullable: true);
    await _adapter.createTable(tableAmiibo);

    final Create tableDate = Create("date", ifNotExists: true)
      .addStr('lastUpdated', length: 35)
      .addPrimaryInt("id");
    await _adapter.createTable(tableDate);

    //await connection.close();
  }

  Future<AmiiboLocalDB> fetchAll() async{
    SqfliteAdapter _adapter = await connection.adapter;
    final fetchAll = Find("amiibo").selAll().orderByMany(['jp', 'name']);
    final AmiiboLocalDB allAmiibos = entityFromList(await _adapter.find(fetchAll));
    //await connection.close();
    return allAmiibos;
  }

  Future<List<String>> fetchDistinct(String name, String column) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final List<Map> allAmiibos = await _adapter.connection.rawQuery('SELECT DISTINCT $column FROM $name ORDER BY $column' );
    final List<String> list = List<String>.from(allAmiibos.map((x) => x['amiiboSeries']));
    //await connection.close();
    return list;
  }

  Future<List<String>> fetchLimit(String name, int limit) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final fetchAll = Find("amiibo").sel('name').like('character',name).or(like('name',name)).limit(limit);
    final allAmiibos = await _adapter.find(fetchAll);
    final List<String> list = List<String>.from(allAmiibos.map((x) => x['name']));
    //await connection.close();
    return list;
  }

  Future<LastUpdateDB> lastUpdate() async{
    SqfliteAdapter _adapter = await connection.adapter;
    final fetch = Find("date").sel("lastUpdated").eq("id", 1);
    final date = await _adapter.findOne(fetch);
    final LastUpdateDB dateBackup = date == null ? null : LastUpdateDB.fromMap(date);
    //await connection.close();
    return dateBackup;
  }

  Future<void> updateTime(LastUpdateDB map) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final insertMap = Upsert("date").setValues(map.toMap()).setValues({"id":1});
    await _adapter.upsert(insertMap);
    //await connection.close();
  }

  Future<AmiiboLocalDB> fetchByColumn(String column, String name) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final fetchAll = Find("amiibo").selAll().like(column, name);
    final AmiiboLocalDB allAmiibos = entityFromList(await _adapter.find(fetchAll));
    //await connection.close();
    return allAmiibos;
  }

  Future<AmiiboDB> fetchById(String id) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final fetch = Find("amiibo").selAll().where(eq("id", id));
    final AmiiboDB amiibo = AmiiboDB.fromDB(await _adapter.findOne(fetch));
    //await connection.close();
    return amiibo;
  }

  Future<AmiiboLocalDB> findNew() async{
    SqfliteAdapter _adapter = await connection.adapter;
    final List<Map> allAmiibos = await _adapter.connection.rawQuery('SELECT * FROM amiibo WHERE brandNew IS NULL ORDER BY jp DESC, name DESC' );
    final AmiiboLocalDB amiibos = entityFromList(allAmiibos);
    //await connection.close();
    return amiibos;
  }

  Future<void> insertAll(AmiiboLocalDB list, String name) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final insertList = UpsertMany(name).addAllMap(entityToListOfMaps(list));
    await _adapter.upsertMany(insertList);
    //await connection.close();
  }

  Future<void> insert(AmiiboDB map, String name) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final insertMap = Upsert(name).setValues(map.toMap());
    await _adapter.upsert(insertMap);
    //await connection.close();
  }

  Future<void> update(AmiiboDB map, String name) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final updateMap = Update(name).setValues(map.toMap()).where(eq('id', map.id));
    await _adapter.update(updateMap);
    //await connection.close();
  }

  Future<void> updateAll(String name, String column,
      String value, {String category, String columnCategory}) async{
        SqfliteAdapter _adapter = await connection.adapter;
        final updateMap = Update(name).setValue(column, value);
        if(category != null) updateMap.like(columnCategory, category);
        await _adapter.update(updateMap);
        //await connection.close();
  }

  Future<void> remove({String name, String column, String value}) async{
    SqfliteAdapter _adapter = await connection.adapter;
    final deleteRecord = Remove(name).eq(column, value);
    await _adapter.remove(deleteRecord);
    //await connection.close();
  }
}