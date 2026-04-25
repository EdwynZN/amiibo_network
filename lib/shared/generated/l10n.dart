// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Just a second . . .`
  String get splashMessage {
    return Intl.message(
      'Just a second . . .',
      name: 'splashMessage',
      desc: '',
      args: [],
    );
  }

  /// `WELCOME`
  String get splashWelcome {
    return Intl.message('WELCOME', name: 'splashWelcome', desc: '', args: []);
  }

  /// `Couldn't Update ☹`
  String get splashError {
    return Intl.message(
      'Couldn\'t Update ☹',
      name: 'splashError',
      desc: '',
      args: [],
    );
  }

  /// `Show percentage`
  String get showPercentage {
    return Intl.message(
      'Show percentage',
      name: 'showPercentage',
      desc: '',
      args: [],
    );
  }

  /// `Show owner categories`
  String get showOwnerCategories {
    return Intl.message(
      'Show owner categories',
      name: 'showOwnerCategories',
      desc: '',
      args: [],
    );
  }

  /// `Allow to visualize owned amiibos by boxed/unboxed`
  String get showOwnerCategoriesDetails {
    return Intl.message(
      'Allow to visualize owned amiibos by boxed/unboxed',
      name: 'showOwnerCategoriesDetails',
      desc: '',
      args: [],
    );
  }

  /// `{choice, select, All {All} Owned {Owned} Wishlist {Wishlist} Name {Name} Game {Game} Figures {All Figures} Cards {All Cards} AmiiboSeries {Custom} other {{choice}}}`
  String category(Object choice) {
    return Intl.select(
      choice,
      {
        'All': 'All',
        'Owned': 'Owned',
        'Wishlist': 'Wishlist',
        'Name': 'Name',
        'Game': 'Game',
        'Figures': 'All Figures',
        'Cards': 'All Cards',
        'AmiiboSeries': 'Custom',
        'other': '$choice',
      },
      name: 'category',
      desc: '',
      args: [choice],
    );
  }

  /// `{choice, select, Game {Game} Name {Name} AmiiboSeries {Serie} other {{choice}}}`
  String searchCategory(Object choice) {
    return Intl.select(
      choice,
      {
        'Game': 'Game',
        'Name': 'Name',
        'AmiiboSeries': 'Serie',
        'other': '$choice',
      },
      name: 'searchCategory',
      desc: '',
      args: [choice],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Remaining`
  String get remaining {
    return Intl.message('Remaining', name: 'remaining', desc: '', args: []);
  }

  /// `Owned`
  String get owned {
    return Intl.message('Owned', name: 'owned', desc: '', args: []);
  }

  /// `Boxed`
  String get boxed {
    return Intl.message('Boxed', name: 'boxed', desc: '', args: []);
  }

  /// `Unboxed`
  String get unboxed {
    return Intl.message('Unboxed', name: 'unboxed', desc: '', args: []);
  }

  /// `Wished`
  String get wished {
    return Intl.message('Wished', name: 'wished', desc: '', args: []);
  }

  /// `Stats`
  String get stats {
    return Intl.message('Stats', name: 'stats', desc: '', args: []);
  }

  /// `{choice, select, Figure {Figure} Card {Card} Yarn {Yarn} Band {Band} other {Other}}`
  String types(Object choice) {
    return Intl.select(
      choice,
      {
        'Figure': 'Figure',
        'Card': 'Card',
        'Yarn': 'Yarn',
        'Band': 'Band',
        'other': 'Other',
      },
      name: 'types',
      desc: '',
      args: [choice],
    );
  }

  /// `Figures`
  String get figures {
    return Intl.message('Figures', name: 'figures', desc: '', args: []);
  }

  /// `Cards`
  String get cards {
    return Intl.message('Cards', name: 'cards', desc: '', args: []);
  }

  /// `Name: {name}`
  String name(Object name) {
    return Intl.message('Name: $name', name: 'name', desc: '', args: [name]);
  }

  /// `Character: {character}`
  String character(Object character) {
    return Intl.message(
      'Character: $character',
      name: 'character',
      desc: '',
      args: [character],
    );
  }

  /// `Serie: {serie}`
  String serie(Object serie) {
    return Intl.message(
      'Serie: $serie',
      name: 'serie',
      desc: '',
      args: [serie],
    );
  }

  /// `Game: {game}`
  String game(Object game) {
    return Intl.message('Game: $game', name: 'game', desc: '', args: [game]);
  }

  /// `Type: {type}`
  String type(Object type) {
    return Intl.message('Type: $type', name: 'type', desc: '', args: [type]);
  }

  /// `Ascending (A-Z)`
  String get asc {
    return Intl.message('Ascending (A-Z)', name: 'asc', desc: '', args: []);
  }

  /// `Descending (Z-A)`
  String get desc {
    return Intl.message('Descending (Z-A)', name: 'desc', desc: '', args: []);
  }

  /// `Name`
  String get sortName {
    return Intl.message('Name', name: 'sortName', desc: '', args: []);
  }

  /// `Australia`
  String get au {
    return Intl.message('Australia', name: 'au', desc: '', args: []);
  }

  /// `Europe`
  String get eu {
    return Intl.message('Europe', name: 'eu', desc: '', args: []);
  }

  /// `North America`
  String get na {
    return Intl.message('North America', name: 'na', desc: '', args: []);
  }

  /// `Japan`
  String get jp {
    return Intl.message('Japan', name: 'jp', desc: '', args: []);
  }

  /// `Card number`
  String get cardNumber {
    return Intl.message('Card number', name: 'cardNumber', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Sort By`
  String get sort {
    return Intl.message('Sort By', name: 'sort', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Sure`
  String get sure {
    return Intl.message('Sure', name: 'sure', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `System`
  String get auto {
    return Intl.message('System', name: 'auto', desc: '', args: []);
  }

  /// `{choice, select, system {System} light {Light} dark {Dark} other {Auto}}`
  String themeMode(Object choice) {
    return Intl.select(
      choice,
      {'system': 'System', 'light': 'Light', 'dark': 'Dark', 'other': 'Auto'},
      name: 'themeMode',
      desc: '',
      args: [choice],
    );
  }

  /// `Theme Mode`
  String get mode {
    return Intl.message('Theme Mode', name: 'mode', desc: '', args: []);
  }

  /// `Light Theme`
  String get lightTheme {
    return Intl.message('Light Theme', name: 'lightTheme', desc: '', args: []);
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message('Dark Theme', name: 'darkTheme', desc: '', args: []);
  }

  /// `Remove`
  String get removeTooltip {
    return Intl.message('Remove', name: 'removeTooltip', desc: '', args: []);
  }

  /// `Own`
  String get ownTooltip {
    return Intl.message('Own', name: 'ownTooltip', desc: '', args: []);
  }

  /// `Wish`
  String get wishTooltip {
    return Intl.message('Wish', name: 'wishTooltip', desc: '', args: []);
  }

  /// `Save Stats`
  String get saveStatsTooltip {
    return Intl.message(
      'Save Stats',
      name: 'saveStatsTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Up`
  String get upToolTip {
    return Intl.message('Up', name: 'upToolTip', desc: '', args: []);
  }

  /// `Nothing to see here. . .yet`
  String get emptyPage {
    return Intl.message(
      'Nothing to see here. . .yet',
      name: 'emptyPage',
      desc: '',
      args: [],
    );
  }

  /// `Create a collection`
  String get emptyPageAction {
    return Intl.message(
      'Create a collection',
      name: 'emptyPageAction',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message('Export', name: 'export', desc: '', args: []);
  }

  /// `Import`
  String get import {
    return Intl.message('Import', name: 'import', desc: '', args: []);
  }

  /// `Appearance`
  String get appearance {
    return Intl.message('Appearance', name: 'appearance', desc: '', args: []);
  }

  /// `Features`
  String get features {
    return Intl.message('Features', name: 'features', desc: '', args: []);
  }

  /// `More personalization`
  String get appearanceSubtitle {
    return Intl.message(
      'More personalization',
      name: 'appearanceSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Credits`
  String get credits {
    return Intl.message('Credits', name: 'credits', desc: '', args: []);
  }

  /// `Those who make it possible`
  String get creditsSubtitle {
    return Intl.message(
      'Those who make it possible',
      name: 'creditsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms and conditions`
  String get privacySubtitle {
    return Intl.message(
      'Terms and conditions',
      name: 'privacySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Reset your wishlist and collection`
  String get resetSubtitle {
    return Intl.message(
      'Reset your wishlist and collection',
      name: 'resetSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset your collection`
  String get resetTitleDialog {
    return Intl.message(
      'Reset your collection',
      name: 'resetTitleDialog',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure? This action can't be undone`
  String get resetContent {
    return Intl.message(
      'Are you sure? This action can\'t be undone',
      name: 'resetContent',
      desc: '',
      args: [],
    );
  }

  /// `Wait no!`
  String get cancel {
    return Intl.message('Wait no!', name: 'cancel', desc: '', args: []);
  }

  /// `Save Collection`
  String get saveCollection {
    return Intl.message(
      'Save Collection',
      name: 'saveCollection',
      desc: '',
      args: [],
    );
  }

  /// `Create a picture of your collection`
  String get saveCollectionSubtitle {
    return Intl.message(
      'Create a picture of your collection',
      name: 'saveCollectionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Select your collection`
  String get saveCollectionTitleDialog {
    return Intl.message(
      'Select your collection',
      name: 'saveCollectionTitleDialog',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch {url}`
  String couldNotLaunchUrl(Object url) {
    return Intl.message(
      'Could not launch $url',
      name: 'couldNotLaunchUrl',
      desc: '',
      args: [url],
    );
  }

  /// `Report bug`
  String get reportBug {
    return Intl.message('Report bug', name: 'reportBug', desc: '', args: []);
  }

  /// `Rate me`
  String get rate {
    return Intl.message('Rate me', name: 'rate', desc: '', args: []);
  }

  /// `What's new`
  String get changelogSubtitle {
    return Intl.message(
      'What\'s new',
      name: 'changelogSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Changelog`
  String get changelog {
    return Intl.message('Changelog', name: 'changelog', desc: '', args: []);
  }

  /// `There was an error loading the file`
  String get markdownError {
    return Intl.message(
      'There was an error loading the file',
      name: 'markdownError',
      desc: '',
      args: [],
    );
  }

  /// `{choice, select, granted {Storage permission granted} denied {Storage permission denied} permanentlyDenied {Storage permission denied} restricted {Storage permission restricted} other {Unknown permission access}}`
  String storagePermission(Object choice) {
    return Intl.select(
      choice,
      {
        'granted': 'Storage permission granted',
        'denied': 'Storage permission denied',
        'permanentlyDenied': 'Storage permission denied',
        'restricted': 'Storage permission restricted',
        'other': 'Unknown permission access',
      },
      name: 'storagePermission',
      desc: '',
      args: [choice],
    );
  }

  /// `Created on`
  String get createdOn {
    return Intl.message('Created on', name: 'createdOn', desc: '', args: []);
  }

  /// `Collection reset`
  String get collectionReset {
    return Intl.message(
      'Collection reset',
      name: 'collectionReset',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get openAppSettings {
    return Intl.message('Change', name: 'openAppSettings', desc: '', args: []);
  }

  /// `Still processing your last file`
  String get recordMessage {
    return Intl.message(
      'Still processing your last file',
      name: 'recordMessage',
      desc: '',
      args: [],
    );
  }

  /// `Saving your file. This could take a while depending on your device`
  String get savingCollectionMessage {
    return Intl.message(
      'Saving your file. This could take a while depending on your device',
      name: 'savingCollectionMessage',
      desc: '',
      args: [],
    );
  }

  /// `This isn't an Amiibo List`
  String get errorImporting {
    return Intl.message(
      'This isn\'t an Amiibo List',
      name: 'errorImporting',
      desc: '',
      args: [],
    );
  }

  /// `Amiibo List updated`
  String get successImport {
    return Intl.message(
      'Amiibo List updated',
      name: 'successImport',
      desc: '',
      args: [],
    );
  }

  /// `Export complete`
  String get notificationTitle {
    return Intl.message(
      'Export complete',
      name: 'notificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get actionText {
    return Intl.message('Share', name: 'actionText', desc: '', args: []);
  }

  /// `Donate`
  String get donate {
    return Intl.message('Donate', name: 'donate', desc: '', args: []);
  }

  /// `{choice, select, true {Locked} false {Unlocked} other {Unknown}}`
  String lockTooltip(Object choice) {
    return Intl.select(
      choice,
      {'true': 'Locked', 'false': 'Unlocked', 'other': 'Unknown'},
      name: 'lockTooltip',
      desc: '',
      args: [choice],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Choose a language or use it from the system`
  String get languageSubtitle {
    return Intl.message(
      'Choose a language or use it from the system',
      name: 'languageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message('System', name: 'system', desc: '', args: []);
  }

  /// `{choice, select, en {English} es {Spanish} fr {French} other {Unknown}}`
  String localization(Object choice) {
    return Intl.select(
      choice,
      {'en': 'English', 'es': 'Spanish', 'fr': 'French', 'other': 'Unknown'},
      name: 'localization',
      desc: '',
      args: [choice],
    );
  }

  /// `{choice, select, true {Percentage} false {Fraction} other {Unknown}}`
  String statTooltip(Object choice) {
    return Intl.select(
      choice,
      {'true': 'Percentage', 'false': 'Fraction', 'other': 'Unknown'},
      name: 'statTooltip',
      desc: '',
      args: [choice],
    );
  }

  /// `Switch`
  String get switch_platform {
    return Intl.message('Switch', name: 'switch_platform', desc: '', args: []);
  }

  /// `WiiU`
  String get wiiu_platform {
    return Intl.message('WiiU', name: 'wiiu_platform', desc: '', args: []);
  }

  /// `3DS`
  String get console_3DS_platform {
    return Intl.message(
      '3DS',
      name: 'console_3DS_platform',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{+ 1 more} two{+ 2 more} few{+ {count} more} other{+ many more}}`
  String amiibo_usage_count(num count) {
    return Intl.plural(
      count,
      one: '+ 1 more',
      two: '+ 2 more',
      few: '+ $count more',
      other: '+ many more',
      name: 'amiibo_usage_count',
      desc: '',
      args: [count],
    );
  }

  /// `Invalid amiibo data`
  String get invalid_amiibo {
    return Intl.message(
      'Invalid amiibo data',
      name: 'invalid_amiibo',
      desc: '',
      args: [],
    );
  }

  /// `Check your network`
  String get socket_exception {
    return Intl.message(
      'Check your network',
      name: 'socket_exception',
      desc: '',
      args: [],
    );
  }

  /// `No games found for this amiibo yet`
  String get no_games_found {
    return Intl.message(
      'No games found for this amiibo yet',
      name: 'no_games_found',
      desc: '',
      args: [],
    );
  }

  /// `To be announced`
  String get no_date {
    return Intl.message('To be announced', name: 'no_date', desc: '', args: []);
  }

  /// `Grid`
  String get showGrid {
    return Intl.message('Grid', name: 'showGrid', desc: '', args: []);
  }

  /// `Caution, disabling a feature will hide it from all aspects of the app`
  String get hide_caution {
    return Intl.message(
      'Caution, disabling a feature will hide it from all aspects of the app',
      name: 'hide_caution',
      desc: '',
      args: [],
    );
  }

  /// `Export completed!`
  String get export_complete {
    return Intl.message(
      'Export completed!',
      name: 'export_complete',
      desc: '',
      args: [],
    );
  }

  /// `Select a category`
  String get select_user_attribute {
    return Intl.message(
      'Select a category',
      name: 'select_user_attribute',
      desc: '',
      args: [],
    );
  }

  /// `{choice, select, pokemon {Gotta collect 'em all} pokeball {Gotta collect 'em all} mario {Your collection is in another castle} mushroom {1UP Collection this way} pacman {Hungry for amiibos} pacmanGhost {Hungry for amiibos?} link {Hyaaa!! (No amiibos here)} other {Nothing to see here. . .yet}}`
  String emptyMessageType(Object choice) {
    return Intl.select(
      choice,
      {
        'pokemon': 'Gotta collect \'em all',
        'pokeball': 'Gotta collect \'em all',
        'mario': 'Your collection is in another castle',
        'mushroom': '1UP Collection this way',
        'pacman': 'Hungry for amiibos',
        'pacmanGhost': 'Hungry for amiibos?',
        'link': 'Hyaaa!! (No amiibos here)',
        'other': 'Nothing to see here. . .yet',
      },
      name: 'emptyMessageType',
      desc: '',
      args: [choice],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Look and feel`
  String get color_mode {
    return Intl.message(
      'Look and feel',
      name: 'color_mode',
      desc: '',
      args: [],
    );
  }

  /// `Amiibo type`
  String get amiibo_type {
    return Intl.message('Amiibo type', name: 'amiibo_type', desc: '', args: []);
  }

  /// `Save a file of your collection`
  String get export_subtitle {
    return Intl.message(
      'Save a file of your collection',
      name: 'export_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Restore your collection from a file`
  String get import_subtitle {
    return Intl.message(
      'Restore your collection from a file',
      name: 'import_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Dynamic Color`
  String get use_wallpaper {
    return Intl.message(
      'Dynamic Color',
      name: 'use_wallpaper',
      desc: '',
      args: [],
    );
  }

  /// `Use your wallpaper as a palette of colors`
  String get use_wallpaper_subtitle {
    return Intl.message(
      'Use your wallpaper as a palette of colors',
      name: 'use_wallpaper_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Open affiliate web pages in app`
  String get use_in_app_browser {
    return Intl.message(
      'Open affiliate web pages in app',
      name: 'use_in_app_browser',
      desc: '',
      args: [],
    );
  }

  /// `Allow affiliate links to open inside the app`
  String get use_in_app_browser_subtitle {
    return Intl.message(
      'Allow affiliate links to open inside the app',
      name: 'use_in_app_browser_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Amazon site`
  String get amazon_link_setting {
    return Intl.message(
      'Amazon site',
      name: 'amazon_link_setting',
      desc: '',
      args: [],
    );
  }

  /// `Choose your country-specific Amazon site`
  String get amazon_link_setting_subtitle {
    return Intl.message(
      'Choose your country-specific Amazon site',
      name: 'amazon_link_setting_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `No preference`
  String get no_link_selected {
    return Intl.message(
      'No preference',
      name: 'no_link_selected',
      desc: '',
      args: [],
    );
  }

  /// `Will be asked each time`
  String get no_link_selected_subtitle {
    return Intl.message(
      'Will be asked each time',
      name: 'no_link_selected_subtitle',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
