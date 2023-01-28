import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';


@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    required bool usePercentage,
    required bool useGrid,
    HiddenTypes? ignored,
  }) = _Preferences;
	
}
