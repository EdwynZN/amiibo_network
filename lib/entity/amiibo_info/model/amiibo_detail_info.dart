import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_detail_info.freezed.dart';

@freezed
class const AmiiboDetailInfo({
  required final int id,
  required final AmiiboMetadata details,
  required final List<AmiiboBundleMetadata> bundles,
}) with _$AmiiboDetailInfo;

@freezed
class const AmiiboBundleMetadata({
  required final String id,
  required final String name,
  required final List<String> amiiboIds,
  required final UserAttributes userAttributes,
  final List<String> images = const [],
}) with _$AmiiboBundleMetadata;

@freezed
class const AmiiboMetadata({
  required final String? nfcId,
  required final String amiiboSeries,
  required final String character,
  required final String gameSeries,
  required final String name,
  required final UserAttributes userAttributes,
  final List<String> images = const [],
  final String? au,
  final String? eu,
  final String? jp,
  final String? na,
  required final String type,
  required final int? cardNumber,
}) with _$AmiiboMetadata;

@freezed
sealed class UserCollectionAttributes with _$UserCollectionAttributes {
  const factory none() = EmptyUserCollectionAttributes;
  const factory wished() = WishedUserCollectionAttributes;
  const factory owned({@Default(0) int boxed, @Default(1) int opened}) =
      OwnedUserCollectionAttributes;
}
