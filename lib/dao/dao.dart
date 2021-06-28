abstract class Dao<T, K> {
  Future<List<T>> fetchAll(String orderBy);

  Future<List<T>> fetchByColumn(String column, List<String> args, String orderBy);

  Future<T> fetchByKey(K key);

  Future<void> insertAll(List<T> list, String name);

  Future<void> insert(T map, String name);

  Future<void> update(T map, String name);

  Future<void> updateAll(String name, Map<String,dynamic> map, {String? category, String? columnCategory});

  Future<void> remove({String? name, String? column, String? value});
}