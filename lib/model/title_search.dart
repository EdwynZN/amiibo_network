import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_search.freezed.dart';

@freezed
sealed class TitleSearch with _$TitleSearch {
  const factory TitleSearch({
    required String title,
    required AmiiboCategory category,
  }) = TitleCategory;

  const factory TitleSearch.count({
    required String title,
    required AmiiboCategory category,
  }) = TitleCount;

  const factory TitleSearch.search({
    required String title,
    required AmiiboCategory category,
    required SearchCategory searchCategory,
  }) = TitleSearchCategory;
	
}
