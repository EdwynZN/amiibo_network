import 'package:amiibo_network/utils/preferences_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> sharedPreferencesMigration(SharedPreferences preferences) async {
  /// Fix migration error: type 'String' is not a subtype of type 'bool?'
  /// in type cast. Error thrown PreferencesProvider.
  final sharedInAppBrowserObject = preferences.get(sharedInAppBrowser);
  if (sharedInAppBrowserObject is String?) {
    await preferences.remove(sharedInAppBrowser);
  }
}
