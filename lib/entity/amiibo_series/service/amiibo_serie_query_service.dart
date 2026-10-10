import 'package:amiibo_network/app/configuration/model/sort_enum.dart';

abstract interface class AmiiboSerieQueryService {
  Future<List<String>> figures({String? filter, SortBy sort});

  Future<List<String>> cards({String? filter, SortBy sort});
}
