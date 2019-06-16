import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheManager extends BaseCacheManager {
  static const key = 'amiiboCachedImage';
  static const maxAgeCacheObject = const Duration(days: 180);
  static const maxNrOfCacheObjects = 1000;

  static final CacheManager _instance = CacheManager._();
  factory CacheManager() => _instance;

  CacheManager._() : super(key, maxAgeCacheObject: maxAgeCacheObject,
      maxNrOfCacheObjects: maxNrOfCacheObjects);

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}