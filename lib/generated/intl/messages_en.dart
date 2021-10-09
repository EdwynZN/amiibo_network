// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, one: '+ 1 more', two: '+ 2 more', few: '+ ${count} more', other: '+ many more')}";

  static String m1(choice) => "${Intl.select(choice, {
            'All': 'All',
            'Owned': 'Owned',
            'Wishlist': 'Wishlist',
            'Name': 'Name',
            'Game': 'Game',
            'AmiiboSeries': 'Serie',
            'Figures': 'All Figures',
            'Cards': 'All Cards',
            'Custom': 'Custom',
            'other': '${choice}',
          })}";

  static String m2(character) => "Character: ${character}";

  static String m3(url) => "Could not launch ${url}";

  static String m4(game) => "Game: ${game}";

  static String m5(choice) => "${Intl.select(choice, {
            'true': 'Locked',
            'false': 'Unlocked',
            'other': 'Unknown',
          })}";

  static String m6(name) => "Name: ${name}";

  static String m7(serie) => "Serie: ${serie}";

  static String m8(choice) => "${Intl.select(choice, {
            'true': 'Percentage',
            'false': 'Fraction',
            'other': 'Unknown',
          })}";

  static String m9(choice) => "${Intl.select(choice, {
            'granted': 'Storage permission granted',
            'denied': 'Storage permission denied',
            'permanentlyDenied': 'Storage permission denied',
            'restricted': 'Storage permission restricted',
            'other': 'Unknown permission access',
          })}";

  static String m10(choice) => "${Intl.select(choice, {
            'system': 'Auto',
            'light': 'Light',
            'dark': 'Dark',
            'other': 'Auto',
          })}";

  static String m11(type) => "Type: ${type}";

  static String m12(choice) => "${Intl.select(choice, {
            'Figure': 'Type: Figure',
            'Card': 'Type: Card',
            'Yarn': 'Type: Yarn',
            'Band': 'Type: Band',
            'other': 'Type: Other',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionText": MessageLookupByLibrary.simpleMessage("Share"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "amiibo_usage_count": m0,
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "appearanceSubtitle":
            MessageLookupByLibrary.simpleMessage("More personalization"),
        "asc": MessageLookupByLibrary.simpleMessage("Ascending (A-Z)"),
        "au": MessageLookupByLibrary.simpleMessage("Australia"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "cancel": MessageLookupByLibrary.simpleMessage("Wait no!"),
        "cards": MessageLookupByLibrary.simpleMessage("Cards"),
        "category": m1,
        "changelog": MessageLookupByLibrary.simpleMessage("Changelog"),
        "changelogSubtitle":
            MessageLookupByLibrary.simpleMessage("What\'s new"),
        "character": m2,
        "collectionReset":
            MessageLookupByLibrary.simpleMessage("Collection reset"),
        "console_3DS_platform": MessageLookupByLibrary.simpleMessage("3DS"),
        "couldNotLaunchUrl": m3,
        "createdOn": MessageLookupByLibrary.simpleMessage("Created on"),
        "credits": MessageLookupByLibrary.simpleMessage("Credits"),
        "creditsSubtitle":
            MessageLookupByLibrary.simpleMessage("Those who make it possible"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "darkTheme": MessageLookupByLibrary.simpleMessage("Dark Theme"),
        "desc": MessageLookupByLibrary.simpleMessage("Descending (Z-A)"),
        "donate": MessageLookupByLibrary.simpleMessage("Donate"),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "emptyPage":
            MessageLookupByLibrary.simpleMessage("Nothing to see here. . .yet"),
        "errorImporting":
            MessageLookupByLibrary.simpleMessage("This isn\'t an Amiibo List"),
        "eu": MessageLookupByLibrary.simpleMessage("Europe"),
        "export": MessageLookupByLibrary.simpleMessage("Export"),
        "figures": MessageLookupByLibrary.simpleMessage("Figures"),
        "game": m4,
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "invalid_amiibo":
            MessageLookupByLibrary.simpleMessage("Invalid amiibo data"),
        "jp": MessageLookupByLibrary.simpleMessage("Japan"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "lightTheme": MessageLookupByLibrary.simpleMessage("Light Theme"),
        "lockTooltip": m5,
        "markdownError": MessageLookupByLibrary.simpleMessage(
            "There was an error loading the file"),
        "mode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "na": MessageLookupByLibrary.simpleMessage("North America"),
        "name": m6,
        "no_date": MessageLookupByLibrary.simpleMessage("No Date"),
        "no_games_found": MessageLookupByLibrary.simpleMessage(
            "No games found for this amiibo yet"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Export complete"),
        "openAppSettings": MessageLookupByLibrary.simpleMessage("Change"),
        "ownTooltip": MessageLookupByLibrary.simpleMessage("Own"),
        "owned": MessageLookupByLibrary.simpleMessage("Owned"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
        "privacySubtitle":
            MessageLookupByLibrary.simpleMessage("Terms and conditions"),
        "rate": MessageLookupByLibrary.simpleMessage("Rate me"),
        "recordMessage": MessageLookupByLibrary.simpleMessage(
            "Still processing your last file"),
        "removeTooltip": MessageLookupByLibrary.simpleMessage("Remove"),
        "reportBug": MessageLookupByLibrary.simpleMessage("Report bug"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "resetContent": MessageLookupByLibrary.simpleMessage(
            "Are you sure? This action can\'t be undone"),
        "resetSubtitle": MessageLookupByLibrary.simpleMessage(
            "Reset your wishlist and collection"),
        "resetTitleDialog":
            MessageLookupByLibrary.simpleMessage("Reset your collection"),
        "saveCollection":
            MessageLookupByLibrary.simpleMessage("Save Collection"),
        "saveCollectionSubtitle": MessageLookupByLibrary.simpleMessage(
            "Create a picture of your collection"),
        "saveCollectionTitleDialog":
            MessageLookupByLibrary.simpleMessage("Select your collection"),
        "saveStatsTooltip": MessageLookupByLibrary.simpleMessage("Save Stats"),
        "savingCollectionMessage": MessageLookupByLibrary.simpleMessage(
            "Saving your file. This could take a while depending on your device"),
        "serie": m7,
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "showPercentage":
            MessageLookupByLibrary.simpleMessage("Show percentage"),
        "socket_exception":
            MessageLookupByLibrary.simpleMessage("Check your network"),
        "sort": MessageLookupByLibrary.simpleMessage("Sort By"),
        "sortName": MessageLookupByLibrary.simpleMessage("Name"),
        "splashError":
            MessageLookupByLibrary.simpleMessage("Couldn\'t Update ☹"),
        "splashMessage":
            MessageLookupByLibrary.simpleMessage("Just a second . . ."),
        "splashWelcome": MessageLookupByLibrary.simpleMessage("WELCOME"),
        "statTooltip": m8,
        "stats": MessageLookupByLibrary.simpleMessage("Stats"),
        "storagePermission": m9,
        "successImport":
            MessageLookupByLibrary.simpleMessage("Amiibo List updated"),
        "sure": MessageLookupByLibrary.simpleMessage("Sure"),
        "switch_platform": MessageLookupByLibrary.simpleMessage("Switch"),
        "themeMode": m10,
        "type": m11,
        "types": m12,
        "upToolTip": MessageLookupByLibrary.simpleMessage("Up"),
        "wiiu_platform": MessageLookupByLibrary.simpleMessage("WIiU"),
        "wishTooltip": MessageLookupByLibrary.simpleMessage("Wish"),
        "wished": MessageLookupByLibrary.simpleMessage("Wished")
      };
}
