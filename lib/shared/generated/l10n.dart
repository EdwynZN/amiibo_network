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
      desc: 'Splash screen loading message',
      args: [],
    );
  }

  /// `WELCOME`
  String get splashWelcome {
    return Intl.message(
      'WELCOME',
      name: 'splashWelcome',
      desc: 'Splash screen welcome title',
      args: [],
    );
  }

  /// `Couldn't Update ☹`
  String get splashError {
    return Intl.message(
      'Couldn\'t Update ☹',
      name: 'splashError',
      desc: 'Splash screen error message when update fails',
      args: [],
    );
  }

  /// `Show percentage`
  String get showPercentage {
    return Intl.message(
      'Show percentage',
      name: 'showPercentage',
      desc: 'Setting option label to display stats as percentages',
      args: [],
    );
  }

  /// `Show owner categories`
  String get showOwnerCategories {
    return Intl.message(
      'Show owner categories',
      name: 'showOwnerCategories',
      desc: 'Setting option label to show boxed/unboxed categories',
      args: [],
    );
  }

  /// `Allow to visualize owned amiibos by boxed/unboxed`
  String get showOwnerCategoriesDetails {
    return Intl.message(
      'Allow to visualize owned amiibos by boxed/unboxed',
      name: 'showOwnerCategoriesDetails',
      desc: 'Detailed description for showOwnerCategories setting',
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
      desc: 'Category filter selection options',
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
      desc: 'Search category filter options',
      args: [choice],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: 'Label for all item category',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: 'Label for total count in stats',
      args: [],
    );
  }

  /// `Remaining`
  String get remaining {
    return Intl.message(
      'Remaining',
      name: 'remaining',
      desc: 'Label for remaining item count',
      args: [],
    );
  }

  /// `Owned`
  String get owned {
    return Intl.message(
      'Owned',
      name: 'owned',
      desc: 'Label for owned amiibos category',
      args: [],
    );
  }

  /// `Boxed`
  String get boxed {
    return Intl.message(
      'Boxed',
      name: 'boxed',
      desc: 'Label for boxed amiibos status',
      args: [],
    );
  }

  /// `Unboxed`
  String get unboxed {
    return Intl.message(
      'Unboxed',
      name: 'unboxed',
      desc: 'Label for unboxed amiibos status',
      args: [],
    );
  }

  /// `Wished`
  String get wished {
    return Intl.message(
      'Wished',
      name: 'wished',
      desc: 'Label for wished amiibos category',
      args: [],
    );
  }

  /// `Stats`
  String get stats {
    return Intl.message(
      'Stats',
      name: 'stats',
      desc: 'Title or label for statistics',
      args: [],
    );
  }

  /// `{choice, select, Figure {Figure} Card {Card} Yarn {Yarn} Band {Band} other {Other}}`
  String types(String choice) {
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
      desc: 'Amiibo item types',
      args: [choice],
    );
  }

  /// `Figures`
  String get figures {
    return Intl.message(
      'Figures',
      name: 'figures',
      desc: 'Label for figures type group',
      args: [],
    );
  }

  /// `Cards`
  String get cards {
    return Intl.message(
      'Cards',
      name: 'cards',
      desc: 'Label for cards type group',
      args: [],
    );
  }

  /// `Name: {name}`
  String name(String name) {
    return Intl.message(
      'Name: $name',
      name: 'name',
      desc: 'Label displaying amiibo name',
      args: [name],
    );
  }

  /// `Character: {character}`
  String character(String character) {
    return Intl.message(
      'Character: $character',
      name: 'character',
      desc: 'Label displaying character name',
      args: [character],
    );
  }

  /// `Serie: {serie}`
  String serie(String serie) {
    return Intl.message(
      'Serie: $serie',
      name: 'serie',
      desc: 'Label displaying amiibo series',
      args: [serie],
    );
  }

  /// `Game: {game}`
  String game(String game) {
    return Intl.message(
      'Game: $game',
      name: 'game',
      desc: 'Label displaying game name',
      args: [game],
    );
  }

  /// `Type: {type}`
  String type(String type) {
    return Intl.message(
      'Type: $type',
      name: 'type',
      desc: 'Label displaying amiibo type',
      args: [type],
    );
  }

  /// `Ascending (A-Z)`
  String get asc {
    return Intl.message(
      'Ascending (A-Z)',
      name: 'asc',
      desc: 'Sorting option for ascending order',
      args: [],
    );
  }

  /// `Descending (Z-A)`
  String get desc {
    return Intl.message(
      'Descending (Z-A)',
      name: 'desc',
      desc: 'Sorting option for descending order',
      args: [],
    );
  }

  /// `Name`
  String get sortName {
    return Intl.message(
      'Name',
      name: 'sortName',
      desc: 'Sorting criteria name',
      args: [],
    );
  }

  /// `Australia`
  String get au {
    return Intl.message(
      'Australia',
      name: 'au',
      desc: 'Region name for Australia',
      args: [],
    );
  }

  /// `Europe`
  String get eu {
    return Intl.message(
      'Europe',
      name: 'eu',
      desc: 'Region name for Europe',
      args: [],
    );
  }

  /// `North America`
  String get na {
    return Intl.message(
      'North America',
      name: 'na',
      desc: 'Region name for North America',
      args: [],
    );
  }

  /// `Japan`
  String get jp {
    return Intl.message(
      'Japan',
      name: 'jp',
      desc: 'Region name for Japan',
      args: [],
    );
  }

  /// `Card number`
  String get cardNumber {
    return Intl.message(
      'Card number',
      name: 'cardNumber',
      desc: 'Label for card number field',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Title for settings page or menu',
      args: [],
    );
  }

  /// `Sort By`
  String get sort {
    return Intl.message(
      'Sort By',
      name: 'sort',
      desc: 'Label or header for sort options',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: 'Button label for completing action',
      args: [],
    );
  }

  /// `Sure`
  String get sure {
    return Intl.message(
      'Sure',
      name: 'sure',
      desc: 'Confirmation button label',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: 'Light theme mode option label',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: 'Dark theme mode option label',
      args: [],
    );
  }

  /// `System`
  String get auto {
    return Intl.message(
      'System',
      name: 'auto',
      desc: 'System default theme mode option label',
      args: [],
    );
  }

  /// `{choice, select, system {System} light {Light} dark {Dark} other {Auto}}`
  String themeMode(Object choice) {
    return Intl.select(
      choice,
      {'system': 'System', 'light': 'Light', 'dark': 'Dark', 'other': 'Auto'},
      name: 'themeMode',
      desc: 'Theme selection mode options',
      args: [choice],
    );
  }

  /// `Theme Mode`
  String get mode {
    return Intl.message(
      'Theme Mode',
      name: 'mode',
      desc: 'Theme mode settings header',
      args: [],
    );
  }

  /// `Light Theme`
  String get lightTheme {
    return Intl.message(
      'Light Theme',
      name: 'lightTheme',
      desc: 'Label for light theme option',
      args: [],
    );
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message(
      'Dark Theme',
      name: 'darkTheme',
      desc: 'Label for dark theme option',
      args: [],
    );
  }

  /// `Remove`
  String get removeTooltip {
    return Intl.message(
      'Remove',
      name: 'removeTooltip',
      desc: 'Tooltip for removing item',
      args: [],
    );
  }

  /// `Own`
  String get ownTooltip {
    return Intl.message(
      'Own',
      name: 'ownTooltip',
      desc: 'Tooltip for marking item as owned',
      args: [],
    );
  }

  /// `Wish`
  String get wishTooltip {
    return Intl.message(
      'Wish',
      name: 'wishTooltip',
      desc: 'Tooltip for marking item on wishlist',
      args: [],
    );
  }

  /// `Save Stats`
  String get saveStatsTooltip {
    return Intl.message(
      'Save Stats',
      name: 'saveStatsTooltip',
      desc: 'Tooltip for saving statistics',
      args: [],
    );
  }

  /// `Up`
  String get upToolTip {
    return Intl.message(
      'Up',
      name: 'upToolTip',
      desc: 'Tooltip for scroll to top action',
      args: [],
    );
  }

  /// `Nothing to see here. . .yet`
  String get emptyPage {
    return Intl.message(
      'Nothing to see here. . .yet',
      name: 'emptyPage',
      desc: 'Empty state display text',
      args: [],
    );
  }

  /// `Create a collection`
  String get emptyPageAction {
    return Intl.message(
      'Create a collection',
      name: 'emptyPageAction',
      desc: 'Action button text on empty state page',
      args: [],
    );
  }

  /// `Export`
  String get export {
    return Intl.message(
      'Export',
      name: 'export',
      desc: 'Button or menu item for data export',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: 'Button or menu item for data import',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: 'Settings section title for app appearance',
      args: [],
    );
  }

  /// `Features`
  String get features {
    return Intl.message(
      'Features',
      name: 'features',
      desc: 'Settings section title for app features',
      args: [],
    );
  }

  /// `More personalization`
  String get appearanceSubtitle {
    return Intl.message(
      'More personalization',
      name: 'appearanceSubtitle',
      desc: 'Subtitle for appearance settings section',
      args: [],
    );
  }

  /// `Credits`
  String get credits {
    return Intl.message(
      'Credits',
      name: 'credits',
      desc: 'Credits page title or menu item',
      args: [],
    );
  }

  /// `Those who make it possible`
  String get creditsSubtitle {
    return Intl.message(
      'Those who make it possible',
      name: 'creditsSubtitle',
      desc: 'Subtitle for credits section',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: 'Privacy policy link or title',
      args: [],
    );
  }

  /// `Terms and conditions`
  String get privacySubtitle {
    return Intl.message(
      'Terms and conditions',
      name: 'privacySubtitle',
      desc: 'Subtitle for privacy policy section',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: 'Reset action title',
      args: [],
    );
  }

  /// `Reset your wishlist and collection`
  String get resetSubtitle {
    return Intl.message(
      'Reset your wishlist and collection',
      name: 'resetSubtitle',
      desc: 'Subtitle explaining reset functionality',
      args: [],
    );
  }

  /// `Reset your collection`
  String get resetTitleDialog {
    return Intl.message(
      'Reset your collection',
      name: 'resetTitleDialog',
      desc: 'Title of reset confirmation dialog',
      args: [],
    );
  }

  /// `Are you sure? This action can't be undone`
  String get resetContent {
    return Intl.message(
      'Are you sure? This action can\'t be undone',
      name: 'resetContent',
      desc: 'Confirmation prompt text in reset dialog',
      args: [],
    );
  }

  /// `Wait no!`
  String get cancel {
    return Intl.message(
      'Wait no!',
      name: 'cancel',
      desc: 'Cancel button text in dialogs',
      args: [],
    );
  }

  /// `Save Collection`
  String get saveCollection {
    return Intl.message(
      'Save Collection',
      name: 'saveCollection',
      desc: 'Button text for saving collection image',
      args: [],
    );
  }

  /// `Create a picture of your collection`
  String get saveCollectionSubtitle {
    return Intl.message(
      'Create a picture of your collection',
      name: 'saveCollectionSubtitle',
      desc: 'Subtitle for saving collection option',
      args: [],
    );
  }

  /// `Select your collection`
  String get saveCollectionTitleDialog {
    return Intl.message(
      'Select your collection',
      name: 'saveCollectionTitleDialog',
      desc: 'Title for collection selection dialog when saving',
      args: [],
    );
  }

  /// `Could not launch {url}`
  String couldNotLaunchUrl(String url) {
    return Intl.message(
      'Could not launch $url',
      name: 'couldNotLaunchUrl',
      desc: 'Error message when URL launcher fails',
      args: [url],
    );
  }

  /// `Report bug`
  String get reportBug {
    return Intl.message(
      'Report bug',
      name: 'reportBug',
      desc: 'Button or link to report a bug',
      args: [],
    );
  }

  /// `Rate me`
  String get rate {
    return Intl.message(
      'Rate me',
      name: 'rate',
      desc: 'Button or link to rate the app',
      args: [],
    );
  }

  /// `What's new`
  String get changelogSubtitle {
    return Intl.message(
      'What\'s new',
      name: 'changelogSubtitle',
      desc: 'Subtitle for changelog section',
      args: [],
    );
  }

  /// `Changelog`
  String get changelog {
    return Intl.message(
      'Changelog',
      name: 'changelog',
      desc: 'Title for changelog section or page',
      args: [],
    );
  }

  /// `There was an error loading the file`
  String get markdownError {
    return Intl.message(
      'There was an error loading the file',
      name: 'markdownError',
      desc: 'Error text when markdown file fails to render',
      args: [],
    );
  }

  /// `{choice, select, granted {Storage permission granted} denied {Storage permission denied} permanentlyDenied {Storage permission denied} restricted {Storage permission restricted} other {Unknown permission access}}`
  String storagePermission(String choice) {
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
      desc: 'Storage permission status messages',
      args: [choice],
    );
  }

  /// `Created on`
  String get createdOn {
    return Intl.message(
      'Created on',
      name: 'createdOn',
      desc: 'Prefix for creation date',
      args: [],
    );
  }

  /// `Collection reset`
  String get collectionReset {
    return Intl.message(
      'Collection reset',
      name: 'collectionReset',
      desc: 'Toast or message after resetting collection',
      args: [],
    );
  }

  /// `Change`
  String get openAppSettings {
    return Intl.message(
      'Change',
      name: 'openAppSettings',
      desc: 'Button label to navigate to app settings',
      args: [],
    );
  }

  /// `Still processing your last file`
  String get recordMessage {
    return Intl.message(
      'Still processing your last file',
      name: 'recordMessage',
      desc: 'Status message while background file processing is active',
      args: [],
    );
  }

  /// `Saving your file. This could take a while depending on your device`
  String get savingCollectionMessage {
    return Intl.message(
      'Saving your file. This could take a while depending on your device',
      name: 'savingCollectionMessage',
      desc: 'Status message while saving collection image',
      args: [],
    );
  }

  /// `This isn't an Amiibo List`
  String get errorImporting {
    return Intl.message(
      'This isn\'t an Amiibo List',
      name: 'errorImporting',
      desc: 'Error message for invalid imported file format',
      args: [],
    );
  }

  /// `Amiibo List updated`
  String get successImport {
    return Intl.message(
      'Amiibo List updated',
      name: 'successImport',
      desc: 'Success message after completing import',
      args: [],
    );
  }

  /// `Export complete`
  String get notificationTitle {
    return Intl.message(
      'Export complete',
      name: 'notificationTitle',
      desc: 'Notification title when export finishes',
      args: [],
    );
  }

  /// `Share`
  String get actionText {
    return Intl.message(
      'Share',
      name: 'actionText',
      desc: 'Generic share action button label',
      args: [],
    );
  }

  /// `Donate`
  String get donate {
    return Intl.message(
      'Donate',
      name: 'donate',
      desc: 'Donate button or link label',
      args: [],
    );
  }

  /// `{choice, select, true {Locked} false {Unlocked} other {Unknown}}`
  String lockTooltip(Object choice) {
    return Intl.select(
      choice,
      {'true': 'Locked', 'false': 'Unlocked', 'other': 'Unknown'},
      name: 'lockTooltip',
      desc: 'Tooltip for lock status',
      args: [choice],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Title for language settings section',
      args: [],
    );
  }

  /// `Choose a language or use it from the system`
  String get languageSubtitle {
    return Intl.message(
      'Choose a language or use it from the system',
      name: 'languageSubtitle',
      desc: 'Subtitle for language settings',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: 'System language option label',
      args: [],
    );
  }

  /// `{choice, select, en {English} es {Spanish} fr {French} de {German} other {Unknown}}`
  String localization(String choice) {
    return Intl.select(
      choice,
      {
        'en': 'English',
        'es': 'Spanish',
        'fr': 'French',
        'de': 'German',
        'other': 'Unknown',
      },
      name: 'localization',
      desc: 'Language name options',
      args: [choice],
    );
  }

  /// `{choice, select, true {Percentage} false {Fraction} other {Unknown}}`
  String statTooltip(Object choice) {
    return Intl.select(
      choice,
      {'true': 'Percentage', 'false': 'Fraction', 'other': 'Unknown'},
      name: 'statTooltip',
      desc: 'Tooltip for stat display format toggle',
      args: [choice],
    );
  }

  /// `Switch`
  String get switch_platform {
    return Intl.message(
      'Switch',
      name: 'switch_platform',
      desc: 'Nintendo Switch console platform name',
      args: [],
    );
  }

  /// `WiiU`
  String get wiiu_platform {
    return Intl.message(
      'WiiU',
      name: 'wiiu_platform',
      desc: 'Wii U console platform name',
      args: [],
    );
  }

  /// `3DS`
  String get console_3DS_platform {
    return Intl.message(
      '3DS',
      name: 'console_3DS_platform',
      desc: 'Nintendo 3DS console platform name',
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
      desc: 'Plural representation of additional amiibo usages in games',
      args: [count],
    );
  }

  /// `Invalid amiibo data`
  String get invalid_amiibo {
    return Intl.message(
      'Invalid amiibo data',
      name: 'invalid_amiibo',
      desc: 'Error text for malformed amiibo item',
      args: [],
    );
  }

  /// `Check your network`
  String get socket_exception {
    return Intl.message(
      'Check your network',
      name: 'socket_exception',
      desc: 'Network connection error message',
      args: [],
    );
  }

  /// `No games found for this amiibo yet`
  String get no_games_found {
    return Intl.message(
      'No games found for this amiibo yet',
      name: 'no_games_found',
      desc: 'Message shown when no compatible games are listed for an amiibo',
      args: [],
    );
  }

  /// `To be announced`
  String get no_date {
    return Intl.message(
      'To be announced',
      name: 'no_date',
      desc: 'Placeholder for unknown or unannounced release date',
      args: [],
    );
  }

  /// `Grid`
  String get showGrid {
    return Intl.message(
      'Grid',
      name: 'showGrid',
      desc: 'Label for grid view toggle option',
      args: [],
    );
  }

  /// `Caution, disabling a feature will hide it from all aspects of the app`
  String get hide_caution {
    return Intl.message(
      'Caution, disabling a feature will hide it from all aspects of the app',
      name: 'hide_caution',
      desc: 'Warning message when turning off feature flags',
      args: [],
    );
  }

  /// `Export completed!`
  String get export_complete {
    return Intl.message(
      'Export completed!',
      name: 'export_complete',
      desc: 'Message shown upon successful export',
      args: [],
    );
  }

  /// `Select a category`
  String get select_user_attribute {
    return Intl.message(
      'Select a category',
      name: 'select_user_attribute',
      desc: 'Instruction label to select user category attribute',
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
      desc: 'Fun empty state text variants based on theme choice',
      args: [choice],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'Title or label for About app section',
      args: [],
    );
  }

  /// `Support`
  String get support {
    return Intl.message(
      'Support',
      name: 'support',
      desc: 'Label for support section',
      args: [],
    );
  }

  /// `Look and feel`
  String get color_mode {
    return Intl.message(
      'Look and feel',
      name: 'color_mode',
      desc: 'Settings title for visual theme preferences',
      args: [],
    );
  }

  /// `Amiibo type`
  String get amiibo_type {
    return Intl.message(
      'Amiibo type',
      name: 'amiibo_type',
      desc: 'Header or label for amiibo product types',
      args: [],
    );
  }

  /// `Save a file of your collection`
  String get export_subtitle {
    return Intl.message(
      'Save a file of your collection',
      name: 'export_subtitle',
      desc: 'Subtitle describing export feature',
      args: [],
    );
  }

  /// `Restore your collection from a file`
  String get import_subtitle {
    return Intl.message(
      'Restore your collection from a file',
      name: 'import_subtitle',
      desc: 'Subtitle describing import feature',
      args: [],
    );
  }

  /// `Dynamic Color`
  String get use_wallpaper {
    return Intl.message(
      'Dynamic Color',
      name: 'use_wallpaper',
      desc: 'Setting title for wallpaper-based dynamic accent colors',
      args: [],
    );
  }

  /// `Use your wallpaper as a palette of colors`
  String get use_wallpaper_subtitle {
    return Intl.message(
      'Use your wallpaper as a palette of colors',
      name: 'use_wallpaper_subtitle',
      desc: 'Subtitle explaining dynamic color feature',
      args: [],
    );
  }

  /// `Open affiliate web pages in app`
  String get use_in_app_browser {
    return Intl.message(
      'Open affiliate web pages in app',
      name: 'use_in_app_browser',
      desc: 'Setting title for in-app browser preference',
      args: [],
    );
  }

  /// `Allow affiliate links to open inside the app`
  String get use_in_app_browser_subtitle {
    return Intl.message(
      'Allow affiliate links to open inside the app',
      name: 'use_in_app_browser_subtitle',
      desc: 'Subtitle for in-app browser preference',
      args: [],
    );
  }

  /// `Amazon site`
  String get amazon_link_setting {
    return Intl.message(
      'Amazon site',
      name: 'amazon_link_setting',
      desc: 'Setting title for Amazon region selection',
      args: [],
    );
  }

  /// `Choose your country-specific Amazon site`
  String get amazon_link_setting_subtitle {
    return Intl.message(
      'Choose your country-specific Amazon site',
      name: 'amazon_link_setting_subtitle',
      desc: 'Subtitle for Amazon region selection',
      args: [],
    );
  }

  /// `No preference`
  String get no_link_selected {
    return Intl.message(
      'No preference',
      name: 'no_link_selected',
      desc: 'Option label when no specific regional link is selected',
      args: [],
    );
  }

  /// `Will be asked each time`
  String get no_link_selected_subtitle {
    return Intl.message(
      'Will be asked each time',
      name: 'no_link_selected_subtitle',
      desc: 'Subtitle explaining no preference behavior',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
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
