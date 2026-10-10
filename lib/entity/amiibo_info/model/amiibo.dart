import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo.freezed.dart';
part 'amiibo.g.dart';

List<Amiibo> entityFromMap(Map<String, dynamic> amiibo) =>
    List<Amiibo>.from(amiibo["amiibo"].map((x) => Amiibo.fromJson(x)));

@freezed
abstract class Amiibo with _$Amiibo {

  const factory Amiibo({
    required int key,
    required AmiiboDetails details,
    @Default(UserAttributes.none()) UserAttributes userAttributes,
  }) = _Amiibo;

  factory Amiibo.fromJson(Map<String, dynamic> json) => _$AmiiboFromJson(json);
}

@freezed
abstract class AmiiboDetails with _$AmiiboDetails {
  const factory AmiiboDetails({
    @JsonKey(includeIfNull: true) String? id,
    @JsonKey(required: true) required String amiiboSeries,
    @JsonKey(required: true) required String character,
    @JsonKey(required: true) required String gameSeries,
    @JsonKey(required: true) required String name,
    @JsonKey(includeIfNull: true) String? image,
    @JsonKey(includeIfNull: true) String? au,
    @JsonKey(includeIfNull: true) String? eu,
    @JsonKey(includeIfNull: true) String? jp,
    @JsonKey(includeIfNull: true) String? na,
    @JsonKey(required: true) required String type,
    int? cardNumber,
  }) = _AmiiboDetails;

  factory AmiiboDetails.fromJson(Map<String, dynamic> json) =>
      _$AmiiboDetailsFromJson(json);
}
