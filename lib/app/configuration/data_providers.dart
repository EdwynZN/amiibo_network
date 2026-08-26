import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/shared/service/update_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@riverpod
UpdateService updateService(Ref ref) =>
    UpdateService(database: ref.watch(databaseProvider));
