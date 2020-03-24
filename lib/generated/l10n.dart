// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S(this.localeName);
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S(localeName);
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  final String localeName;

  String get splashMessage {
    return Intl.message(
      'Just a second . . .',
      name: 'splashMessage',
      desc: '',
      args: [],
    );
  }

  String get splashWelcome {
    return Intl.message(
      'WELCOME',
      name: 'splashWelcome',
      desc: '',
      args: [],
    );
  }

  String get splashError {
    return Intl.message(
      'Couldn\'t Update ☹',
      name: 'splashError',
      desc: '',
      args: [],
    );
  }

  String get showPercentage {
    return Intl.message(
      'Show percentage',
      name: 'showPercentage',
      desc: '',
      args: [],
    );
  }

  String category(dynamic choice) {
    return Intl.message(
      '{choice, select, All {All} Owned {Owned} Wishlist {Wishlist} Name {Name} Game {Game} AmiiboSeries {Serie} Figures {All Figures} Cards {All Cards} other {{choice}}}',
      name: 'category',
      desc: '',
      args: [choice],
    );
  }

  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  String get owned {
    return Intl.message(
      'Owned',
      name: 'owned',
      desc: '',
      args: [],
    );
  }

  String get wished {
    return Intl.message(
      'Wished',
      name: 'wished',
      desc: '',
      args: [],
    );
  }

  String get stats {
    return Intl.message(
      'Stats',
      name: 'stats',
      desc: '',
      args: [],
    );
  }

  String types(dynamic choice) {
    return Intl.message(
      '{choice, select, Figure {Type: Figure} Card {Type: Card} Yarn {Type: Yarn} other {Type: Other}}',
      name: 'types',
      desc: '',
      args: [choice],
    );
  }

  String get figures {
    return Intl.message(
      'Figures',
      name: 'figures',
      desc: '',
      args: [],
    );
  }

  String get cards {
    return Intl.message(
      'Cards',
      name: 'cards',
      desc: '',
      args: [],
    );
  }

  String name(dynamic name) {
    return Intl.message(
      'Name: $name',
      name: 'name',
      desc: '',
      args: [name],
    );
  }

  String character(dynamic character) {
    return Intl.message(
      'Character: $character',
      name: 'character',
      desc: '',
      args: [character],
    );
  }

  String serie(dynamic serie) {
    return Intl.message(
      'Serie: $serie',
      name: 'serie',
      desc: '',
      args: [serie],
    );
  }

  String game(dynamic game) {
    return Intl.message(
      'Game: $game',
      name: 'game',
      desc: '',
      args: [game],
    );
  }

  String type(dynamic type) {
    return Intl.message(
      'Type: $type',
      name: 'type',
      desc: '',
      args: [type],
    );
  }

  String get asc {
    return Intl.message(
      'Ascending (A-Z)',
      name: 'asc',
      desc: '',
      args: [],
    );
  }

  String get desc {
    return Intl.message(
      'Descending (Z-A)',
      name: 'desc',
      desc: '',
      args: [],
    );
  }

  String get sortName {
    return Intl.message(
      'Name',
      name: 'sortName',
      desc: '',
      args: [],
    );
  }

  String get au {
    return Intl.message(
      'Australia',
      name: 'au',
      desc: '',
      args: [],
    );
  }

  String get eu {
    return Intl.message(
      'Europe',
      name: 'eu',
      desc: '',
      args: [],
    );
  }

  String get na {
    return Intl.message(
      'North America',
      name: 'na',
      desc: '',
      args: [],
    );
  }

  String get jp {
    return Intl.message(
      'Japan',
      name: 'jp',
      desc: '',
      args: [],
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  String get sort {
    return Intl.message(
      'Sort By',
      name: 'sort',
      desc: '',
      args: [],
    );
  }

  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  String get sure {
    return Intl.message(
      'Sure',
      name: 'sure',
      desc: '',
      args: [],
    );
  }

  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  String get auto {
    return Intl.message(
      'Auto',
      name: 'auto',
      desc: '',
      args: [],
    );
  }

  String themeMode(dynamic choice) {
    return Intl.message(
      '{choice, select, system {Auto} light {Light} dark {Dark} other {Auto}}',
      name: 'themeMode',
      desc: '',
      args: [choice],
    );
  }

  String get mode {
    return Intl.message(
      'Theme Mode',
      name: 'mode',
      desc: '',
      args: [],
    );
  }

  String get lightTheme {
    return Intl.message(
      'Light Theme',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  String get darkTheme {
    return Intl.message(
      'Dark Theme',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  String get removeTooltip {
    return Intl.message(
      'Remove',
      name: 'removeTooltip',
      desc: '',
      args: [],
    );
  }

  String get ownTooltip {
    return Intl.message(
      'Own',
      name: 'ownTooltip',
      desc: '',
      args: [],
    );
  }

  String get wishTooltip {
    return Intl.message(
      'Wish',
      name: 'wishTooltip',
      desc: '',
      args: [],
    );
  }

  String get saveStatsTooltip {
    return Intl.message(
      'Save Stats',
      name: 'saveStatsTooltip',
      desc: '',
      args: [],
    );
  }

  String get upToolTip {
    return Intl.message(
      'Up',
      name: 'upToolTip',
      desc: '',
      args: [],
    );
  }

  String get emptyPage {
    return Intl.message(
      'Nothing to see here. . .yet',
      name: 'emptyPage',
      desc: '',
      args: [],
    );
  }

  String get export {
    return Intl.message(
      'Export',
      name: 'export',
      desc: '',
      args: [],
    );
  }

  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: '',
      args: [],
    );
  }

  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  String get appearanceSubtitle {
    return Intl.message(
      'More personalization',
      name: 'appearanceSubtitle',
      desc: '',
      args: [],
    );
  }

  String get credits {
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: '',
      args: [],
    );
  }

  String get creditsSubtitle {
    return Intl.message(
      'Those who make it possible',
      name: 'creditsSubtitle',
      desc: '',
      args: [],
    );
  }

  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  String get privacySubtitle {
    return Intl.message(
      'Therms and conditions',
      name: 'privacySubtitle',
      desc: '',
      args: [],
    );
  }

  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  String get resetSubtitle {
    return Intl.message(
      'Reset your wishlist and collection',
      name: 'resetSubtitle',
      desc: '',
      args: [],
    );
  }

  String get resetTitleDialog {
    return Intl.message(
      'Reset your collection',
      name: 'resetTitleDialog',
      desc: '',
      args: [],
    );
  }

  String get resetContent {
    return Intl.message(
      'Are you sure? This action can\'t be undone',
      name: 'resetContent',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'Wait no!',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get saveCollection {
    return Intl.message(
      'Save Collection',
      name: 'saveCollection',
      desc: '',
      args: [],
    );
  }

  String get saveCollectionSubtitle {
    return Intl.message(
      'Create a picture of your collection',
      name: 'saveCollectionSubtitle',
      desc: '',
      args: [],
    );
  }

  String get saveCollectionTitleDialog {
    return Intl.message(
      'Select your collection',
      name: 'saveCollectionTitleDialog',
      desc: '',
      args: [],
    );
  }

  String couldNotLaunchUrl(dynamic url) {
    return Intl.message(
      'Could not launch $url',
      name: 'couldNotLaunchUrl',
      desc: '',
      args: [url],
    );
  }

  String get reportBug {
    return Intl.message(
      'Report bug',
      name: 'reportBug',
      desc: '',
      args: [],
    );
  }

  String get rate {
    return Intl.message(
      'Rate me',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  String get changelogSubtitle {
    return Intl.message(
      'What\'s new',
      name: 'changelogSubtitle',
      desc: '',
      args: [],
    );
  }

  String get changelog {
    return Intl.message(
      'Changelog',
      name: 'changelog',
      desc: '',
      args: [],
    );
  }

  String get markdownError {
    return Intl.message(
      'There was an error loading the file',
      name: 'markdownError',
      desc: '',
      args: [],
    );
  }

  String storagePermission(dynamic choice) {
    return Intl.message(
      '{choice, select, granted {Storage permission granted} denied {Storage permission denied} neverAskAgain {Storage permission disabled} restricted {Storage permission restricted} other {Unknown permission access}}',
      name: 'storagePermission',
      desc: '',
      args: [choice],
    );
  }

  String get createdOn {
    return Intl.message(
      'Created on',
      name: 'createdOn',
      desc: '',
      args: [],
    );
  }

  String get collectionReset {
    return Intl.message(
      'Collection reset',
      name: 'collectionReset',
      desc: '',
      args: [],
    );
  }

  String get openAppSettings {
    return Intl.message(
      'change',
      name: 'openAppSettings',
      desc: '',
      args: [],
    );
  }

  String get recordMessage {
    return Intl.message(
      'Still processing your last file',
      name: 'recordMessage',
      desc: '',
      args: [],
    );
  }

  String get savingCollectionMessage {
    return Intl.message(
      'Saving your file. This could take a while depending on your device',
      name: 'savingCollectionMessage',
      desc: '',
      args: [],
    );
  }

  String get errorImporting {
    return Intl.message(
      'This isn\'t an Amiibo List',
      name: 'errorImporting',
      desc: '',
      args: [],
    );
  }

  String get successImport {
    return Intl.message(
      'Amiibo List updated',
      name: 'successImport',
      desc: '',
      args: [],
    );
  }

  String get saved {
    return Intl.message(
      'saved',
      name: 'saved',
      desc: '',
      args: [],
    );
  }

  String get overwritten {
    return Intl.message(
      'overwritten',
      name: 'overwritten',
      desc: '',
      args: [],
    );
  }

  String get fileSaved {
    return Intl.message(
      'Your file has been',
      name: 'fileSaved',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'), Locale.fromSubtags(languageCode: 'es'),
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
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}