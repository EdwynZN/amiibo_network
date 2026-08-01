// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(count) =>
      "${Intl.plural(count, one: '+ 1 mehr', two: '+ 2 mehr', few: '+ ${count} mehr', other: '+ viele mehr')}";

  static String m1(choice) =>
      "${Intl.select(choice, {'All': 'Alle', 'Owned': 'Besitz', 'Wishlist': 'Wunschliste', 'Name': 'Name', 'Game': 'Spiel', 'Figures': 'Alle Figuren', 'Cards': 'Alle Karten', 'AmiiboSeries': 'Benutzerdefiniert', 'other': '${choice}'})}";

  static String m2(character) => "Charakter: ${character}";

  static String m3(url) => "${url} konnte nicht geöffnet werden";

  static String m4(choice) =>
      "${Intl.select(choice, {'pokemon': 'Schnapp sie dir alle!', 'pokeball': 'Schnapp sie dir alle!', 'mario': 'Deine Sammlung ist in einem anderen Schloss', 'mushroom': '1UP Sammlung hier entlang', 'pacman': 'Hunger auf Amiibos', 'pacmanGhost': 'Hunger auf Amiibos?', 'link': 'Hyaaa!! (Keine Amiibos hier)', 'other': 'Hier gibt es noch nichts zu sehen . . .'})}";

  static String m5(game) => "Spiel: ${game}";

  static String m6(choice) =>
      "${Intl.select(choice, {'en': 'Englisch', 'es': 'Spanisch', 'fr': 'Französisch', 'de': 'Deutsch', 'other': 'Unbekannt'})}";

  static String m7(choice) =>
      "${Intl.select(choice, {'true': 'Gesperrt', 'false': 'Entsperrt', 'other': 'Unbekannt'})}";

  static String m8(name) => "Name: ${name}";

  static String m9(choice) =>
      "${Intl.select(choice, {'Game': 'Spiel', 'Name': 'Name', 'AmiiboSeries': 'Serie', 'other': '${choice}'})}";

  static String m10(serie) => "Serie: ${serie}";

  static String m11(choice) =>
      "${Intl.select(choice, {'true': 'Prozentsatz', 'false': 'Bruch', 'other': 'Unbekannt'})}";

  static String m12(choice) =>
      "${Intl.select(choice, {'granted': 'Speicherberechtigung erteilt', 'denied': 'Speicherberechtigung verweigert', 'permanentlyDenied': 'Speicherberechtigung verweigert', 'restricted': 'Speicherberechtigung eingeschränkt', 'other': 'Unbekannter Berechtigungsstatus'})}";

  static String m13(choice) =>
      "${Intl.select(choice, {'system': 'System', 'light': 'Hell', 'dark': 'Dunkel', 'other': 'Auto'})}";

  static String m14(type) => "Typ: ${type}";

  static String m15(choice) =>
      "${Intl.select(choice, {'Figure': 'Figur', 'Card': 'Karte', 'Yarn': 'Wolle', 'Band': 'Armband', 'other': 'Sonstiges'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("Über"),
    "actionText": MessageLookupByLibrary.simpleMessage("Teilen"),
    "all": MessageLookupByLibrary.simpleMessage("Alle"),
    "amazon_link_setting": MessageLookupByLibrary.simpleMessage("Amazon-Seite"),
    "amazon_link_setting_subtitle": MessageLookupByLibrary.simpleMessage(
      "Wähle deine länderspezifische Amazon-Seite",
    ),
    "amiibo_type": MessageLookupByLibrary.simpleMessage("Amiibo-Typ"),
    "amiibo_usage_count": m0,
    "appearance": MessageLookupByLibrary.simpleMessage("Erscheinungsbild"),
    "appearanceSubtitle": MessageLookupByLibrary.simpleMessage(
      "Mehr Personalisierung",
    ),
    "asc": MessageLookupByLibrary.simpleMessage("Aufsteigend (A-Z)"),
    "au": MessageLookupByLibrary.simpleMessage("Australien"),
    "auto": MessageLookupByLibrary.simpleMessage("System"),
    "boxed": MessageLookupByLibrary.simpleMessage("OVP"),
    "cancel": MessageLookupByLibrary.simpleMessage("Warten, nein!"),
    "cardNumber": MessageLookupByLibrary.simpleMessage("Kartennummer"),
    "cards": MessageLookupByLibrary.simpleMessage("Karten"),
    "category": m1,
    "changelog": MessageLookupByLibrary.simpleMessage("Änderungsprotokoll"),
    "changelogSubtitle": MessageLookupByLibrary.simpleMessage(
      "Was gibt es Neues",
    ),
    "character": m2,
    "collectionReset": MessageLookupByLibrary.simpleMessage(
      "Sammlung zurückgesetzt",
    ),
    "color_mode": MessageLookupByLibrary.simpleMessage("Erscheinungsbild"),
    "console_3DS_platform": MessageLookupByLibrary.simpleMessage("3DS"),
    "couldNotLaunchUrl": m3,
    "createdOn": MessageLookupByLibrary.simpleMessage("Erstellt am"),
    "credits": MessageLookupByLibrary.simpleMessage("Mitwirkende"),
    "creditsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Diejenigen, die es möglich machen",
    ),
    "dark": MessageLookupByLibrary.simpleMessage("Dunkel"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Dunkles Design"),
    "desc": MessageLookupByLibrary.simpleMessage("Absteigend (Z-A)"),
    "donate": MessageLookupByLibrary.simpleMessage("Spenden"),
    "done": MessageLookupByLibrary.simpleMessage("Fertig"),
    "emptyMessageType": m4,
    "emptyPage": MessageLookupByLibrary.simpleMessage(
      "Hier gibt es noch nichts zu sehen . . .",
    ),
    "emptyPageAction": MessageLookupByLibrary.simpleMessage(
      "Sammlung erstellen",
    ),
    "errorImporting": MessageLookupByLibrary.simpleMessage(
      "Dies ist keine Amiibo-Liste",
    ),
    "eu": MessageLookupByLibrary.simpleMessage("Europa"),
    "export": MessageLookupByLibrary.simpleMessage("Exportieren"),
    "export_complete": MessageLookupByLibrary.simpleMessage(
      "Export abgeschlossen!",
    ),
    "export_subtitle": MessageLookupByLibrary.simpleMessage(
      "Speichere eine Datei deiner Sammlung",
    ),
    "features": MessageLookupByLibrary.simpleMessage("Funktionen"),
    "figures": MessageLookupByLibrary.simpleMessage("Figuren"),
    "game": m5,
    "hide_caution": MessageLookupByLibrary.simpleMessage(
      "Achtung: Das Deaktivieren einer Funktion blendet sie in der gesamten App aus",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Importieren"),
    "import_subtitle": MessageLookupByLibrary.simpleMessage(
      "Stelle deine Sammlung aus einer Datei wieder her",
    ),
    "invalid_amiibo": MessageLookupByLibrary.simpleMessage(
      "Ungültige Amiibo-Daten",
    ),
    "jp": MessageLookupByLibrary.simpleMessage("Japan"),
    "language": MessageLookupByLibrary.simpleMessage("Sprache"),
    "languageSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Sprache oder verwende die System-Sprache",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Hell"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Helles Design"),
    "localization": m6,
    "lockTooltip": m7,
    "markdownError": MessageLookupByLibrary.simpleMessage(
      "Beim Laden der Datei ist ein Fehler aufgetreten",
    ),
    "mode": MessageLookupByLibrary.simpleMessage("Design-Modus"),
    "na": MessageLookupByLibrary.simpleMessage("Nordamerika"),
    "name": m8,
    "no_date": MessageLookupByLibrary.simpleMessage(
      "Wird noch bekannt gegeben",
    ),
    "no_games_found": MessageLookupByLibrary.simpleMessage(
      "Noch keine Spiele für dieses Amiibo gefunden",
    ),
    "no_link_selected": MessageLookupByLibrary.simpleMessage(
      "Keine Bevorzugung",
    ),
    "no_link_selected_subtitle": MessageLookupByLibrary.simpleMessage(
      "Wird jedes Mal gefragt",
    ),
    "notificationTitle": MessageLookupByLibrary.simpleMessage(
      "Export abgeschlossen",
    ),
    "openAppSettings": MessageLookupByLibrary.simpleMessage("Ändern"),
    "ownTooltip": MessageLookupByLibrary.simpleMessage("Besitzen"),
    "owned": MessageLookupByLibrary.simpleMessage("Besitz"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzerklärung",
    ),
    "privacySubtitle": MessageLookupByLibrary.simpleMessage(
      "AGB und Bedingungen",
    ),
    "rate": MessageLookupByLibrary.simpleMessage("Bewerten"),
    "recordMessage": MessageLookupByLibrary.simpleMessage(
      "Ihre letzte Datei wird noch verarbeitet",
    ),
    "remaining": MessageLookupByLibrary.simpleMessage("Verbleibend"),
    "removeTooltip": MessageLookupByLibrary.simpleMessage("Entfernen"),
    "reportBug": MessageLookupByLibrary.simpleMessage("Fehler melden"),
    "reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "resetContent": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher? Diese Aktion kann nicht rückgängig gemacht werden",
    ),
    "resetSubtitle": MessageLookupByLibrary.simpleMessage(
      "Wunschliste und Sammlung zurücksetzen",
    ),
    "resetTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Sammlung zurücksetzen",
    ),
    "saveCollection": MessageLookupByLibrary.simpleMessage(
      "Sammlung speichern",
    ),
    "saveCollectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Erstelle ein Bild deiner Sammlung",
    ),
    "saveCollectionTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Wähle deine Sammlung",
    ),
    "saveStatsTooltip": MessageLookupByLibrary.simpleMessage(
      "Statistiken speichern",
    ),
    "savingCollectionMessage": MessageLookupByLibrary.simpleMessage(
      "Datei wird gespeichert. Dies kann je nach Gerät eine Weile dauern",
    ),
    "searchCategory": m9,
    "select_user_attribute": MessageLookupByLibrary.simpleMessage(
      "Kategorie auswählen",
    ),
    "serie": m10,
    "settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "showGrid": MessageLookupByLibrary.simpleMessage("Raster"),
    "showOwnerCategories": MessageLookupByLibrary.simpleMessage(
      "Besitzer-Kategorien anzeigen",
    ),
    "showOwnerCategoriesDetails": MessageLookupByLibrary.simpleMessage(
      "Erlaubt die Visualisierung von Amiibos nach OVP / Ausgepackt",
    ),
    "showPercentage": MessageLookupByLibrary.simpleMessage(
      "Prozentwert anzeigen",
    ),
    "socket_exception": MessageLookupByLibrary.simpleMessage(
      "Überprüfe deine Netzwerkverbindung",
    ),
    "sort": MessageLookupByLibrary.simpleMessage("Sortieren nach"),
    "sortName": MessageLookupByLibrary.simpleMessage("Name"),
    "splashError": MessageLookupByLibrary.simpleMessage(
      "Aktualisierung fehlgeschlagen ☹",
    ),
    "splashMessage": MessageLookupByLibrary.simpleMessage(
      "Einen Moment bitte . . .",
    ),
    "splashWelcome": MessageLookupByLibrary.simpleMessage("WILLKOMMEN"),
    "statTooltip": m11,
    "stats": MessageLookupByLibrary.simpleMessage("Statistiken"),
    "storagePermission": m12,
    "successImport": MessageLookupByLibrary.simpleMessage(
      "Amiibo-Liste aktualisiert",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Unterstützung"),
    "sure": MessageLookupByLibrary.simpleMessage("Sicher"),
    "switch_platform": MessageLookupByLibrary.simpleMessage("Switch"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "themeMode": m13,
    "total": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "type": m14,
    "types": m15,
    "unboxed": MessageLookupByLibrary.simpleMessage("Ausgepackt"),
    "upToolTip": MessageLookupByLibrary.simpleMessage("Nach oben"),
    "use_in_app_browser": MessageLookupByLibrary.simpleMessage(
      "Affiliate-Webseiten in der App öffnen",
    ),
    "use_in_app_browser_subtitle": MessageLookupByLibrary.simpleMessage(
      "Erlaube das Öffnen von Affiliate-Links innerhalb der App",
    ),
    "use_wallpaper": MessageLookupByLibrary.simpleMessage("Dynamische Farbe"),
    "use_wallpaper_subtitle": MessageLookupByLibrary.simpleMessage(
      "Verwende dein Hintergrundbild als Farbpalette",
    ),
    "wiiu_platform": MessageLookupByLibrary.simpleMessage("WiiU"),
    "wishTooltip": MessageLookupByLibrary.simpleMessage("Wünschen"),
    "wished": MessageLookupByLibrary.simpleMessage("Gewünscht"),
  };
}
