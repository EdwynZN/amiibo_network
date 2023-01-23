import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_search.freezed.dart';

enum TitleType { count, search, category }

@freezed
class TitleSearch with _$TitleSearch {
  const factory TitleSearch({
    required String title,
    required TitleType type,
    AmiiboCategory? category,
  }) = _TitleSearch;
	
}
