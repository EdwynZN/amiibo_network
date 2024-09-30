import 'package:amiibo_network/affiliation_product/presentation/controller/amazon_afilliation_provider.dart';
import 'package:amiibo_network/affiliation_product/presentation/widget/amazon_affiliation_link_selection_bottomsheet.dart';
import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/model/result.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/screenshot_service.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/riverpod/stat_ui_remote_config_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/utils/format_color_on_theme.dart';
import 'package:amiibo_network/widget/feature_disable_message_card.dart';
import 'package:amiibo_network/widget/locale_selection_dialog.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/widget/markdown_widget.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/urls_constants.dart';
import 'package:amiibo_network/service/notification_service.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/widget/selected_chip.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final theme = Theme.of(context);
    const divider = SliverToBoxAdapter(child: Divider(height: 16));
    final Widget body = Scrollbar(
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverGap(16.0),
          const _FeatureListWidget(),
          divider,
          const _AppearanceListWidget(),
          divider,
          const _SupportListWidget(),
          divider,
          const _AboutListWidget(),
          const SliverGap(16.0),
        ],
      ),
    );
    return ListTileTheme.merge(
      iconColor: theme.colorScheme.onSurface,
      textColor: theme.colorScheme.onSurface,
      horizontalTitleGap: 8.0,
      child: Scaffold(
        appBar: AppBar(title: Text(translate.settings)),
        body: IconTheme.merge(
          data: const IconThemeData(size: 18.0),
          child: body,
        ),
      ),
    );
  }
}

class _AppearanceListWidget extends ConsumerWidget {
  // ignore: unused_element
  const _AppearanceListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = ref.watch(personalProvider);
    final S translate = S.of(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList.list(
        children: [
          _TitleSetting(title: translate.appearance),
          const Gap(4.0),
          Consumer(
            builder: (context, ref, _) {
              final mode = ref.watch(themeProvider).preferredMode;
              return _ListSettings(
                title: translate.appearance,
                subtitle: translate.themeMode(mode),
                icon: const Icon(Icons.color_lens_outlined),
                onTap: () => ThemeButton.dialog(context),
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final Locale? locale = ref.watch(localeProvider);
              final String subtitle;
              if (locale != null) {
                subtitle = '(${locale.toLanguageTag().toUpperCase()})';
              } else {
                subtitle =
                    '${translate.system} (${Localizations.localeOf(context).toLanguageTag().toUpperCase()})';
              }
              return _ListSettings(
                title: translate.language,
                subtitle: subtitle,
                icon: const Icon(Icons.language),
                onTap: () async {
                  final localeResult = await showDialog<Result<String?>>(
                    context: context,
                    builder: (context) => const LocaleDialog(),
                  );
                  if (localeResult == null) {
                    return;
                  }
                  ref
                      .read(personalProvider.notifier)
                      .forceLocale(localeResult.data);
                },
              );
            },
          ),
          _SwitchListSettings(
            title: translate.showPercentage,
            icon: const Icon(Icons.percent),
            value: pref.usePercentage,
            onChanged: (value) async =>
                await ref.read(personalProvider.notifier).toggleStat(value),
          ),
          _SwitchListSettings(
            title: translate.showGrid,
            icon: const Icon(Icons.grid_view_outlined),
            value: pref.useGrid,
            onChanged: (value) async => await ref
                .read(personalProvider.notifier)
                .toggleVisualList(value),
          ),
        ],
      ),
    );
  }
}

class _FeatureListWidget extends ConsumerStatefulWidget {
  // ignore: unused_element
  const _FeatureListWidget({super.key});

  @override
  ConsumerState<_FeatureListWidget> createState() => _FeatureListWidgetState();
}

class _FeatureListWidgetState extends ConsumerState<_FeatureListWidget> {
  late ThemeData theme;
  late S translate;
  ScaffoldMessengerState? scaffoldState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    theme = Theme.of(context);
    scaffoldState = ScaffoldMessenger.maybeOf(context);
  }

  void openSnackBar(String message, {SnackBarAction? action}) {
    if (!(scaffoldState?.mounted ?? false)) return;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(
      content: Text(message),
      action: action,
    ));
  }

  Future<void> _openFileExplorer() async {
    try {
      final service = ref.read(serviceProvider.notifier);
      final file = await FilePicker.platform.pickFiles(
        type: FileType.any,
        //allowedExtensions: ['json'],
      );
      final String? _path = file?.files.single.path;
      if (_path == null)
        return;
      else if (file?.files.single.extension != 'json') {
        openSnackBar(translate.errorImporting);
      } else {
        //final Uint8List data = file!.files.single.bytes!;
        final AmiiboFile amiiboFile = await compute(readFile, _path);
        if (amiiboFile is AmiiboFileError) {
          FirebaseCrashlytics.instance.recordError(
            amiiboFile.error,
            amiiboFile.stackTrace,
          );
          openSnackBar(translate.errorImporting);
          return;
        }
        await service
            .update((amiiboFile as AmiiboFileData).amiibosUserAttributes);
        openSnackBar(translate.successImport);
      }
      await FilePicker.platform.clearTemporaryFiles();
    } on PlatformException catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      debugPrint(e.message);
      openSnackBar(translate.storagePermission('denied'));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      openSnackBar(translate.errorImporting);
    }
  }

  Future<void> _writePermission() async {
    try {
      if (!(await permissionGranted(scaffoldState))) return;
      final _service = ref.read(serviceProvider.notifier);
      final amiibos = await _service.fetchAllAmiibo();
      openSnackBar(translate.savingCollectionMessage);
      await NotificationService.saveJsonFile(
        title: translate.notificationTitle,
        actionNotificationTitle: translate.actionText,
        amiibos: amiibos,
        name: 'MyAmiiboNetwork',
      );
      openSnackBar(translate.export_complete);
    } catch (e) {
      openSnackBar(translate.storagePermission('denied'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownedCategoriesRemote = ref.watch(remoteOwnedCategoryProvider);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList.list(
        children: [
          _TitleSetting(title: S.of(context).features),
          const Gap(4.0),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 450),
            child: const FeatureDisableMessageCard(),
          ),
          const _ResetCollection(),
          const _SaveCollection(),
          _ListSettings(
            title: translate.export,
            subtitle: translate.export_subtitle,
            icon: const ImageIcon(AssetImage(NetworkIcons.fileExport)),
            onTap: _writePermission,
          ),
          _ListSettings(
            title: translate.import,
            subtitle: translate.import_subtitle,
            icon: const ImageIcon(AssetImage(NetworkIcons.fileImport)),
            onTap: _openFileExplorer,
          ),
          if (ownedCategoriesRemote)
            _SwitchListSettings(
              title: translate.showOwnerCategories,
              icon: const ImageIcon(AssetImage(NetworkIcons.openBox)),
              subtitle: translate.showOwnerCategoriesDetails,
              value: ref.watch(ownTypesCategoryProvider),
              onChanged: (value) async => await ref
                  .read(personalProvider.notifier)
                  .toggleOwnType(value),
            ),
          _SwitchListSettings(
            title: translate.use_in_app_browser,
            icon: const Icon(Icons.open_in_new),
            subtitle: translate.use_in_app_browser_subtitle,
            value: ref.watch(
              personalProvider.select((userPref) => userPref.inAppBrowser),
            ),
            onChanged: ref.read(personalProvider.notifier).toogleInAppBrowser,
          ),
          Consumer(
            builder: (context, ref, _) {
              final selected = ref.watch(selectedAmazonAffiliationProvider);
              return _ListSettings(
                title: translate.amazon_link_setting,
                subtitle: selected == null
                  ? translate.amazon_link_setting_subtitle
                  : selected.link.toString(),
                icon: const ImageIcon(AssetImage(NetworkIcons.amazon)),
                onTap: () async {
                  final result = await amazonLinkBottomSheet(
                    context,
                    showSelected: true,
                  );
                  if (result != null) {
                    ref
                        .read(personalProvider.notifier)
                        .changeAmazonCountryCode(result.result?.countryCode);
                  }
                },
              );
            },
          ),
          const Gap(4.0),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 400, maxWidth: 450),
              child: Card(
                elevation: 1.0,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: _TitleSetting(
                          title: translate.amiibo_type.toUpperCase(),
                        ),
                      ),
                      const Gap(8.0),
                      Consumer(
                        builder: (context, ref, _) {
                          final category = ref.watch(hiddenCategoryProvider);
                          return SegmentedButton<HiddenType>(
                            emptySelectionAllowed: false,
                            multiSelectionEnabled: true,
                            segments: <ButtonSegment<HiddenType>>[
                              ButtonSegment<HiddenType>(
                                value: HiddenType.Figures,
                                label: Text(translate.figures),
                                icon: const ImageIcon(
                                  AssetImage('assets/collection/icon_1.webp'),
                                ),
                              ),
                              ButtonSegment<HiddenType>(
                                value: HiddenType.Cards,
                                label: Text(translate.cards),
                                icon: const Icon(Icons.view_carousel),
                              ),
                            ],
                            selected: <HiddenType>{
                              if (category != HiddenType.Figures)
                                HiddenType.Figures,
                              if (category != HiddenType.Cards)
                                HiddenType.Cards,
                            },
                            onSelectionChanged: (newSelection) {
                              HiddenType? newCategory;
                              if (newSelection.length == 1) {
                                newCategory =
                                    newSelection.first == HiddenType.Cards
                                        ? HiddenType.Figures
                                        : HiddenType.Cards;
                              }
                              ref
                                  .read(personalProvider.notifier)
                                  .updateIgnoredList(newCategory);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutListWidget extends StatelessWidget {
  // ignore: unused_element
  const _AboutListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = S.of(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList.list(
        children: [
          _TitleSetting(title: translate.about),
          const Gap(4.0),
          _ListSettings(
            title: translate.changelog,
            subtitle: translate.changelogSubtitle,
            icon: const Icon(Icons.build_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => MarkdownReader(
                  file: translate.changelog.replaceAll(' ', '_'),
                  title: translate.changelogSubtitle,
                ),
              );
            },
          ),
          _ListSettings(
            title: translate.credits,
            subtitle: translate.creditsSubtitle,
            icon: const Icon(Icons.theaters_outlined),
            onTap: () => showDialog(
              context: context,
              builder: (context) => MarkdownReader(
                file: 'Credits',
                title: translate.creditsSubtitle,
              ),
            ),
          ),
          _ListSettings(
            title: translate.privacyPolicy,
            subtitle: translate.privacySubtitle,
            icon: const Icon(Icons.policy_outlined),
            onTap: () => showDialog(
              context: context,
              builder: (context) => MarkdownReader(
                file: translate.privacyPolicy.replaceAll(' ', '_'),
                title: translate.privacySubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportListWidget extends ConsumerWidget {
  // ignore: unused_element
  const _SupportListWidget({super.key});

  Future<void> _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).couldNotLaunchUrl(url))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = S.of(context);
    final mediaBrightness = MediaQuery.of(context).platformBrightness;
    final themeMode = ref.watch(themeProvider.select((t) => t.preferredMode));
    final color = colorOnThemeMode(themeMode, mediaBrightness);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList.list(
        children: [
          _TitleSetting(title: translate.support),
          const Gap(4.0),
          _ListSettings(
            title: 'Github',
            icon: const ImageIcon(AssetImage(NetworkIcons.github)),
            onTap: () => _launchURL(github, context),
          ),
          _ListSettings(
            title: translate.reportBug,
            icon: const Icon(Icons.bug_report_outlined),
            onTap: () => _launchURL(reportIssue, context),
          ),
          _ListSettings(
            title: translate.rate,
            icon: Image.asset(
              NetworkIcons.iconApp,
              height: 24,
              width: 24,
              fit: BoxFit.fill,
              colorBlendMode: BlendMode.srcATop,
              color: color,
            ),
            onTap: LaunchReview.launch,
          ),
          _ListSettings(
            title: translate.donate,
            icon: Image.asset(
              NetworkIcons.koFiIcon,
              height: 24,
              width: 24,
              fit: BoxFit.fill,
              colorBlendMode: BlendMode.srcATop,
              color: color,
            ),
            onTap: () => _launchURL(reportIssue, context),
          ),
        ],
      ),
    );
  }
}

class _SaveCollection extends ConsumerStatefulWidget {
  const _SaveCollection({Key? key}) : super(key: key);

  @override
  __SaveCollectionState createState() => __SaveCollectionState();
}

class __SaveCollectionState extends ConsumerState<_SaveCollection> {
  late S translate;
  ScaffoldMessengerState? scaffoldState;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    scaffoldState = ScaffoldMessenger.maybeOf(context);
  }

  Future<void> _saveCollection(
    AmiiboCategory category,
    List<String> figures,
    List<String> cards,
  ) async {
    final _screenshot = ref.read(screenshotProvider.notifier);
    final String message = _screenshot.isLoading
        ? translate.recordMessage
        : translate.savingCollectionMessage;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
    if (!_screenshot.isLoading) {
      await _screenshot.saveAmiibos(
        context,
        search: Search(
          categoryAttributes: CategoryAttributes(
            category: category,
            cards: cards,
            figures: figures,
          ),
        ),
        useHidden: false,
      );
      if (mounted) {
        scaffoldState?.showSnackBar(
          SnackBar(content: Text(translate.export_complete)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ListSettings(
      title: translate.saveCollection,
      subtitle: translate.saveCollectionSubtitle,
      icon: const ImageIcon(AssetImage(NetworkIcons.jpg)),
      onTap: () async {
        if (!(await permissionGranted(scaffoldState))) return;
        final hidden = ref.watch(hiddenCategoryProvider);
        final isFiguresShown = hidden == null || hidden != HiddenType.Figures;
        final isCardsShown = hidden == null || hidden != HiddenType.Cards;
        final filter = ref.read(queryProvider.notifier);
        final List<String> figures =
            isFiguresShown ? filter.customFigures.toList() : [];
        final List<String> cards =
            isCardsShown ? filter.customCards.toList() : [];
        bool save = await showDialog<bool>(
              context: context,
              builder: (_) => CustomQueryWidget(
                translate.saveCollection,
                figures: figures,
                cards: cards,
              ),
            ) ??
            false;
        if (save && (figures.isNotEmpty || cards.isNotEmpty)) {
          bool equalFigures = false;
          bool equalCards = false;
          AmiiboCategory category = AmiiboCategory.All;
          final listOfFigures = await ref.read(figuresProvider.future);
          final listOfCards = await ref.read(cardsProvider.future);
          if (figures.isNotEmpty) {
            equalFigures =
                QueryBuilderProvider.checkEquality(figures, listOfFigures);
          }
          if (cards.isNotEmpty) {
            equalCards = QueryBuilderProvider.checkEquality(cards, listOfCards);
          }
          if (equalFigures && cards.isEmpty) {
            category = AmiiboCategory.Figures;
          } else if (equalCards && figures.isEmpty) {
            category = AmiiboCategory.Cards;
          } else if (!equalCards || !equalFigures) {
            category = AmiiboCategory.AmiiboSeries;
          }
          await _saveCollection(category, figures, cards);
        }
      },
    );
  }
}

class _ResetCollection extends ConsumerWidget {
  const _ResetCollection({Key? key}) : super(key: key);

  Future<bool?> _dialog(BuildContext context) async {
    final S translate = S.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate.resetTitleDialog),
          titlePadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          content: Text(translate.resetContent),
          actions: <Widget>[
            TextButton(
              child: Text(translate.cancel),
              onPressed: Navigator.of(context).pop,
            ),
            TextButton(
              child: Text(translate.sure),
              onPressed: () async => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  void _message(ScaffoldMessengerState? scaffoldState, String message) {
    if (!(scaffoldState?.mounted ?? false)) return;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    return _ListSettings(
      title: translate.reset,
      subtitle: translate.resetSubtitle,
      icon: const Icon(Icons.restart_alt),
      onTap: () async {
        final bool? reset = await _dialog(context);
        if (reset ?? false) {
          final ScaffoldMessengerState? scaffoldState =
              ScaffoldMessenger.maybeOf(context)!;
          try {
            await ref.read(serviceProvider.notifier).resetCollection();
            _message(scaffoldState, translate.collectionReset);
          } catch (e) {
            _message(scaffoldState, translate.splashError);
          }
        }
      },
    );
  }
}

class _SwitchListSettings extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  _SwitchListSettings({
    // ignore: unused_element
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTileTheme.merge(
      minVerticalPadding: 12.0,
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.only(left: 16.0, right: 8.0),
        value: value,
        onChanged: onChanged,
        visualDensity:
            subtitle == null ? null : const VisualDensity(vertical: -2.5),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 0.1,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: -0.1,
                  fontWeight: FontWeight.normal,
                ),
              ),
        secondary: icon,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}

class _ListSettings extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;

  _ListSettings({
    // ignore: unused_element
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      minVerticalPadding: 12.0,
      visualDensity:
          subtitle == null ? null : const VisualDensity(vertical: -2.5),
      title: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          letterSpacing: 0.1,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: -0.1,
                fontWeight: FontWeight.normal,
              ),
            ),
      onTap: onTap,
      leading: icon,
    );
  }
}

class _TitleSetting extends StatelessWidget {
  final String title;

  // ignore: unused_element
  const _TitleSetting({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.start,
      maxLines: 1,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
