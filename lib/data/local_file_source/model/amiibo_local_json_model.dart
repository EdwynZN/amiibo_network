import 'package:amiibo_network/model/amiibo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_local_json_model.freezed.dart';
part 'amiibo_local_json_model.g.dart';

List<Amiibo> entityFromMapToDomain(Map<String, dynamic> amiibo) =>
    List<Amiibo>.from(
        amiibo["amiibo"].map((x) => AmiiboLocalFile.fromJson(x).toDomain()));

@freezed
class AmiiboLocalFile with _$AmiiboLocalFile {
  const AmiiboLocalFile._();

  const factory AmiiboLocalFile({
    required int key,
    @JsonKey(includeIfNull: true) String? id,
    @Default('') String amiiboSeries,
    @Default('') String character,
    @Default('') String gameSeries,
    @Default('') String name,
    @JsonKey(includeIfNull: true) String? au,
    @JsonKey(includeIfNull: true) String? eu,
    @JsonKey(includeIfNull: true) String? jp,
    @JsonKey(includeIfNull: true) String? na,
    @JsonKey(includeIfNull: true) String? type,
    int? cardNumber,
  }) = _AmiiboLocalFile;

  Amiibo toDomain() {
    return Amiibo(
      key: key,
      userAttributes: const UserAttributes.none(),
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

  factory AmiiboLocalFile.fromJson(Map<String, dynamic> json) =>
      _$AmiiboLocalFileFromJson(json);
}
