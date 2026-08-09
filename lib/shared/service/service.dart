import 'package:amiibo_network/app/configuration/model/hidden_types.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
import 'package:amiibo_network/entity/amiibo_info/model/stat.dart';
import 'package:amiibo_network/feature/amiibo/application/input/update_amiibo_user_attributes.dart';

abstract interface class AmiiboService {
  Future<Amiibo?> fetchOne(int key);

  Future<List<Amiibo>> fetchAllAmiibo();

  Future<List<Stat>> fetchStats({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    HiddenType? hiddenCategories,
    bool group = false,
  });

  Future<List<Amiibo>> fetchByCategory({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    List<String> figures = const [],
    List<String> cards = const [],
    HiddenType? hiddenCategories,
  });

  Future<void> update(List<UpdateAmiiboUserAttributes> amiibos);

  Future<List<String>> fetchDistinct({
    required CategoryAttributes categoryAttributes,
    required SearchAttributes? searchAttributes,
    OrderBy orderBy = OrderBy.NA,
    SortBy sortBy = SortBy.DESC,
    HiddenType? hiddenCategories,
  });

  Future<List<String>> search({
    required SearchAttributes searchAttributes,
    HiddenType? hidden,
  });

  Future<void> resetCollection();
}
