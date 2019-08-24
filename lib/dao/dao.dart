abstract class Dao<T, K, V> {
  Future<T> fetchAll(String orderBy);

  Future<T> fetchByColumn(String column, String name, String orderBy);

  Future<V> fetchByKey(K key);

  Future<void> insertAll(T list, String name);

  Future<void> insert(V map, String name);

  Future<void> update(V map, String name);

  Future<void> updateAll(String name, Map<String,dynamic> map, {String category, String columnCategory});

  Future<void> remove({String name, String column, String value});
}