import 'package:amiibo_network/utils/amiibo_category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';

part 'expression.dart';
part 'search_result.freezed.dart';

@freezed
abstract class Query with _$Query {
  const Query._();

  const factory Query.search({
    String search,
    @Default(AmiiboCategory.Name) AmiiboCategory category,
    List<String> customFigures,
    List<String> customCards,
  }) = Search;

  @With(_OrderBy)
  factory Query.builder({
    Expression where,
    String orderBy,
    String sortBy,
  }) = QueryBuilder;
}

mixin _OrderBy{
  String orderBy;
  String sortBy;

  String get order {
    if (this.orderBy == null) return null;
    StringBuffer orderBy = StringBuffer(this.orderBy);
    if (sortBy?.isNotEmpty ?? false) orderBy..write(' ')..write(sortBy);
    return orderBy.toString();
  }
}
