// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: '+ 1 de plus', two: '+ 2 de plus', few: '+ ${count} de plus', other: 'beaucoup plus')}";

  static String m1(choice) => "${Intl.select(choice, {
            'All': 'Tous',
            'Owned': 'Possédé',
            'Wishlist': 'Liste de souhaits',
            'Name': 'Nom',
            'Game': 'Jeux',
            'AmiiboSeries': 'Série',
            'Figures': 'Tous les Figurines',
            'Cards': 'Toutes les Cartes',
            'Custom': 'Personnel',
            'other': '${choice}',
          })} ";

  static String m2(character) => "Personnage: ${character}";

  static String m3(url) => "Impossible de lancer ${url}";

  static String m4(game) => "Jeux: ${game}";

  static String m5(choice) => "${Intl.select(choice, {
            'true': 'Fermé à clé',
            'false': 'Déverrouillé',
            'other': 'inconnue',
          })}";

  static String m6(name) => "Nom: ${name}";

  static String m7(serie) => "Série: ${serie}";

  static String m8(choice) => "${Intl.select(choice, {
            'true': 'Pourcentage',
            'false': 'Fraction',
            'other': 'inconnue',
          })}";

  static String m9(choice) =>
      "{choix, sélectionnez, accordé {autorisation de stockage accordée} refusée {autorisation de stockage refusée} définitivementDenied {autorisation de stockage refusée} restreinte {autorisation de stockage restreinte} autre {accès d\'autorisation inconnu}}";

  static String m10(choice) => "${Intl.select(choice, {
            'system': 'Défaut',
            'light': 'Clair',
            'dark': 'Sombre',
            'other': 'Défaut',
          })}";

  static String m11(type) => "Type: ${type}";

  static String m12(choice) => "${Intl.select(choice, {
            'Figure': 'Type: Figurine',
            'Card': 'Type: Carte',
            'Yarn': 'Type: Laine',
            'Band': 'Type: Bracelet',
            'other': 'Type: Autre',
          })}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionText": MessageLookupByLibrary.simpleMessage("Partager"),
        "all": MessageLookupByLibrary.simpleMessage("Tous"),
        "amiibo_usage_count": m0,
        "appearance": MessageLookupByLibrary.simpleMessage("Apparence"),
        "appearanceSubtitle":
            MessageLookupByLibrary.simpleMessage("Plus de personnalisation"),
        "asc": MessageLookupByLibrary.simpleMessage("Croissant (A-Z)"),
        "au": MessageLookupByLibrary.simpleMessage("Australie"),
        "auto": MessageLookupByLibrary.simpleMessage("Défaut"),
        "cancel": MessageLookupByLibrary.simpleMessage("Attends non!"),
        "cards": MessageLookupByLibrary.simpleMessage("Cartes"),
        "category": m1,
        "changelog":
            MessageLookupByLibrary.simpleMessage("Journal des Modifications"),
        "changelogSubtitle":
            MessageLookupByLibrary.simpleMessage("Quoi de neuf"),
        "character": m2,
        "collectionReset":
            MessageLookupByLibrary.simpleMessage("réinitialiser la collection"),
        "console_3DS_platform": MessageLookupByLibrary.simpleMessage("3DS"),
        "couldNotLaunchUrl": m3,
        "createdOn": MessageLookupByLibrary.simpleMessage("Créé le"),
        "credits": MessageLookupByLibrary.simpleMessage("Crédits"),
        "creditsSubtitle": MessageLookupByLibrary.simpleMessage(
            "Ceux qui le rendent possible"),
        "dark": MessageLookupByLibrary.simpleMessage("Sombre"),
        "darkTheme": MessageLookupByLibrary.simpleMessage("Thème Sombre"),
        "desc": MessageLookupByLibrary.simpleMessage("Décroissant (Z-A)"),
        "donate": MessageLookupByLibrary.simpleMessage("Faire un don"),
        "done": MessageLookupByLibrary.simpleMessage("Fini"),
        "emptyPage":
            MessageLookupByLibrary.simpleMessage("Rien à voir ici ... encore"),
        "errorImporting": MessageLookupByLibrary.simpleMessage(
            "Ceci n\'est pas une liste Amiibo"),
        "eu": MessageLookupByLibrary.simpleMessage("Europe"),
        "export": MessageLookupByLibrary.simpleMessage("Exporter"),
        "figures": MessageLookupByLibrary.simpleMessage("Figurines"),
        "game": m4,
        "import": MessageLookupByLibrary.simpleMessage("Importer"),
        "invalid_amiibo":
            MessageLookupByLibrary.simpleMessage("informations invalides"),
        "jp": MessageLookupByLibrary.simpleMessage("Japon"),
        "light": MessageLookupByLibrary.simpleMessage("Clair"),
        "lightTheme": MessageLookupByLibrary.simpleMessage("Thème Clair"),
        "lockTooltip": m5,
        "markdownError": MessageLookupByLibrary.simpleMessage(
            "Une erreur s\'est produite lors du chargement du fichier"),
        "mode": MessageLookupByLibrary.simpleMessage("Mode"),
        "na": MessageLookupByLibrary.simpleMessage("Amérique du Nord"),
        "name": m6,
        "no_games_found": MessageLookupByLibrary.simpleMessage(
            "Aucun jeu trouvé pour cette amiibo pour le moment"),
        "notificationTitle":
            MessageLookupByLibrary.simpleMessage("Fichier généré"),
        "openAppSettings": MessageLookupByLibrary.simpleMessage("Modifier"),
        "ownTooltip": MessageLookupByLibrary.simpleMessage("Posséder"),
        "owned": MessageLookupByLibrary.simpleMessage("Possédé"),
        "privacyPolicy": MessageLookupByLibrary.simpleMessage(
            "Politique de Confidentialité"),
        "privacySubtitle":
            MessageLookupByLibrary.simpleMessage("Termes et conditions"),
        "rate": MessageLookupByLibrary.simpleMessage("Evaluer"),
        "recordMessage": MessageLookupByLibrary.simpleMessage(
            "Traitement de votre dernier fichier en cours"),
        "removeTooltip": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "reportBug": MessageLookupByLibrary.simpleMessage("Signaler un bug"),
        "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
        "resetContent": MessageLookupByLibrary.simpleMessage(
            "Êtes-vous sûr? Cette action est irréversible"),
        "resetSubtitle": MessageLookupByLibrary.simpleMessage(
            "Réinitialisez votre liste de souhaits et votre collection"),
        "resetTitleDialog": MessageLookupByLibrary.simpleMessage(
            "Réinitialisez votre collection"),
        "saveCollection":
            MessageLookupByLibrary.simpleMessage("Sauver la collection"),
        "saveCollectionSubtitle": MessageLookupByLibrary.simpleMessage(
            "Sauver une image de votre collection"),
        "saveCollectionTitleDialog": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez votre collection"),
        "saveStatsTooltip": MessageLookupByLibrary.simpleMessage(
            "Enregistrer les statistiques"),
        "serie": m7,
        "settings": MessageLookupByLibrary.simpleMessage("Paramétres"),
        "showPercentage":
            MessageLookupByLibrary.simpleMessage("Afficher le pourcentage"),
        "sort": MessageLookupByLibrary.simpleMessage("Trier par"),
        "sortName": MessageLookupByLibrary.simpleMessage("Nom"),
        "splashError": MessageLookupByLibrary.simpleMessage(
            "Impossible de mettre à jour ☹"),
        "splashMessage":
            MessageLookupByLibrary.simpleMessage("Juste une seconde ..."),
        "splashWelcome": MessageLookupByLibrary.simpleMessage("Bienvenue"),
        "statTooltip": m8,
        "stats": MessageLookupByLibrary.simpleMessage("Statistiques"),
        "storagePermission": m9,
        "successImport":
            MessageLookupByLibrary.simpleMessage("Collection mise à jour"),
        "sure": MessageLookupByLibrary.simpleMessage("Bien-sûr"),
        "switch_platform": MessageLookupByLibrary.simpleMessage("Switch"),
        "themeMode": m10,
        "type": m11,
        "types": m12,
        "upToolTip": MessageLookupByLibrary.simpleMessage("Vers le haut"),
        "wiiu_platform": MessageLookupByLibrary.simpleMessage("WIiU"),
        "wishTooltip": MessageLookupByLibrary.simpleMessage("Souhait"),
        "wished": MessageLookupByLibrary.simpleMessage("Souhaité")
      };
}
