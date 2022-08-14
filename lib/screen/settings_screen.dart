import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/riverpod/theme_provider.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/utils/format_color_on_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/widget/markdown_widget.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/urls_constants.dart';
import 'package:amiibo_network/service/notification_service.dart';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/widget/selected_chip.dart';
import 'package:amiibo_network/model/amiibo.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: _DropMenu(key: Key('theme')),
              ),
            )
          ],
          title: Text(translate.settings),
        ),
        body: Scrollbar(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _ResetCollection(),
                  _SaveCollection(),
                  _CardSettings(
                      title: translate.appearance,
                      subtitle: translate.appearanceSubtitle,
                      icon: const Icon(Icons.color_lens),
                      onTap: () => ThemeButton.dialog(context)),
                  _CardSettings(
                    title: translate.changelog,
                    subtitle: translate.changelogSubtitle,
                    icon: const Icon(Icons.build),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => MarkdownReader(
                              file: translate.changelog.replaceAll(' ', '_'),
                              title: translate.changelogSubtitle));
                    },
                  ),
                  _CardSettings(
                      title: translate.credits,
                      subtitle: translate.creditsSubtitle,
                      icon: const Icon(Icons.theaters),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => MarkdownReader(
                              file: 'Credits',
                              title: translate.creditsSubtitle))),
                  _CardSettings(
                      title: translate.privacyPolicy,
                      subtitle: translate.privacySubtitle,
                      icon: const Icon(Icons.help),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => MarkdownReader(
                              file:
                                  translate.privacyPolicy.replaceAll(' ', '_'),
                              title: translate.privacySubtitle))),
                  _ProjectButtons(
                    icons: const <IconData>[Icons.code, Icons.bug_report],
                    titles: <String>['Github', translate.reportBug],
                    urls: const <String>[github, reportIssue],
                  ),
                  _SupportButtons()
                ]),
              ),
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox(
                    height: 0,
                    child: Image.asset(
                      NetworkIcons.iconApp,
                      fit: BoxFit.scaleDown,
                      color: Theme.of(context).colorScheme.brightness ==
                              Brightness.dark
                          ? Colors.white54
                          : null,
                    ),
                  ))
            ],
          ),
        ),
        bottomNavigationBar: const BottomBar(),
      ),
    );
  }
}

class _SupportButtons extends ConsumerWidget {
  Future<void> _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).couldNotLaunchUrl(url))));
    }
  }

  _SupportButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final mediaBrightness = MediaQuery.of(context).platformBrightness;
    final themeMode = ref.watch(themeProvider.select((t) => t.preferredTheme));
    final color = colorOnThemeMode(themeMode, mediaBrightness);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ElevatedButton.icon(
              onPressed: LaunchReview.launch,
              icon: Image.asset(
                NetworkIcons.iconApp,
                height: 30,
                width: 30,
                fit: BoxFit.fill,
                color: color,
              ),
              label: FittedBox(
                child: Text(
                  translate.rate,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ElevatedButton.icon(
              onPressed: () => _launchURL(kofi, context),
              icon: Image.asset(
                NetworkIcons.koFiIcon,
                height: 30,
                width: 30,
                fit: BoxFit.fill,
                colorBlendMode: BlendMode.srcATop,
                color: color,
              ),
              label: FittedBox(
                child: Text(
                  translate.donate,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectButtons extends StatelessWidget {
  final List<IconData> icons;
  final List<String> titles;
  final List<String> urls;

  const _ProjectButtons(
      {required this.icons, required this.titles, required this.urls})
      : assert(icons.length == titles.length && icons.length == urls.length);

  Future<void> _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).couldNotLaunchUrl(url))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int index = 0; index < icons.length; index++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(urls[index], context),
                icon: Icon(icons[index]),
                label: FittedBox(
                  child: Text(
                    titles[index],
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SaveCollection extends ConsumerStatefulWidget {
  _SaveCollection({Key? key}) : super(key: key);

  @override
  __SaveCollectionState createState() => __SaveCollectionState();
}

class __SaveCollectionState extends ConsumerState<_SaveCollection> {
  static final Screenshot _screenshot = Screenshot();
  late S translate;
  ScaffoldMessengerState? scaffoldState;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    scaffoldState = ScaffoldMessenger.maybeOf(context);
  }

  Future<void> _saveCollection(WidgetRef ref, AmiiboCategory category,
      List<String>? figures, cards) async {
    final String message = _screenshot.isRecording
        ? translate.recordMessage
        : translate.savingCollectionMessage;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
    if (!_screenshot.isRecording) {
      String name;
      int id;
      Expression expression;
      switch (category) {
        case AmiiboCategory.Cards:
          name = 'MyCardCollection';
          id = 4;
          expression = Cond.eq('type', 'Card');
          break;
        case AmiiboCategory.Figures:
          name = 'MyFigureCollection';
          expression = InCond.inn('type', figureType);
          id = 5;
          break;
        case AmiiboCategory.Custom:
          name = 'MyCustomCollection';
          id = 8;
          expression = Bracket(InCond.inn('type', figureType) &
                  InCond.inn('amiiboSeries', figures!)) |
              Bracket(
                  Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', cards));
          break;
        case AmiiboCategory.All:
        default:
          name = 'MyAmiiboCollection';
          id = 9;
          expression = And();
          break;
      }
      _screenshot.update(ref, context);
      final buffer = await _screenshot.saveCollection(expression);
      if (buffer != null) {
        final Map<String, dynamic> notificationArgs = <String, dynamic>{
          'title': translate.notificationTitle,
          'actionTitle': translate.actionText,
          'id': id,
          'buffer': buffer,
          'name': '${name}_$dateTaken'
        };
        await NotificationService.saveImage(notificationArgs);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CardSettings(
      title: translate.saveCollection,
      subtitle: translate.saveCollectionSubtitle,
      icon: const Icon(Icons.save),
      onTap: () async {
        if (!(await permissionGranted(scaffoldState))) return;
        final filter = ref.read(queryProvider.notifier);
        final List<String>? figures = filter.customFigures;
        final List<String>? cards = filter.customCards;
        bool save = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) => CustomQueryWidget(
                translate.saveCollection,
                figures: figures,
                cards: cards,
              ),
            ) ??
            false;
        if (save && (figures!.isNotEmpty || cards!.isNotEmpty)) {
          bool? equalFigures = false;
          bool? equalCards = false;
          AmiiboCategory category = AmiiboCategory.All;
          final listOfFigures = await ref.read(figuresProvider.future);
          final listOfCards = await ref.read(cardsProvider.future);
          if (figures.isNotEmpty)
            equalFigures =
                QueryBuilderProvider.checkEquality(figures, listOfFigures);
          if (cards!.isNotEmpty)
            equalCards = QueryBuilderProvider.checkEquality(cards, listOfCards);
          if (equalFigures! && cards.isEmpty)
            category = AmiiboCategory.Figures;
          else if (equalCards! && figures.isEmpty)
            category = AmiiboCategory.Cards;
          else if (!equalCards || !equalFigures)
            category = AmiiboCategory.Custom;
          await _saveCollection(ref, category, figures, cards);
        }
      },
    );
  }
}

class _ResetCollection extends ConsumerWidget {
  _ResetCollection({Key? key}) : super(key: key);

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
    return _CardSettings(
      title: translate.reset,
      subtitle: translate.resetSubtitle,
      icon: const Icon(Icons.warning),
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

class _DropMenu extends ConsumerWidget {
  _DropMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final S translate = S.of(context);
    final themeStyle = Theme.of(context).appBarTheme;
    return DropdownButton<ThemeMode>(
      items: [
        DropdownMenuItem<ThemeMode>(
          value: ThemeMode.system,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const Icon(Icons.brightness_auto, color: Colors.amber),
              Padding(
                  child: Text(translate.themeMode(ThemeMode.system)),
                  padding: const EdgeInsets.only(left: 8))
            ],
          ),
        ),
        DropdownMenuItem<ThemeMode>(
          value: ThemeMode.light,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wb_sunny, color: Colors.amber),
              Padding(
                  child: Text(translate.themeMode(ThemeMode.light)),
                  padding: const EdgeInsets.only(left: 8))
            ],
          ),
        ),
        DropdownMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.brightness_3, color: Colors.amber),
              Padding(
                  child: Text(translate.themeMode(ThemeMode.dark)),
                  padding: EdgeInsets.only(left: 8))
            ],
          ),
        ),
      ],
      onChanged: themeMode.themeDB,
      //underline: const SizedBox.shrink(),
      iconEnabledColor: themeStyle.iconTheme!.color,
      elevation: 4,
      hint: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const Icon(Icons.color_lens),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              translate.themeMode(themeMode.preferredTheme),
              style: themeStyle.toolbarTextStyle,
            ),
          )
        ],
      ),
    );
  }
}

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  late S translate;
  ScaffoldMessengerState? scaffoldState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
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

  Future<void> _openFileExplorer(WidgetRef ref) async {
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
        Map<String, dynamic>? map = await compute(readFile, _path);
        if (map == null)
          openSnackBar(translate.errorImporting);
        else {
          List<Amiibo> amiibos = await compute(entityFromMap, map);
          await service.update(amiibos);
          openSnackBar(translate.successImport);
        }
      }
      await FilePicker.platform.clearTemporaryFiles();
    } on PlatformException catch (e) {
      debugPrint(e.message);
      openSnackBar(translate.storagePermission('denied'));
    }
  }

  Future<void> _writePermission(WidgetRef ref) async {
    try {
      final _service = ref.read(serviceProvider.notifier);
      openSnackBar(translate.savingCollectionMessage);
      final Map<String, dynamic> args = Map<String, dynamic>();
      args['amiibos'] = await _service.fetchAllAmiiboDB();
      final file = await createFile();
      args['file'] = file;
      await compute(writeFile, args);
      final Map<String, dynamic> notificationArgs = <String, dynamic>{
        'title': translate.notificationTitle,
        'path': file.path,
        'actionTitle': translate.actionText,
        'id': 6
      };
      await NotificationService.sendNotification(notificationArgs);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return BottomAppBar(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextButton.icon(
                style: TextButton.styleFrom(
                    minimumSize: Size.fromHeight(48),
                    shape: BeveledRectangleBorder(),
                    primary: Theme.of(context).textTheme.headline6!.color,
                    backgroundColor: Theme.of(context).cardColor),
                onPressed: () async => await _writePermission(ref),
                icon: const Icon(Icons.file_upload),
                label: Text(translate.export)),
          ),
          const Padding(padding: const EdgeInsets.symmetric(horizontal: 0.5)),
          Expanded(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  shape: BeveledRectangleBorder(),
                  primary: Theme.of(context).textTheme.headline6!.color,
                  backgroundColor: Theme.of(context).cardColor),
              onPressed: () async => await _openFileExplorer(ref),
              icon: const Icon(Icons.file_download),
              label: Text(translate.import),
            ),
          )
        ],
      ),
    );
  }
}

class _CardSettings extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;

  _CardSettings({Key? key, this.title, this.subtitle, this.icon, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTileTheme(
      iconColor: Theme.of(context).iconTheme.color,
      textColor: Theme.of(context).textTheme.bodyText2!.color,
      child: Material(
        color: Colors.transparent,
        shape: Theme.of(context).cardTheme.shape,
        clipBehavior: Clip.hardEdge,
        child: ListTile(
            title: Text(title!),
            subtitle: subtitle == null
                ? null
                : Text(subtitle!,
                    softWrap: false, overflow: TextOverflow.ellipsis),
            onTap: onTap,
            leading: Container(
              padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          width: 1, color: Theme.of(context).dividerColor))),
              child: icon,
            )),
      ),
    ));
  }
}
