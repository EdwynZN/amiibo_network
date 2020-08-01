import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:amiibo_network/provider/query_provider.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/utils/amiibo_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/widget/markdown_widget.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/urls_constants.dart';
import 'package:amiibo_network/service/notification_service.dart';
import 'package:amiibo_network/model/query_builder.dart';
import '../widget/selected_chip.dart';

class SettingsPage extends StatelessWidget{
  const SettingsPage({Key key}): super(key: key);

  @override
  Widget build(BuildContext context){
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
                  _CardSettings(title: translate.appearance, subtitle: translate.appearanceSubtitle, icon: const Icon(Icons.color_lens),
                      onTap: () => ThemeButton.dialog(context)
                  ),
                  _CardSettings(
                    title: translate.changelog,
                    subtitle: translate.changelogSubtitle,
                    icon: const Icon(Icons.build),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => MarkdownReader(
                              file: translate.changelog,
                              title: translate.changelogSubtitle
                          )
                      );
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
                              title: translate.creditsSubtitle
                          )
                      )
                  ),
                  _CardSettings(
                    title: translate.privacyPolicy,
                    subtitle: translate.privacySubtitle,
                    icon: const Icon(Icons.help),
                    onTap: () => showDialog(
                        context: context,
                        builder: (context) => MarkdownReader(
                            file: translate.privacyPolicy.replaceAll(' ', '_'),
                            title: translate.privacySubtitle
                        )
                    )
                  ),
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
                    child: Image.asset('assets/images/icon_app.png',
                      fit: BoxFit.scaleDown,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54 : null,
                    ),
                  )
              )
            ],
          )
        ),
        bottomNavigationBar: BottomBar()
      )
    );
  }
}

class _SupportButtons extends StatelessWidget{
  Future<void> _launchURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(S.of(context).couldNotLaunchUrl(url))));
    }
  }

  _SupportButtons({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Card(
            child: FlatButton.icon(
              onPressed: LaunchReview.launch,
              icon: Image.asset('assets/images/icon_app.png',
                height: 30, width: 30, fit: BoxFit.fill,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54 : null,
              ),
              label: Flexible(child: FittedBox(child: Text(translate.rate, style: Theme.of(context).textTheme.bodyText1, overflow: TextOverflow.fade,),))
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: FlatButton.icon(
              onPressed: () => _launchURL(kofi, context),
              icon: Image.asset('assets/images/ko-fi_icon.png',
                height: 30, width: 30, fit: BoxFit.fill,
                colorBlendMode: BlendMode.srcATop,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black38 : null,
              ),
              label: Flexible(child: FittedBox(child: Text(translate.donate, style: Theme.of(context).textTheme.bodyText1, overflow: TextOverflow.fade,),))
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectButtons extends StatelessWidget{
  final List<IconData> icons;
  final List<String> titles;
  final List<String> urls;

  const _ProjectButtons({this.icons, this.titles, this.urls})
    : assert(icons.length == titles.length && icons.length == urls.length);
  Future<void> _launchURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(S.of(context).couldNotLaunchUrl(url))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for(int index = 0; index < icons.length ;index++)
          Expanded(
            child: Card(
              child: FlatButton.icon(
                onPressed: () => _launchURL(urls[index], context),
                icon: Icon(icons[index], color: Theme.of(context).iconTheme.color,),
                label: Flexible(child: FittedBox(child: Text(titles[index], style: Theme.of(context).textTheme.bodyText1, overflow: TextOverflow.fade,),))
              ),
            ),
          ),
      ],
    );
  }
}

class _SaveCollection extends StatefulWidget {

  _SaveCollection({Key key}) : super(key: key);

  @override
  __SaveCollectionState createState() => __SaveCollectionState();
}

class __SaveCollectionState extends State<_SaveCollection> {
  static final Screenshot _screenshot = Screenshot();
  final Future<List<String>> listOfFigures = Service().fetchDistinct(column: ['amiiboSeries'],
      expression: InCond.inn('type', ['Figure', 'Yarn']), orderBy: 'amiiboSeries');
  final Future<List<String>> listOfCards = Service().fetchDistinct(column: ['amiiboSeries'],
      expression: Cond.eq('type', 'Card'), orderBy: 'amiiboSeries');
  S translate;
  ScaffoldState scaffoldState;
  QueryProvider filter;

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    translate = S.of(context);
    scaffoldState = Scaffold.of(context, nullOk: true);
    filter = context.read<QueryProvider>();
  }

  Future<void> _saveCollection(AmiiboCategory category, List<String> figures, cards) async {
    final String message = _screenshot.isRecording ?
      translate.recordMessage : translate.savingCollectionMessage;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
    if(!_screenshot.isRecording) {
      String name;
      int id;
      Expression expression;
      switch(category){
        case AmiiboCategory.Cards:
          name = 'MyCardCollection';
          id = 4;
          expression = Cond.eq('type', 'Card');
          break;
        case AmiiboCategory.Figures:
          name = 'MyFigureCollection';
          expression = InCond.inn('type', ['Figure', 'Yarn']);
          id = 5;
          break;
        case AmiiboCategory.Custom:
          name = 'MyCustomCollection';
          id = 8;
          expression =
          Bracket(InCond.inn('type', ['Figure', 'Yarn']) & InCond.inn('amiiboSeries', figures))
          | Bracket(Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', cards));
          break;
        case AmiiboCategory.All:
        default:
          name = 'MyAmiiboCollection';
          id = 9;
          expression = And();
          break;
      }
      _screenshot.update(context);
      final buffer = await _screenshot.saveCollection(expression);
      if(buffer != null) {
        final Map<String, dynamic> notificationArgs = <String, dynamic>{
          'title': translate.notificationTitle,
          'actionTitle': translate.actionText,
          'id': id,
          'buffer' : buffer,
          'name': '${name}_$dateTaken'
        };
        await NotificationService.saveImage(notificationArgs);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CardSettings(title: translate.saveCollection,
      subtitle: translate.saveCollectionSubtitle,
      icon: const Icon(Icons.save),
      onTap: () async {
        if(!(await permissionGranted(scaffoldState))) return;
        final List<String> figures = filter.customFigures;
        final List<String> cards = filter.customCards;
        bool save = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) =>
            CustomQueryWidget(translate.saveCollection,
              figureSeriesList: listOfFigures,
              cardSeriesList: listOfCards,
              figures: figures,
              cards: cards,
            )
        ) ?? false;

        if(save && (figures.isNotEmpty || cards.isNotEmpty)) {
          bool equalFigures = false;
          bool equalCards = false;
          AmiiboCategory category = AmiiboCategory.All;
          if(figures.isNotEmpty) equalFigures = QueryProvider.checkEquality(figures, await listOfFigures);
          if(cards.isNotEmpty) equalCards = QueryProvider.checkEquality(cards, await listOfCards);
          if(equalFigures && cards.isEmpty) category = AmiiboCategory.Figures;
          else if(equalCards && figures.isEmpty) category = AmiiboCategory.Cards;
          else if(!equalCards || !equalFigures) category = AmiiboCategory.Custom;
          await _saveCollection(category, figures, cards);
        }
      }
    );
  }
}

class _ResetCollection extends StatelessWidget{

  _ResetCollection({Key key}) : super(key: key);

  Future<bool> _dialog(BuildContext context) async {
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
            FlatButton(
              child: Text(translate.cancel),
              onPressed: Navigator.of(context).pop,
              textColor: Theme.of(context).accentColor,
            ),
            FlatButton(
              textColor: Theme.of(context).accentColor,
              child: Text(translate.sure),
              onPressed: () async => Navigator.of(context).pop(true)
            ),
          ],
        );
      }
    );
  }

  void _message(ScaffoldState scaffoldState, String message){
    if(!scaffoldState.mounted) return;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final QueryProvider queryProvider = Provider.of<QueryProvider>(context, listen: false);
    return _CardSettings(
      title: translate.reset,
      subtitle: translate.resetSubtitle,
      icon: const Icon(Icons.warning),
      onTap: () async {
        final bool reset = await _dialog(context);
        if(reset ?? false){
          final ScaffoldState scaffoldState = Scaffold.of(context, nullOk: true);
          try{
            await queryProvider.resetCollection();
            _message(scaffoldState, translate.collectionReset);
          }catch(e){
            _message(scaffoldState, translate.splashError);
          }
        }
      },
    );
  }

}

class _DropMenu extends StatelessWidget {
  _DropMenu({Key key}): super(key :key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeMode, _) {
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
                  Padding(child: Text(translate.themeMode(ThemeMode.system)), padding: const EdgeInsets.only(left: 8))
                ],
              ),
            ),
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.light,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.wb_sunny, color: Colors.amber),
                  Padding(child: Text(translate.themeMode(ThemeMode.light)), padding: const EdgeInsets.only(left: 8))
                ],
              ),
            ),
            DropdownMenuItem<ThemeMode>(
              value: ThemeMode.dark,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.brightness_3, color: Colors.amber),
                  Padding(child: Text(translate.themeMode(ThemeMode.dark)), padding: EdgeInsets.only(left: 8))
                ],
              ),
            ),
          ],
          onChanged: themeMode.themeDB,
          //underline: const SizedBox.shrink(),
          iconEnabledColor: themeStyle.iconTheme.color,
          hint: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              const Icon(Icons.color_lens),
              Padding(padding: const EdgeInsets.only(left: 8),
                child: Text(translate.themeMode(themeMode.preferredTheme), style: themeStyle.textTheme.subtitle2),
              )
            ]
          )
        );
      },
    );
  }
}

class BottomBar extends StatefulWidget {
  BottomBar({Key key}) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  S translate;
  ScaffoldState scaffoldState;
  QueryProvider queryProvider;
  final _service = Service();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    scaffoldState = Scaffold.of(context, nullOk: true);
    queryProvider = Provider.of<QueryProvider>(context, listen: false);
  }

  void openSnackBar(String message, {SnackBarAction action}){
    if(!(scaffoldState?.mounted ?? false)) return;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(
      SnackBar(content: Text(message),
        action: action,
    ));
  }

  Future<void> _openFileExplorer() async {
    try{
      final file = await FilePicker.getFile(type: FileType.any);

      final String _path = file?.path;
      //print('MyPath: $_path');
      if(_path == null) return;
      else if(_path.substring(_path.lastIndexOf('.')) != '.json') {
        openSnackBar(translate.errorImporting);
      }
      else{
        Map<String,dynamic> map = await compute(readFile, file);
        if(map == null)
          openSnackBar(translate.errorImporting);
        else{
          AmiiboLocalDB amiibos = await compute(entityFromMap, map);
          await _service.update(amiibos);
          queryProvider.retryQuery;
          openSnackBar(translate.successImport);
        }
      }
      await FilePicker.clearTemporaryFiles();
    } on PlatformException catch(e){
      debugPrint(e.message);
      openSnackBar(translate.storagePermission('denied'));
    }
  }

  Future<void> _writePermission() async {
    try{
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
    }catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return BottomAppBar(
      //color: Theme.of(context).appBarTheme.color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: FlatButton.icon(
              color: Theme.of(context).buttonColor,
              shape: BeveledRectangleBorder(),
              textColor: Theme.of(context).textTheme.headline6.color,
              onPressed: () async => await _writePermission(),
              icon: const Icon(Icons.file_upload),
              label: Text(translate.export)
            ),
          ),
          const Padding(padding: const EdgeInsets.symmetric(horizontal: 0.5)),
          Expanded(
            child: FlatButton.icon(
              color: Theme.of(context).buttonColor,
              shape: BeveledRectangleBorder(),
              textColor: Theme.of(context).textTheme.headline6.color,
              onPressed: () async => await _openFileExplorer(),
              icon: const Icon(Icons.file_download),
              label: Text(translate.import)
            ),
          )
        ],
      ),
    );
  }
}

class _CardSettings extends StatelessWidget{
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  _CardSettings({
    Key key,
    this.title,
    this.subtitle,
    this.icon,
    this.onTap
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: ListTileTheme(
        iconColor: Theme.of(context).iconTheme.color,
        textColor: Theme.of(context).textTheme.bodyText2.color,
        child: Material(
          color: Colors.transparent,
          shape: Theme.of(context).cardTheme.shape,
          clipBehavior: Clip.hardEdge,
          child: ListTile(
            title: Text(title),
            subtitle: subtitle == null ? null : Text(subtitle, softWrap: false, overflow: TextOverflow.ellipsis),
            onTap: onTap,
            leading: Container(
              padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                  border: Border(right: BorderSide(width: 1, color: Theme.of(context).dividerColor))
              ),
              child: icon,
            )
          ),
        ),
      )
    );
  }
}