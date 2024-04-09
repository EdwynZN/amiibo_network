import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/enum/sort_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';

part 'expression.dart';
part 'search_result.freezed.dart';

@freezed
class Query with _$Query {
  const Query._();

  const factory Query.search({
    String? search,
    required AmiiboCategory category,
    @Default(OrderBy.NA) OrderBy orderBy,
    @Default(SortBy.DESC) SortBy sortBy,
    @Default([]) List<String> customFigures,
    @Default([]) List<String> customCards,
  }) = Search;

}

@freezed
class Filter with _$Filter {

  const factory Filter({
    String? search,
    required AmiiboCategory category,
    @Default(OrderBy.NA) OrderBy orderBy,
    @Default(SortBy.DESC) SortBy sortBy,
    @Default([]) List<String> customFigures,
    @Default([]) List<String> customCards,
    HiddenType? hiddenType,
  }) = _Filter;

}
