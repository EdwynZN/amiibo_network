import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_bundle_local_json_model.freezed.dart';
part 'amiibo_bundle_local_json_model.g.dart';

List<AmiiboBundleLocalFile> entityFromMapToDomain(
  Map<String, dynamic> amiibo,
) => (amiibo["bundles"] as List)
    .map((x) => AmiiboBundleLocalFile.fromJson(x as Map<String, dynamic>))
    .toList();

@Freezed(toJson: false)
abstract class AmiiboBundleLocalFile with _$AmiiboBundleLocalFile {
  factory AmiiboBundleLocalFile({
    required int id,
    @JsonKey(required: true) required String name,
    @JsonKey(required: true)
    required List<AmiiboBundleRelationLocalFile> amiibos,
  }) = _AmiiboBundleLocalFile;

  factory AmiiboBundleLocalFile.fromJson(Map<String, dynamic> json) =>
      _$AmiiboBundleLocalFileFromJson(json);
}

@Freezed(toJson: false)
abstract class AmiiboBundleRelationLocalFile
    with _$AmiiboBundleRelationLocalFile {
  factory AmiiboBundleRelationLocalFile({
    @JsonKey(required: true, name: 'amiibo_key') required int amiiboId,
    @JsonKey(required: true) required int quantity,
  }) = _AmiiboBundleRelationLocalFile;

  factory AmiiboBundleRelationLocalFile.fromJson(Map<String, dynamic> json) =>
      _$AmiiboBundleRelationLocalFileFromJson(json);
}
