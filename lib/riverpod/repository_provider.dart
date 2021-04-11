import 'package:amiibo_network/service/service.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//initialize at main
final preferencesProvider =
    Provider<SharedPreferences>((_) => throw UnsupportedError('No amiibo id selected'), name: 'PreferencesProvider');

final serviceProvider = Provider<Service>((_) => Service());
