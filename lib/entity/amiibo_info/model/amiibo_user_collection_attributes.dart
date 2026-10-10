import 'package:freezed_annotation/freezed_annotation.dart';

part 'amiibo_user_collection_attributes.freezed.dart';
part 'amiibo_user_collection_attributes.g.dart';

@freezed
sealed class UserAttributes with _$UserAttributes {
  const factory none() = EmptyUserAttributes;

  const factory wished() = WishedUserAttributes;

  @Assert('(boxed > 0) || (opened > 0)', 'boxed or opened cannot be both less than 0')
  const factory owned({
    @Default(0) int boxed,
    @Default(1) int opened,
  }) = OwnedUserAttributes;

  factory fromOwnedOrEmpty({
    required int boxed,
    required int opened,
  }) => boxed + opened <= 0
    ? const EmptyUserAttributes()
    : OwnedUserAttributes(boxed: boxed, opened: opened);

  factory fromJson(Map<String, dynamic> json) =>
      _$UserAttributesFromJson(json);
}
