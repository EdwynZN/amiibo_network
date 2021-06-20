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

  static String m0(choice) => "${Intl.select(choice, {
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

  static String m1(character) => "Character: ${character}";

  static String m2(url) => "Could not launch ${url}";

  static String m3(game) => "Game: ${game}";

  static String m4(choice) => "${Intl.select(choice, {
            'true': 'Locked',
            'false': 'Unlocked',
            'other': 'Unknown',
          })}";

  static String m5(name) => "Name: ${name}";

  static String m6(serie) => "Serie: ${serie}";

  static String m7(choice) => "${Intl.select(choice, {
            'true': 'Percentage',
            'false': 'Fraction',
            'other': 'Unknown',
          })}";

  static String m8(choice) => "${Intl.select(choice, {
            'granted': 'Storage permission granted',
            'denied': 'Storage permission denied',
            'permanentlyDenied': 'Storage permission denied',
            'restricted': 'Storage permission restricted',
            'other': 'Unknown permission access',
          })}";

  static String m9(choice) => "${Intl.select(choice, {
            'system': 'Auto',
            'light': 'Light',
            'dark': 'Dark',
            'other': 'Auto',
          })}";

  static String m10(type) => "Type: ${type}";

  static String m11(choice) => "${Intl.select(choice, {
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
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "appearanceSubtitle":
            MessageLookupByLibrary.simpleMessage("More personalization"),
        "asc": MessageLookupByLibrary.simpleMessage("Ascending (A-Z)"),
        "au": MessageLookupByLibrary.simpleMessage("Australia"),
        "auto": MessageLookupByLibrary.simpleMessage("Auto"),
        "cancel": MessageLookupByLibrary.simpleMessage("Wait no!"),
        "cards": MessageLookupByLibrary.simpleMessage("Cards"),
        "category": m0,
        "changelog": MessageLookupByLibrary.simpleMessage("Changelog"),
        "changelogSubtitle":
            MessageLookupByLibrary.simpleMessage("What\'s new"),
        "character": m1,
        "collectionReset":
            MessageLookupByLibrary.simpleMessage("Collection reset"),
        "couldNotLaunchUrl": m2,
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
        "game": m3,
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "jp": MessageLookupByLibrary.simpleMessage("Japan"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "lightTheme": MessageLookupByLibrary.simpleMessage("Light Theme"),
        "lockTooltip": m4,
        "markdownError": MessageLookupByLibrary.simpleMessage(
            "There was an error loading the file"),
        "mode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
        "na": MessageLookupByLibrary.simpleMessage("North America"),
        "name": m5,
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
        "serie": m6,
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "showPercentage":
            MessageLookupByLibrary.simpleMessage("Show percentage"),
        "sort": MessageLookupByLibrary.simpleMessage("Sort By"),
        "sortName": MessageLookupByLibrary.simpleMessage("Name"),
        "splashError":
            MessageLookupByLibrary.simpleMessage("Couldn\'t Update ☹"),
        "splashMessage":
            MessageLookupByLibrary.simpleMessage("Just a second . . ."),
        "splashWelcome": MessageLookupByLibrary.simpleMessage("WELCOME"),
        "statTooltip": m7,
        "stats": MessageLookupByLibrary.simpleMessage("Stats"),
        "storagePermission": m8,
        "successImport":
            MessageLookupByLibrary.simpleMessage("Amiibo List updated"),
        "sure": MessageLookupByLibrary.simpleMessage("Sure"),
        "themeMode": m9,
        "type": m10,
        "types": m11,
        "upToolTip": MessageLookupByLibrary.simpleMessage("Up"),
        "wishTooltip": MessageLookupByLibrary.simpleMessage("Wish"),
        "wished": MessageLookupByLibrary.simpleMessage("Wished")
      };
}
