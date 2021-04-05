import 'package:freezed_annotation/freezed_annotation.dart';

part 'selection.freezed.dart';

@freezed
abstract class Selection with _$Selection {
  const factory Selection({
    @required bool activated,
    @required bool selected,
  }) = _Selection;
}
