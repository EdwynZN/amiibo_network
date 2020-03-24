// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static m0(choice) => "${Intl.select(choice, {'All': 'All', 'Owned': 'Owned', 'Wishlist': 'Wishlist', 'Name': 'Name', 'Game': 'Game', 'AmiiboSeries': 'Serie', 'Figures': 'All Figures', 'Cards': 'All Cards', 'other': '${choice}', })}";

  static m1(character) => "Character: ${character}";

  static m2(url) => "Could not launch ${url}";

  static m3(game) => "Game: ${game}";

  static m4(name) => "Name: ${name}";

  static m5(serie) => "Serie: ${serie}";

  static m6(choice) => "${Intl.select(choice, {'granted': 'Storage permission granted', 'denied': 'Storage permission denied', 'neverAskAgain': 'Storage permission disabled', 'restricted': 'Storage permission restricted', 'other': 'Unknown permission access', })}";

  static m7(choice) => "${Intl.select(choice, {'system': 'Auto', 'light': 'Light', 'dark': 'Dark', 'other': 'Auto', })}";

  static m8(type) => "Type: ${type}";

  static m9(choice) => "${Intl.select(choice, {'Figure': 'Type: Figure', 'Card': 'Type: Card', 'Yarn': 'Type: Yarn', 'other': 'Type: Other', })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "all" : MessageLookupByLibrary.simpleMessage("All"),
    "appearance" : MessageLookupByLibrary.simpleMessage("Appearance"),
    "appearanceSubtitle" : MessageLookupByLibrary.simpleMessage("More personalization"),
    "asc" : MessageLookupByLibrary.simpleMessage("Ascending (A-Z)"),
    "au" : MessageLookupByLibrary.simpleMessage("Australia"),
    "auto" : MessageLookupByLibrary.simpleMessage("Auto"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Wait no!"),
    "cards" : MessageLookupByLibrary.simpleMessage("Cards"),
    "category" : m0,
    "changelog" : MessageLookupByLibrary.simpleMessage("Changelog"),
    "changelogSubtitle" : MessageLookupByLibrary.simpleMessage("What\'s new"),
    "character" : m1,
    "collectionReset" : MessageLookupByLibrary.simpleMessage("Collection reset"),
    "couldNotLaunchUrl" : m2,
    "createdOn" : MessageLookupByLibrary.simpleMessage("Created on"),
    "credits" : MessageLookupByLibrary.simpleMessage("Credits"),
    "creditsSubtitle" : MessageLookupByLibrary.simpleMessage("Those who make it possible"),
    "dark" : MessageLookupByLibrary.simpleMessage("Dark"),
    "darkTheme" : MessageLookupByLibrary.simpleMessage("Dark Theme"),
    "desc" : MessageLookupByLibrary.simpleMessage("Descending (Z-A)"),
    "done" : MessageLookupByLibrary.simpleMessage("Done"),
    "emptyPage" : MessageLookupByLibrary.simpleMessage("Nothing to see here. . .yet"),
    "errorImporting" : MessageLookupByLibrary.simpleMessage("This isn\'t an Amiibo List"),
    "eu" : MessageLookupByLibrary.simpleMessage("Europe"),
    "export" : MessageLookupByLibrary.simpleMessage("Export"),
    "figures" : MessageLookupByLibrary.simpleMessage("Figures"),
    "fileSaved" : MessageLookupByLibrary.simpleMessage("Your file has been"),
    "game" : m3,
    "import" : MessageLookupByLibrary.simpleMessage("Import"),
    "jp" : MessageLookupByLibrary.simpleMessage("Japan"),
    "light" : MessageLookupByLibrary.simpleMessage("Light"),
    "lightTheme" : MessageLookupByLibrary.simpleMessage("Light Theme"),
    "markdownError" : MessageLookupByLibrary.simpleMessage("There was an error loading the file"),
    "mode" : MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "na" : MessageLookupByLibrary.simpleMessage("North America"),
    "name" : m4,
    "openAppSettings" : MessageLookupByLibrary.simpleMessage("change"),
    "overwritten" : MessageLookupByLibrary.simpleMessage("overwritten"),
    "ownTooltip" : MessageLookupByLibrary.simpleMessage("Own"),
    "owned" : MessageLookupByLibrary.simpleMessage("Owned"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacySubtitle" : MessageLookupByLibrary.simpleMessage("Therms and conditions"),
    "rate" : MessageLookupByLibrary.simpleMessage("Rate me"),
    "recordMessage" : MessageLookupByLibrary.simpleMessage("Still processing your last file"),
    "removeTooltip" : MessageLookupByLibrary.simpleMessage("Remove"),
    "reportBug" : MessageLookupByLibrary.simpleMessage("Report bug"),
    "reset" : MessageLookupByLibrary.simpleMessage("Reset"),
    "resetContent" : MessageLookupByLibrary.simpleMessage("Are you sure? This action can\'t be undone"),
    "resetSubtitle" : MessageLookupByLibrary.simpleMessage("Reset your wishlist and collection"),
    "resetTitleDialog" : MessageLookupByLibrary.simpleMessage("Reset your collection"),
    "saveCollection" : MessageLookupByLibrary.simpleMessage("Save Collection"),
    "saveCollectionSubtitle" : MessageLookupByLibrary.simpleMessage("Create a picture of your collection"),
    "saveCollectionTitleDialog" : MessageLookupByLibrary.simpleMessage("Select your collection"),
    "saveStatsTooltip" : MessageLookupByLibrary.simpleMessage("Save Stats"),
    "saved" : MessageLookupByLibrary.simpleMessage("saved"),
    "savingCollectionMessage" : MessageLookupByLibrary.simpleMessage("Saving your file. This could take a while depending on your device"),
    "serie" : m5,
    "settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "showPercentage" : MessageLookupByLibrary.simpleMessage("Show percentage"),
    "sort" : MessageLookupByLibrary.simpleMessage("Sort By"),
    "sortName" : MessageLookupByLibrary.simpleMessage("Name"),
    "splashError" : MessageLookupByLibrary.simpleMessage("Couldn\'t Update ☹"),
    "splashMessage" : MessageLookupByLibrary.simpleMessage("Just a second . . ."),
    "splashWelcome" : MessageLookupByLibrary.simpleMessage("WELCOME"),
    "stats" : MessageLookupByLibrary.simpleMessage("Stats"),
    "storagePermission" : m6,
    "successImport" : MessageLookupByLibrary.simpleMessage("Amiibo List updated"),
    "sure" : MessageLookupByLibrary.simpleMessage("Sure"),
    "themeMode" : m7,
    "type" : m8,
    "types" : m9,
    "upToolTip" : MessageLookupByLibrary.simpleMessage("Up"),
    "wishTooltip" : MessageLookupByLibrary.simpleMessage("Wish"),
    "wished" : MessageLookupByLibrary.simpleMessage("Wished")
  };
}
