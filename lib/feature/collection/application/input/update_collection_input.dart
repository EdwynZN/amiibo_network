import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_collection_input.freezed.dart';

const clearCollectionInput = UpdateCollectionInput(
  amiibos: [],
  bundles: [],
  clearAll: true,
);

@freezed
class const UpdateCollectionInput({
  required final List<CollectionAmiibo> amiibos,
  required final List<CollectionAmiibo> bundles,
  final bool clearAll = false,
}) with _$UpdateCollectionInput;

@freezed
class const CollectionAmiibo({
  required final int id,
  required final CollectionAttributes attributes,
}) with _$CollectionAmiibo;

@freezed
sealed class CollectionAttributes with _$CollectionAttributes {
  const factory none() = EmptyCollectionAttributes;

  const factory wished() = WishedCollectionAttributes;

  @Assert(
    '(boxed > 0) || (opened > 0)',
    'boxed or opened cannot be both less than 0',
  )
  const factory owned({@Default(0) int boxed, @Default(1) int opened}) =
      OwnedCollectionAttributes;

  factory fromOwnedOrEmpty({required int boxed, required int opened}) =>
      boxed + opened <= 0
      ? const EmptyCollectionAttributes()
      : OwnedCollectionAttributes(boxed: boxed, opened: opened);
}
