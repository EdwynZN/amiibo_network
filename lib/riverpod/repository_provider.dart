import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//initialize at main
final preferencesProvider =
    Provider<SharedPreferences>((_) => throw UnsupportedError('No sharedPreferences'), name: 'PreferencesProvider');
