import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

@riverpod
SharedPreferences preferences(Ref ref) =>
    throw UnsupportedError('No sharedPreferences');
