abstract class Dao<T, K, V> {
  Future<T> fetchAll();

  Future<T> fetchByColumn(String column, String name);

  Future<V> fetchById(K id);

  Future<void> insertAll(T list, String name);

  Future<void> insert(V map, String name);

  Future<void> update(V map, String name);

  Future<void> updateAll(String name, String column, String value, {String category, String columnCategory});

  Future<void> remove({String name, String column, String value});
}