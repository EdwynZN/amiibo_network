import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_collection_drift_dto.freezed.dart';
part 'amiibo_collection_drift_dto.g.dart';

int boolToInt(bool? value) => value ?? false ? 1 : 0;
bool intToBool(int? value) => value == 1;

@freezed
abstract class AmiiboCollectionDriftDto with _$AmiiboCollectionDriftDto {
  const factory ({
    @JsonKey(required: true, name: 'amiibo.key') required int key,
    @JsonKey(name: 'amiibo.amiiboSeries', required: true)
    required String amiiboSeries,
    @JsonKey(name: 'amiibo.character', required: true)
    required String character,
    @JsonKey(name: 'amiibo.gameSeries', required: true)
    required String gameSeries,
    @JsonKey(name: 'amiibo.name', required: true) required String name,
    @JsonKey(includeIfNull: true, name: 's.amiibo_images.file_path')
    String? image,
    @JsonKey(includeIfNull: true, name: 'amiibo.au') String? au,
    @JsonKey(includeIfNull: true, name: 'amiibo.eu') String? eu,
    @JsonKey(includeIfNull: true, name: 'amiibo.jp') String? jp,
    @JsonKey(includeIfNull: true, name: 'amiibo.na') String? na,
    @JsonKey(required: true, name: 'amiibo.type') required String type,
    @JsonKey(name: 'amiibo.cardNumber') int? cardNumber,
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.boxed') int boxed,
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.opened') int opened,
    @Default(false)
    @JsonKey(
      fromJson: intToBool,
      toJson: boolToInt,
      name: 'amiibo_user_preferences.wishlist',
    )
    bool wishlist,
  }) = _AmiiboCollectionDriftDto;

  factory fromJson(Map<String, dynamic> json) =>
      _$AmiiboCollectionDriftDtoFromJson(json);
}

@freezed
abstract class AmiiboCollectionDetailDriftDto with _$AmiiboCollectionDetailDriftDto {
  const factory ({
    @JsonKey(required: true, name: 'amiibo.key') required int key,
    @JsonKey(name: 'amiibo.amiiboSeries', required: true)
    required String amiiboSeries,
    @JsonKey(name: 'amiibo.character', required: true)
    required String character,
    @JsonKey(name: 'amiibo.gameSeries', required: true)
    required String gameSeries,
    @JsonKey(name: 'amiibo.name', required: true) required String name,
    @JsonKey(includeIfNull: true, name: 'amiibo_images.file_path')
    @Default(const []) List<String> images,
    @Default(const []) List<AmiiboBundleDriftModel> bundles,
    @JsonKey(includeIfNull: true, name: 'amiibo.au') String? au,
    @JsonKey(includeIfNull: true, name: 'amiibo.eu') String? eu,
    @JsonKey(includeIfNull: true, name: 'amiibo.jp') String? jp,
    @JsonKey(includeIfNull: true, name: 'amiibo.na') String? na,
    @JsonKey(required: true, name: 'amiibo.type') required String type,
    @JsonKey(name: 'amiibo.cardNumber') int? cardNumber,

    @Default(0) @JsonKey(name: 'amiibo_user_preferences.boxed') int boxed,
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.opened') int opened,
    @Default(false)
    @JsonKey(
      fromJson: intToBool,
      toJson: boolToInt,
      name: 'amiibo_user_preferences.wishlist',
    )
    bool wishlist,
  }) = _AmiiboCollectionDetailDriftDto;

  factory fromJson(Map<String, dynamic> json) =>
      _$AmiiboCollectionDetailDriftDtoFromJson(json);
}

@freezed
abstract class AmiiboBundleDriftModel with _$AmiiboBundleDriftModel {
  const AmiiboBundleDriftModel._();

  const factory AmiiboBundleDriftModel({
    @JsonKey(name: 'amiibo.id', required: true) required String id,
    @JsonKey(name: 'amiibo.name', required: true) required String name,
    @JsonKey(name: 'amiibo_images.file_path')
    @Default(const []) List<String> images,
    @JsonKey(name: 'amiibo.au', required: true) required List<String> amiiboIds,
  
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.boxed') int boxed,
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.opened') int opened,
    @Default(false)
    @JsonKey(
      fromJson: intToBool,
      toJson: boolToInt,
      name: 'amiibo_user_preferences.wishlist',
    )
    bool wishlist,
  }) = _AmiiboBundleDriftModel;

  factory fromJson(Map<String, dynamic> json) =>
      _$AmiiboBundleDriftModelFromJson(json);
}
