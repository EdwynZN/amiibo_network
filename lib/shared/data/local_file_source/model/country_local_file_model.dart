import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_local_file_model.freezed.dart';
part 'country_local_file_model.g.dart';

List<CountryLocalFileModel> fileCountryToModel(List<Map<String, dynamic>> list) =>
  list.map(CountryLocalFileModel.fromJson).toList();


@freezed
abstract class CountryLocalFileModel with _$CountryLocalFileModel {
  const factory CountryLocalFileModel({
    required String countryCode,
    required String amazonLink,
    required CountryTranslateFileModel translation, 
  }) = _CountryLocalFileModel;
	
  factory CountryLocalFileModel.fromJson(Map<String, dynamic> json) =>
			_$CountryLocalFileModelFromJson(json);
}

@freezed
abstract class CountryTranslateFileModel with _$CountryTranslateFileModel {
  const factory CountryTranslateFileModel({
      required String en,
      required String es,
      required String fr,
  }) = _CountryTranslateFileModel;
	
  factory CountryTranslateFileModel.fromJson(Map<String, dynamic> json) =>
			_$CountryTranslateFileModelFromJson(json);
}
