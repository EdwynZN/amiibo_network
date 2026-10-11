import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/entity/amiibo_series/service/amiibo_serie_query_service.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';

class const DriftAmiiboSerieQueryService(final AmiiboDao _dao)
    implements AmiiboSerieQueryService {

  @override
  Future<List<String>> category({required AmiiboCategory category}) {
    return _dao.fetchDistincts(
      categoryAttributes: CategoryAttributes(category: category),
      hiddenCategories: null,
      orderBy: .AmiiboSerie,
      sortBy: .ASC,
      searchAttributes: null,
    );
  }
}
