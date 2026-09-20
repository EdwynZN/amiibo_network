import 'package:amiibo_network/app/configuration/model/amiibo_category_enum.dart';
import 'package:amiibo_network/app/configuration/model/hidden_types.dart';
import 'package:amiibo_network/app/configuration/model/sort_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result.freezed.dart';

@freezed
abstract class Search with _$Search {
  const factory Search({
    @Default(CategoryAttributes(category: AmiiboCategory.All))
    CategoryAttributes categoryAttributes,
    SearchAttributes? searchAttributes,
    @Default(OrderBy.NA) OrderBy orderBy,
    @Default(SortBy.DESC) SortBy sortBy,
  }) = _Search;
}

@freezed
class CategoryAttributes with _$CategoryAttributes {
  const CategoryAttributes({
    required this.category,
    this.figures = const [],
    this.cards = const [],
  });

  final List<String> figures;
  final List<String> cards;
  final AmiiboCategory category;
}

@freezed
class SearchAttributes with _$SearchAttributes {
  const SearchAttributes({required this.search, required this.category});

  final String search;
  final SearchCategory category;
}

@freezed
class Filter with _$Filter {
  const Filter({
    this.categoryAttributes = const CategoryAttributes(category: .All),
    this.searchAttributes,
    this.orderBy = .NA,
    this.sortBy = .DESC,
    this.hiddenType,
  });

  final CategoryAttributes categoryAttributes;
  final SearchAttributes? searchAttributes;
  final OrderBy orderBy;
  final SortBy sortBy;
  final HiddenType? hiddenType;
}
