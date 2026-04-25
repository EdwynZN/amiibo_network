// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, one: '+ 1 more', two: '+ 2 more', few: '+ ${count} more', other: '+ many more')}";

  static String m1(choice) =>
      "${Intl.select(choice, {'All': 'All', 'Owned': 'Owned', 'Wishlist': 'Wishlist', 'Name': 'Name', 'Game': 'Game', 'Figures': 'All Figures', 'Cards': 'All Cards', 'AmiiboSeries': 'Custom', 'other': '${choice}'})}";

  static String m2(character) => "Character: ${character}";

  static String m3(url) => "Could not launch ${url}";

  static String m4(choice) =>
      "${Intl.select(choice, {'pokemon': 'Gotta collect \'em all', 'pokeball': 'Gotta collect \'em all', 'mario': 'Your collection is in another castle', 'mushroom': '1UP Collection this way', 'pacman': 'Hungry for amiibos', 'pacmanGhost': 'Hungry for amiibos?', 'link': 'Hyaaa!! (No amiibos here)', 'other': 'Nothing to see here. . .yet'})}";

  static String m5(game) => "Game: ${game}";

  static String m6(choice) =>
      "${Intl.select(choice, {'en': 'English', 'es': 'Spanish', 'fr': 'French', 'other': 'Unknown'})}";

  static String m7(choice) =>
      "${Intl.select(choice, {'true': 'Locked', 'false': 'Unlocked', 'other': 'Unknown'})}";

  static String m8(name) => "Name: ${name}";

  static String m9(choice) =>
      "${Intl.select(choice, {'Game': 'Game', 'Name': 'Name', 'AmiiboSeries': 'Serie', 'other': '${choice}'})}";

  static String m10(serie) => "Serie: ${serie}";

  static String m11(choice) =>
      "${Intl.select(choice, {'true': 'Percentage', 'false': 'Fraction', 'other': 'Unknown'})}";

  static String m12(choice) =>
      "${Intl.select(choice, {'granted': 'Storage permission granted', 'denied': 'Storage permission denied', 'permanentlyDenied': 'Storage permission denied', 'restricted': 'Storage permission restricted', 'other': 'Unknown permission access'})}";

  static String m13(choice) =>
      "${Intl.select(choice, {'system': 'System', 'light': 'Light', 'dark': 'Dark', 'other': 'Auto'})}";

  static String m14(type) => "Type: ${type}";

  static String m15(choice) =>
      "${Intl.select(choice, {'Figure': 'Figure', 'Card': 'Card', 'Yarn': 'Yarn', 'Band': 'Band', 'other': 'Other'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "actionText": MessageLookupByLibrary.simpleMessage("Share"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "amazon_link_setting": MessageLookupByLibrary.simpleMessage("Amazon site"),
    "amazon_link_setting_subtitle": MessageLookupByLibrary.simpleMessage(
      "Choose your country-specific Amazon site",
    ),
    "amiibo_type": MessageLookupByLibrary.simpleMessage("Amiibo type"),
    "amiibo_usage_count": m0,
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appearanceSubtitle": MessageLookupByLibrary.simpleMessage(
      "More personalization",
    ),
    "asc": MessageLookupByLibrary.simpleMessage("Ascending (A-Z)"),
    "au": MessageLookupByLibrary.simpleMessage("Australia"),
    "auto": MessageLookupByLibrary.simpleMessage("System"),
    "boxed": MessageLookupByLibrary.simpleMessage("Boxed"),
    "cancel": MessageLookupByLibrary.simpleMessage("Wait no!"),
    "cardNumber": MessageLookupByLibrary.simpleMessage("Card number"),
    "cards": MessageLookupByLibrary.simpleMessage("Cards"),
    "category": m1,
    "changelog": MessageLookupByLibrary.simpleMessage("Changelog"),
    "changelogSubtitle": MessageLookupByLibrary.simpleMessage("What\'s new"),
    "character": m2,
    "collectionReset": MessageLookupByLibrary.simpleMessage("Collection reset"),
    "color_mode": MessageLookupByLibrary.simpleMessage("Look and feel"),
    "console_3DS_platform": MessageLookupByLibrary.simpleMessage("3DS"),
    "couldNotLaunchUrl": m3,
    "createdOn": MessageLookupByLibrary.simpleMessage("Created on"),
    "credits": MessageLookupByLibrary.simpleMessage("Credits"),
    "creditsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Those who make it possible",
    ),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Dark Theme"),
    "desc": MessageLookupByLibrary.simpleMessage("Descending (Z-A)"),
    "donate": MessageLookupByLibrary.simpleMessage("Donate"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "emptyMessageType": m4,
    "emptyPage": MessageLookupByLibrary.simpleMessage(
      "Nothing to see here. . .yet",
    ),
    "emptyPageAction": MessageLookupByLibrary.simpleMessage(
      "Create a collection",
    ),
    "errorImporting": MessageLookupByLibrary.simpleMessage(
      "This isn\'t an Amiibo List",
    ),
    "eu": MessageLookupByLibrary.simpleMessage("Europe"),
    "export": MessageLookupByLibrary.simpleMessage("Export"),
    "export_complete": MessageLookupByLibrary.simpleMessage(
      "Export completed!",
    ),
    "export_subtitle": MessageLookupByLibrary.simpleMessage(
      "Save a file of your collection",
    ),
    "features": MessageLookupByLibrary.simpleMessage("Features"),
    "figures": MessageLookupByLibrary.simpleMessage("Figures"),
    "game": m5,
    "hide_caution": MessageLookupByLibrary.simpleMessage(
      "Caution, disabling a feature will hide it from all aspects of the app",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "import_subtitle": MessageLookupByLibrary.simpleMessage(
      "Restore your collection from a file",
    ),
    "invalid_amiibo": MessageLookupByLibrary.simpleMessage(
      "Invalid amiibo data",
    ),
    "jp": MessageLookupByLibrary.simpleMessage("Japan"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choose a language or use it from the system",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Light Theme"),
    "localization": m6,
    "lockTooltip": m7,
    "markdownError": MessageLookupByLibrary.simpleMessage(
      "There was an error loading the file",
    ),
    "mode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "na": MessageLookupByLibrary.simpleMessage("North America"),
    "name": m8,
    "no_date": MessageLookupByLibrary.simpleMessage("To be announced"),
    "no_games_found": MessageLookupByLibrary.simpleMessage(
      "No games found for this amiibo yet",
    ),
    "no_link_selected": MessageLookupByLibrary.simpleMessage("No preference"),
    "no_link_selected_subtitle": MessageLookupByLibrary.simpleMessage(
      "Will be asked each time",
    ),
    "notificationTitle": MessageLookupByLibrary.simpleMessage(
      "Export complete",
    ),
    "openAppSettings": MessageLookupByLibrary.simpleMessage("Change"),
    "ownTooltip": MessageLookupByLibrary.simpleMessage("Own"),
    "owned": MessageLookupByLibrary.simpleMessage("Owned"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacySubtitle": MessageLookupByLibrary.simpleMessage(
      "Terms and conditions",
    ),
    "rate": MessageLookupByLibrary.simpleMessage("Rate me"),
    "recordMessage": MessageLookupByLibrary.simpleMessage(
      "Still processing your last file",
    ),
    "remaining": MessageLookupByLibrary.simpleMessage("Remaining"),
    "removeTooltip": MessageLookupByLibrary.simpleMessage("Remove"),
    "reportBug": MessageLookupByLibrary.simpleMessage("Report bug"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetContent": MessageLookupByLibrary.simpleMessage(
      "Are you sure? This action can\'t be undone",
    ),
    "resetSubtitle": MessageLookupByLibrary.simpleMessage(
      "Reset your wishlist and collection",
    ),
    "resetTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Reset your collection",
    ),
    "saveCollection": MessageLookupByLibrary.simpleMessage("Save Collection"),
    "saveCollectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Create a picture of your collection",
    ),
    "saveCollectionTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Select your collection",
    ),
    "saveStatsTooltip": MessageLookupByLibrary.simpleMessage("Save Stats"),
    "savingCollectionMessage": MessageLookupByLibrary.simpleMessage(
      "Saving your file. This could take a while depending on your device",
    ),
    "searchCategory": m9,
    "select_user_attribute": MessageLookupByLibrary.simpleMessage(
      "Select a category",
    ),
    "serie": m10,
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "showGrid": MessageLookupByLibrary.simpleMessage("Grid"),
    "showOwnerCategories": MessageLookupByLibrary.simpleMessage(
      "Show owner categories",
    ),
    "showOwnerCategoriesDetails": MessageLookupByLibrary.simpleMessage(
      "Allow to visualize owned amiibos by boxed/unboxed",
    ),
    "showPercentage": MessageLookupByLibrary.simpleMessage("Show percentage"),
    "socket_exception": MessageLookupByLibrary.simpleMessage(
      "Check your network",
    ),
    "sort": MessageLookupByLibrary.simpleMessage("Sort By"),
    "sortName": MessageLookupByLibrary.simpleMessage("Name"),
    "splashError": MessageLookupByLibrary.simpleMessage("Couldn\'t Update ☹"),
    "splashMessage": MessageLookupByLibrary.simpleMessage(
      "Just a second . . .",
    ),
    "splashWelcome": MessageLookupByLibrary.simpleMessage("WELCOME"),
    "statTooltip": m11,
    "stats": MessageLookupByLibrary.simpleMessage("Stats"),
    "storagePermission": m12,
    "successImport": MessageLookupByLibrary.simpleMessage(
      "Amiibo List updated",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "sure": MessageLookupByLibrary.simpleMessage("Sure"),
    "switch_platform": MessageLookupByLibrary.simpleMessage("Switch"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "themeMode": m13,
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "type": m14,
    "types": m15,
    "unboxed": MessageLookupByLibrary.simpleMessage("Unboxed"),
    "upToolTip": MessageLookupByLibrary.simpleMessage("Up"),
    "use_in_app_browser": MessageLookupByLibrary.simpleMessage(
      "Open affiliate web pages in app",
    ),
    "use_in_app_browser_subtitle": MessageLookupByLibrary.simpleMessage(
      "Allow affiliate links to open inside the app",
    ),
    "use_wallpaper": MessageLookupByLibrary.simpleMessage("Dynamic Color"),
    "use_wallpaper_subtitle": MessageLookupByLibrary.simpleMessage(
      "Use your wallpaper as a palette of colors",
    ),
    "wiiu_platform": MessageLookupByLibrary.simpleMessage("WiiU"),
    "wishTooltip": MessageLookupByLibrary.simpleMessage("Wish"),
    "wished": MessageLookupByLibrary.simpleMessage("Wished"),
  };
}
