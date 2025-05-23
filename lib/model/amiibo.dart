import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo.freezed.dart';
part 'amiibo.g.dart';

int boolToInt(bool? value) => value ?? false ? 1 : 0;
bool intToBool(int? value) => value == 1;

List<Amiibo> entityFromMap(Map<String, dynamic> amiibo) =>
    List<Amiibo>.from(amiibo["amiibo"].map((x) => Amiibo.fromJson(x)));

@freezed
abstract class Amiibo with _$Amiibo {

  const factory Amiibo({
    required int key,
    required final AmiiboDetails details,
    /* @Default(false)
    @JsonKey(fromJson: intToBool, toJson: boolToInt)
    bool wishlist, */
    //@Default(false) @JsonKey(fromJson: intToBool, toJson: boolToInt) bool owned,
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

@freezed
sealed class UserAttributes with _$UserAttributes {
  const factory UserAttributes.none() = EmptyUserAttributes;

  const factory UserAttributes.wished() = WishedUserAttributes;

  @Assert('(boxed > 0) || (opened > 0)', 'boxed or opened cannot be both less than 0')
  const factory UserAttributes.owned({
    @Default(0) final int boxed,
    @Default(1) final int opened,
  }) = OwnedUserAttributes;

  factory UserAttributes.fromOwnedOrEmpty({
    required final int boxed,
    required final int opened,
  }) => boxed + opened <= 0
    ? const EmptyUserAttributes()
    : OwnedUserAttributes(boxed: boxed, opened: opened);

  factory UserAttributes.fromJson(Map<String, dynamic> json) =>
      _$UserAttributesFromJson(json);
}
