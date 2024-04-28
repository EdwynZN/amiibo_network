import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

@freezed
class Query with _$Query {
  const Query._();

  const factory Query.search({
    @Default(CategoryAttributes(category: AmiiboCategory.All)) CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    @Default(OrderBy.NA) OrderBy orderBy,
    @Default(SortBy.DESC) SortBy sortBy,
  }) = Search;

}

@freezed
class CategoryAttributes with _$CategoryAttributes {

  const factory CategoryAttributes({
    @Default([]) List<String> figures,
    @Default([]) List<String> cards,
    required AmiiboCategory category,
  }) = _CategoryAttributes;

}

@freezed
class SearchAttributes with _$SearchAttributes {

  const factory SearchAttributes({
    required String search,
    required SearchCategory category,
  }) = _SearchAttributes;

}

@freezed
class Filter with _$Filter {

  const factory Filter({
    @Default(CategoryAttributes(category: AmiiboCategory.All)) CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    @Default(OrderBy.NA) OrderBy orderBy,
    @Default(SortBy.DESC) SortBy sortBy,
    HiddenType? hiddenType,
  }) = _Filter;

}
