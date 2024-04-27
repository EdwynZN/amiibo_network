import 'package:amiibo_network/model/amiibo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drift_joined_amiibo_preferences.freezed.dart';
part 'drift_joined_amiibo_preferences.g.dart';

int boolToInt(bool? value) => value ?? false ? 1 : 0;
bool intToBool(int? value) => value == 1;

List<AmiiboDriftModel> entityFromMap(Map<String, dynamic> amiibo) =>
    List<AmiiboDriftModel>.from(
        amiibo["amiibo"].map((x) => AmiiboDriftModel.fromJson(x)));

List<Amiibo> entityFromMapToDomain(Map<String, dynamic> amiibo) =>
    List<Amiibo>.from(
        amiibo["amiibo"].map((x) => AmiiboDriftModel.fromJson(x).toDomain()));

@freezed
class AmiiboDriftModel with _$AmiiboDriftModel {
  const AmiiboDriftModel._();

  const factory AmiiboDriftModel({
    @JsonKey(required: true, name: 'amiibo.key') required int key,
    @JsonKey(includeIfNull: true, name: 'amiibo.id') String? id,
    @Default('') @JsonKey(name: 'amiibo.amiiboSeries') String amiiboSeries,
    @Default('') @JsonKey(name: 'amiibo.character') String character,
    @Default('') @JsonKey(name: 'amiibo.gameSeries') String gameSeries,
    @Default('') @JsonKey(name: 'amiibo.name') String name,
    @JsonKey(includeIfNull: true, name: 'amiibo.au') String? au,
    @JsonKey(includeIfNull: true, name: 'amiibo.eu') String? eu,
    @JsonKey(includeIfNull: true, name: 'amiibo.jp') String? jp,
    @JsonKey(includeIfNull: true, name: 'amiibo.na') String? na,
    @JsonKey(includeIfNull: true, name: 'amiibo.type') String? type,
    @JsonKey(name: 'amiibo.cardNumber') int? cardNumber,
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.boxed') final int boxed,
    @Default(0) @JsonKey(name: 'amiibo_user_preferences.opened') final int opened,
    @Default(false)
    @JsonKey(fromJson: intToBool, toJson: boolToInt, name: 'amiibo_user_preferences.wishlist')
    bool wishlist,
  }) = _AmiiboDriftModel;

  Amiibo toDomain() {
    final UserAttributes attributes;
    if (!wishlist && boxed == 0 && opened == 0) {
      attributes = const UserAttributes.none();
    } else if (boxed != 0 || opened != 0) {
      attributes = UserAttributes.owned(opened: opened, boxed: boxed);
    } else {
      attributes = const UserAttributes.wished();
    }
    return Amiibo(
      key: key,
      userAttributes: attributes,
      details: AmiiboDetails(
        id: id,
        name: name,
        character: character,
        gameSeries: gameSeries,
        amiiboSeries: amiiboSeries,
        au: au,
        eu: eu,
        jp: jp,
        na: na,
        type: type,
        cardNumber: cardNumber,
      ),
    );
  }

  factory AmiiboDriftModel.fromJson(Map<String, dynamic> json) =>
      _$AmiiboDriftModelFromJson(json);
}