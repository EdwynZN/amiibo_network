import 'package:amiibo_network/enum/amiibo_category_enum.dart';
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
    List<String>? customFigures,
    List<String>? customCards,
  }) = Search;

  @With<_OrderBy>()
  factory Query.builder({
    required Expression where,
    @Default(OrderBy.NA) OrderBy orderBy,
    @Default(SortBy.DESC) SortBy sortBy,
  }) = QueryBuilder;
}

mixin _OrderBy {
  late final OrderBy orderBy;
  late final SortBy sortBy;

  String get order {
    final String order = describeEnum(orderBy);
    StringBuffer orderBuffer = StringBuffer();
    final String sort = describeEnum(sortBy);
    switch (orderBy) {
      case OrderBy.NA:
      case OrderBy.JP:
      case OrderBy.AU:
      case OrderBy.EU:
      case OrderBy.CardNumber:
        orderBuffer.write('$order IS NULL, $order $sort');
        break;
      case OrderBy.Owned:
      case OrderBy.Wishlist:
        final bool asc = sortBy == SortBy.ASC;
        final int _then = asc ? 1 : 0;
        final int _else = asc ? 0 : 1;
        orderBuffer.write(
          'CASE WHEN ($order IS NULL OR $order = 0) THEN $_then ELSE $_else END, key $sort');
        break;
      default:
        orderBuffer.write('$order $sort');
        break;
    }
    return orderBuffer.toString();
  }
}
