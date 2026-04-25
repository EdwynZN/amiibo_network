// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(count) =>
      "${Intl.plural(count, one: '+ 1 de plus', two: '+ 2 de plus', few: '+ ${count} de plus', other: 'beaucoup plus')}";

  static String m1(choice) =>
      "${Intl.select(choice, {'All': 'Tous', 'Owned': 'Possédé', 'Wishlist': 'Liste de souhaits', 'Name': 'Nom', 'Game': 'Jeux', 'Figures': 'Tous les Figurines', 'Cards': 'Toutes les Cartes', 'AmiiboSeries': 'Personnel', 'other': '${choice}'})} ";

  static String m2(character) => "Personnage: ${character}";

  static String m3(url) => "Impossible de lancer ${url}";

  static String m4(choice) =>
      "${Intl.gender(choice, other: 'Rien à voir ici ... encore')}";

  static String m5(game) => "Jeux: ${game}";

  static String m6(choice) =>
      "${Intl.select(choice, {'en': 'Anglais', 'es': 'Espagnol', 'fr': 'Français', 'other': 'Inconnu'})}";

  static String m7(choice) =>
      "${Intl.select(choice, {'true': 'Fermé à clé', 'false': 'Déverrouillé', 'other': 'inconnue'})}";

  static String m8(name) => "Nom: ${name}";

  static String m9(choice) =>
      "${Intl.select(choice, {'Game': 'Jeux', 'Name': 'Nom', 'AmiiboSeries': 'Série', 'other': '${choice}'})}";

  static String m10(serie) => "Série: ${serie}";

  static String m11(choice) =>
      "${Intl.select(choice, {'true': 'Pourcentage', 'false': 'Fraction', 'other': 'inconnue'})}";

  static String m12(choice) =>
      "{choix, sélectionnez, accordé {autorisation de stockage accordée} refusée {autorisation de stockage refusée} définitivementDenied {autorisation de stockage refusée} restreinte {autorisation de stockage restreinte} autre {accès d\'autorisation inconnu}}";

  static String m13(choice) =>
      "${Intl.select(choice, {'system': 'Défaut', 'light': 'Clair', 'dark': 'Sombre', 'other': 'Défaut'})}";

  static String m14(type) => "Type: ${type}";

  static String m15(choice) =>
      "${Intl.select(choice, {'Figure': 'Figurine', 'Card': 'Carte', 'Yarn': 'Laine', 'Band': 'Bracelet', 'other': 'Autre'})}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("À propos"),
    "actionText": MessageLookupByLibrary.simpleMessage("Partager"),
    "all": MessageLookupByLibrary.simpleMessage("Tous"),
    "amazon_link_setting": MessageLookupByLibrary.simpleMessage(
      "Site d\'Amazon",
    ),
    "amazon_link_setting_subtitle": MessageLookupByLibrary.simpleMessage(
      "Choisissez le site Amazon spécifique à votre pays",
    ),
    "amiibo_type": MessageLookupByLibrary.simpleMessage("Type d\'Amiibo"),
    "amiibo_usage_count": m0,
    "appearance": MessageLookupByLibrary.simpleMessage("Apparence"),
    "appearanceSubtitle": MessageLookupByLibrary.simpleMessage(
      "Plus de personnalisation",
    ),
    "asc": MessageLookupByLibrary.simpleMessage("Croissant (A-Z)"),
    "au": MessageLookupByLibrary.simpleMessage("Australie"),
    "auto": MessageLookupByLibrary.simpleMessage("Défaut"),
    "boxed": MessageLookupByLibrary.simpleMessage("En boîte"),
    "cancel": MessageLookupByLibrary.simpleMessage("Attends non!"),
    "cardNumber": MessageLookupByLibrary.simpleMessage("N° de carte"),
    "cards": MessageLookupByLibrary.simpleMessage("Cartes"),
    "category": m1,
    "changelog": MessageLookupByLibrary.simpleMessage(
      "Journal des Modifications",
    ),
    "changelogSubtitle": MessageLookupByLibrary.simpleMessage("Quoi de neuf"),
    "character": m2,
    "collectionReset": MessageLookupByLibrary.simpleMessage(
      "réinitialiser la collection",
    ),
    "color_mode": MessageLookupByLibrary.simpleMessage("Aspect"),
    "console_3DS_platform": MessageLookupByLibrary.simpleMessage("3DS"),
    "couldNotLaunchUrl": m3,
    "createdOn": MessageLookupByLibrary.simpleMessage("Créé le"),
    "credits": MessageLookupByLibrary.simpleMessage("Crédits"),
    "creditsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Ceux qui le rendent possible",
    ),
    "dark": MessageLookupByLibrary.simpleMessage("Sombre"),
    "darkTheme": MessageLookupByLibrary.simpleMessage("Thème Sombre"),
    "desc": MessageLookupByLibrary.simpleMessage("Décroissant (Z-A)"),
    "donate": MessageLookupByLibrary.simpleMessage("Faire un don"),
    "done": MessageLookupByLibrary.simpleMessage("Fini"),
    "emptyMessageType": m4,
    "emptyPage": MessageLookupByLibrary.simpleMessage(
      "Rien à voir ici ... encore",
    ),
    "emptyPageAction": MessageLookupByLibrary.simpleMessage(
      "Créer une collection",
    ),
    "errorImporting": MessageLookupByLibrary.simpleMessage(
      "Ceci n\'est pas une liste Amiibo",
    ),
    "eu": MessageLookupByLibrary.simpleMessage("Europe"),
    "export": MessageLookupByLibrary.simpleMessage("Exporter"),
    "export_complete": MessageLookupByLibrary.simpleMessage(
      "Exportation terminée",
    ),
    "export_subtitle": MessageLookupByLibrary.simpleMessage(
      "Sauvegarder un fichier de votre collection",
    ),
    "features": MessageLookupByLibrary.simpleMessage("Caractéristiques"),
    "figures": MessageLookupByLibrary.simpleMessage("Figurines"),
    "game": m5,
    "hide_caution": MessageLookupByLibrary.simpleMessage(
      "Attention, la désactivation d\'une caractéristique la masquera dans l\'ensemble de l\'application",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Importer"),
    "import_subtitle": MessageLookupByLibrary.simpleMessage(
      "Restaurez votre collection à partir d\'un fichier",
    ),
    "invalid_amiibo": MessageLookupByLibrary.simpleMessage(
      "informations invalides",
    ),
    "jp": MessageLookupByLibrary.simpleMessage("Japon"),
    "language": MessageLookupByLibrary.simpleMessage("Langue"),
    "languageSubtitle": MessageLookupByLibrary.simpleMessage(
      "Choisissez une langue ou utilisez-la depuis le système",
    ),
    "light": MessageLookupByLibrary.simpleMessage("Clair"),
    "lightTheme": MessageLookupByLibrary.simpleMessage("Thème Clair"),
    "localization": m6,
    "lockTooltip": m7,
    "markdownError": MessageLookupByLibrary.simpleMessage(
      "Une erreur s\'est produite lors du chargement du fichier",
    ),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "na": MessageLookupByLibrary.simpleMessage("Amérique du Nord"),
    "name": m8,
    "no_date": MessageLookupByLibrary.simpleMessage("Bientôt disponible"),
    "no_games_found": MessageLookupByLibrary.simpleMessage(
      "Aucun jeu trouvé pour cette amiibo pour le moment",
    ),
    "no_link_selected": MessageLookupByLibrary.simpleMessage(
      "Aucune préférence",
    ),
    "no_link_selected_subtitle": MessageLookupByLibrary.simpleMessage(
      "Sera demandé à chaque fois",
    ),
    "notificationTitle": MessageLookupByLibrary.simpleMessage("Fichier généré"),
    "openAppSettings": MessageLookupByLibrary.simpleMessage("Modifier"),
    "ownTooltip": MessageLookupByLibrary.simpleMessage("Posséder"),
    "owned": MessageLookupByLibrary.simpleMessage("Possédé"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Politique de Confidentialité",
    ),
    "privacySubtitle": MessageLookupByLibrary.simpleMessage(
      "Termes et conditions",
    ),
    "rate": MessageLookupByLibrary.simpleMessage("Evaluer"),
    "recordMessage": MessageLookupByLibrary.simpleMessage(
      "Traitement de votre dernier fichier en cours",
    ),
    "remaining": MessageLookupByLibrary.simpleMessage("Restant"),
    "removeTooltip": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "reportBug": MessageLookupByLibrary.simpleMessage("Signaler un bug"),
    "reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
    "resetContent": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr? Cette action est irréversible",
    ),
    "resetSubtitle": MessageLookupByLibrary.simpleMessage(
      "Réinitialisez votre liste de souhaits et votre collection",
    ),
    "resetTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Réinitialisez votre collection",
    ),
    "saveCollection": MessageLookupByLibrary.simpleMessage(
      "Sauver la collection",
    ),
    "saveCollectionSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sauver une image de votre collection",
    ),
    "saveCollectionTitleDialog": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez votre collection",
    ),
    "saveStatsTooltip": MessageLookupByLibrary.simpleMessage(
      "Enregistrer les statistiques",
    ),
    "searchCategory": m9,
    "select_user_attribute": MessageLookupByLibrary.simpleMessage(
      "Choisir une catégorie",
    ),
    "serie": m10,
    "settings": MessageLookupByLibrary.simpleMessage("Paramétres"),
    "showGrid": MessageLookupByLibrary.simpleMessage("Grille"),
    "showOwnerCategories": MessageLookupByLibrary.simpleMessage(
      "Afficher les catégories de propriétaires",
    ),
    "showOwnerCategoriesDetails": MessageLookupByLibrary.simpleMessage(
      "Permet de visualiser les amiibos possédés par boîte/non boîte",
    ),
    "showPercentage": MessageLookupByLibrary.simpleMessage(
      "Afficher le pourcentage",
    ),
    "socket_exception": MessageLookupByLibrary.simpleMessage(
      "Vérifiez votre connexion",
    ),
    "sort": MessageLookupByLibrary.simpleMessage("Trier par"),
    "sortName": MessageLookupByLibrary.simpleMessage("Nom"),
    "splashError": MessageLookupByLibrary.simpleMessage(
      "Impossible de mettre à jour ☹",
    ),
    "splashMessage": MessageLookupByLibrary.simpleMessage(
      "Juste une seconde ...",
    ),
    "splashWelcome": MessageLookupByLibrary.simpleMessage("Bienvenue"),
    "statTooltip": m11,
    "stats": MessageLookupByLibrary.simpleMessage("Statistiques"),
    "storagePermission": m12,
    "successImport": MessageLookupByLibrary.simpleMessage(
      "Collection mise à jour",
    ),
    "support": MessageLookupByLibrary.simpleMessage("Support"),
    "sure": MessageLookupByLibrary.simpleMessage("Bien-sûr"),
    "switch_platform": MessageLookupByLibrary.simpleMessage("Switch"),
    "system": MessageLookupByLibrary.simpleMessage("Système"),
    "themeMode": m13,
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "type": m14,
    "types": m15,
    "unboxed": MessageLookupByLibrary.simpleMessage("Déballé"),
    "upToolTip": MessageLookupByLibrary.simpleMessage("Vers le haut"),
    "use_in_app_browser": MessageLookupByLibrary.simpleMessage(
      "Ouvrir les pages Web affiliées dans l\'application",
    ),
    "use_in_app_browser_subtitle": MessageLookupByLibrary.simpleMessage(
      "Autoriser l\'ouverture des liens d\'affiliation dans l\'application",
    ),
    "use_wallpaper": MessageLookupByLibrary.simpleMessage("Couleur dynamique"),
    "use_wallpaper_subtitle": MessageLookupByLibrary.simpleMessage(
      "Utilisez votre papier peint comme une palette de couleurss",
    ),
    "wiiu_platform": MessageLookupByLibrary.simpleMessage("WiiU"),
    "wishTooltip": MessageLookupByLibrary.simpleMessage("Souhait"),
    "wished": MessageLookupByLibrary.simpleMessage("Souhaité"),
  };
}
