import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:amiibo_network/entity/amiibo_series/service/amiibo_serie_query_service.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/amiibo_dao.dart';

class const DriftAmiiboSerieQueryService(final AmiiboDao _dao)
    implements AmiiboSerieQueryService {
  @override
  Future<List<String>> cards({String? filter, SortBy sort = .ASC}) {
    return _dao.fetchDistincts(
      categoryAttributes: const CategoryAttributes(category: .Figures),
      hiddenCategories: null,
      orderBy: .AmiiboSerie,
      sortBy: sort,
      searchAttributes: filter == null
          ? null
          : .new(search: filter, category: .AmiiboSeries),
    );
  }

  @override
  Future<List<String>> figures({String? filter, SortBy sort = .ASC}) {
    return _dao.fetchDistincts(
      categoryAttributes: const CategoryAttributes(category: .Cards),
      hiddenCategories: null,
      orderBy: .AmiiboSerie,
      sortBy: sort,
      searchAttributes: filter == null
          ? null
          : .new(search: filter, category: .AmiiboSeries),
    );
  }
}
