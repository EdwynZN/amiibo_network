// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
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
    return Intl.message(
      'WELCOME',
      name: 'splashWelcome',
      desc: '',
      args: [],
    );
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

  /// `{choice, select, All {All} Owned {Owned} Wishlist {Wishlist} Name {Name} Game {Game} AmiiboSeries {Serie} Figures {All Figures} Cards {All Cards} Custom {Custom} other {{choice}}}`
  String category(Object choice) {
    return Intl.select(
      choice,
      {
        'All': 'All',
        'Owned': 'Owned',
        'Wishlist': 'Wishlist',
        'Name': 'Name',
        'Game': 'Game',
        'AmiiboSeries': 'Serie',
        'Figures': 'All Figures',
        'Cards': 'All Cards',
        'Custom': 'Custom',
        'other': '$choice',
      },
      name: 'category',
      desc: '',
      args: [choice],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Owned`
  String get owned {
    return Intl.message(
      'Owned',
      name: 'owned',
      desc: '',
      args: [],
    );
  }

  /// `Wished`
  String get wished {
    return Intl.message(
      'Wished',
      name: 'wished',
      desc: '',
      args: [],
    );
  }

  /// `Stats`
  String get stats {
    return Intl.message(
      'Stats',
      name: 'stats',
      desc: '',
      args: [],
    );
  }

  /// `{choice, select, Figure {Type: Figure} Card {Type: Card} Yarn {Type: Yarn} other {Type: Other}}`
  String types(Object choice) {
    return Intl.select(
      choice,
      {
        'Figure': 'Type: Figure',
        'Card': 'Type: Card',
        'Yarn': 'Type: Yarn',
        'other': 'Type: Other',
      },
      name: 'types',
      desc: '',
      args: [choice],
    );
  }

  /// `Figures`
  String get figures {
    return Intl.message(
      'Figures',
      name: 'figures',
      desc: '',
      args: [],
    );
  }

  /// `Cards`
  String get cards {
    return Intl.message(
      'Cards',
      name: 'cards',
      desc: '',
      args: [],
    );
  }

  /// `Name: {name}`
  String name(Object name) {
    return Intl.message(
      'Name: $name',
      name: 'name',
      desc: '',
      args: [name],
    );
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
    return Intl.message(
      'Game: $game',
      name: 'game',
      desc: '',
      args: [game],
    );
  }

  /// `Type: {type}`
  String type(Object type) {
    return Intl.message(
      'Type: $type',
      name: 'type',
      desc: '',
      args: [type],
    );
  }

  /// `Ascending (A-Z)`
  String get asc {
    return Intl.message(
      'Ascending (A-Z)',
      name: 'asc',
      desc: '',
      args: [],
    );
  }

  /// `Descending (Z-A)`
  String get desc {
    return Intl.message(
      'Descending (Z-A)',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get sortName {
    return Intl.message(
      'Name',
      name: 'sortName',
      desc: '',
      args: [],
    );
  }

  /// `Australia`
  String get au {
    return Intl.message(
      'Australia',
      name: 'au',
      desc: '',
      args: [],
    );
  }

  /// `Europe`
  String get eu {
    return Intl.message(
      'Europe',
      name: 'eu',
      desc: '',
      args: [],
    );
  }

  /// `North America`
  String get na {
    return Intl.message(
      'North America',
      name: 'na',
      desc: '',
      args: [],
    );
  }

  /// `Japan`
  String get jp {
    return Intl.message(
      'Japan',
      name: 'jp',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Sort By`
  String get sort {
    return Intl.message(
      'Sort By',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Sure`
  String get sure {
    return Intl.message(
      'Sure',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Auto`
  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  /// `{choice, select, system {Auto} light {Light} dark {Dark} other {Auto}}`
  String themeMode(Object choice) {
    return Intl.select(
      choice,
      {
        'system': 'Auto',
        'light': 'Light',
        'dark': 'Dark',
        'other': 'Auto',
      },
      name: 'themeMode',
      desc: '',
      args: [choice],
    );
  }

  /// `Theme Mode`
  String get mode {
    return Intl.message(
      'Theme Mode',
      name: 'mode',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get lightTheme {
    return Intl.message(
      'Light Theme',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message(
      'Dark Theme',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get removeTooltip {
    return Intl.message(
      'Remove',
      name: 'removeTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Own`
  String get ownTooltip {
    return Intl.message(
      'Own',
      name: 'ownTooltip',
      desc: '',
      args: [],
    );
  }

  /// `Wish`
  String get wishTooltip {
    return Intl.message(
      'Wish',
      name: 'wishTooltip',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Up',
      name: 'upToolTip',
      desc: '',
      args: [],
    );
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

  /// `Export`
  String get export {
    return Intl.message(
      'Export',
      name: 'export',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: '',
      args: [],
    );
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

  /// `Therms and conditions`
  String get privacySubtitle {
    return Intl.message(
      'Therms and conditions',
      name: 'privacySubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Wait no!',
      name: 'cancel',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Report bug',
      name: 'reportBug',
      desc: '',
      args: [],
    );
  }

  /// `Rate me`
  String get rate {
    return Intl.message(
      'Rate me',
      name: 'rate',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Changelog',
      name: 'changelog',
      desc: '',
      args: [],
    );
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

  /// `{choice, select, granted {Storage permission granted} denied {Storage permission denied} neverAskAgain {Storage permission disabled} restricted {Storage permission restricted} other {Unknown permission access}}`
  String storagePermission(Object choice) {
    return Intl.select(
      choice,
      {
        'granted': 'Storage permission granted',
        'denied': 'Storage permission denied',
        'neverAskAgain': 'Storage permission disabled',
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
    return Intl.message(
      'Created on',
      name: 'createdOn',
      desc: '',
      args: [],
    );
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

  /// `change`
  String get openAppSettings {
    return Intl.message(
      'change',
      name: 'openAppSettings',
      desc: '',
      args: [],
    );
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
    return Intl.message(
      'Share',
      name: 'actionText',
      desc: '',
      args: [],
    );
  }

  /// `Donate`
  String get donate {
    return Intl.message(
      'Donate',
      name: 'donate',
      desc: '',
      args: [],
    );
  }

  /// `{choice, select, true {Locked} false {Unlocked} other {Unknown}}`
  String lockTooltip(Object choice) {
    return Intl.select(
      choice,
      {
        'true': 'Locked',
        'false': 'Unlocked',
        'other': 'Unknown',
      },
      name: 'lockTooltip',
      desc: '',
      args: [choice],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}