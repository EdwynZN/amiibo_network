import 'package:amiibo_network/model/amiibo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_sqlite_model.freezed.dart';
part 'amiibo_sqlite_model.g.dart';

int boolToInt(bool? value) => value ?? false ? 1 : 0;
bool intToBool(int? value) => value == 1;

List<AmiiboSqlite> entityFromMap(Map<String, dynamic> amiibo) =>
    List<AmiiboSqlite>.from(
        amiibo["amiibo"].map((x) => AmiiboSqlite.fromJson(x)));

List<Amiibo> entityFromMapToDomain(Map<String, dynamic> amiibo) =>
    List<Amiibo>.from(
        amiibo["amiibo"].map((x) => AmiiboSqlite.fromJson(x).toDomain()));

@freezed
class AmiiboSqlite with _$AmiiboSqlite {
  const AmiiboSqlite._();

  const factory AmiiboSqlite({
    required int key,
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
    @Default(0) final int boxed,
    @Default(0) final int opened,
    @Default(false)
    @JsonKey(fromJson: intToBool, toJson: boolToInt)
    bool wishlist,
  }) = _AmiiboSqlite;

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

  factory AmiiboSqlite.fromJson(Map<String, dynamic> json) =>
      _$AmiiboSqliteFromJson(json);
}
