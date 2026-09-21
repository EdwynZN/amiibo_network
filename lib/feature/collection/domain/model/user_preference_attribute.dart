import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preference_attribute.freezed.dart';

@freezed
sealed class UserPreferenceAttributes with _$UserPreferenceAttributes {
  const factory none() = EmptyUserPreferenceAttributes;

  const factory wished() = WishedUserPreferenceAttributes;

  @Assert(
    '(boxed > 0) || (opened > 0)',
    'boxed or opened cannot be both less than 0',
  )
  const factory owned({@Default(0) int boxed, @Default(1) int opened}) =
      OwnedUserPreferenceAttributes;
}
