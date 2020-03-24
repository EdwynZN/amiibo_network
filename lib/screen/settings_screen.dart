import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/urls_constants.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
                child: DropMenu(key: Key('theme')),
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
                  ResetCollection(),
                  _SaveCollection(),
                  CardSettings(title: translate.appearance, subtitle: translate.appearanceSubtitle, icon: const Icon(Icons.color_lens),
                    onTap: () => ThemeButton.dialog(context)
                  ),
                  CardSettings(
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
                  CardSettings(
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
                    /*showLicensePage(
                      context: context,
                      applicationName: 'Amiibo Network',
                      applicationVersion: '1.2.2',
                      applicationIcon: Image.asset('assets/images/icon_app.png',
                        height: 30, width: 30, fit: BoxFit.scaleDown,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54 : null,
                      ),
                      //applicationLegalese: applicationLegalese,
                    )*/
                  ),
                  CardSettings(
                    title: translate.privacyPolicy,
                    subtitle: translate.privacySubtitle,
                    icon: const Icon(Icons.help),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => MarkdownReader(
                        file: translate.privacyPolicy.replaceAll(' ', '%20'),
                        title: translate.privacySubtitle
                      )
                    )
                  ),
                  ProjectButtons(),
                  Card(
                    child: FlatButton.icon(
                      onPressed: LaunchReview.launch,
                      icon: Image.asset('assets/images/icon_app.png',
                        height: 30, width: 30, fit: BoxFit.fill,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54 : null,
                      ),
                      label: Text(translate.rate, style: Theme.of(context).textTheme.body2),
                    ),
                  )
                ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomBar()
      )
    );
  }
}

class MarkdownReader extends StatelessWidget {
  final String title;
  final String file;
  const MarkdownReader({Key key, this.title, @required this.file}): super(key: key);

  Future<String> get _localFile => rootBundle.loadString('assets/text/$file.md');

  _launchURL(String url, BuildContext ctx) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(ctx, nullOk: true)?.showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return AlertDialog(
      title: Text(title),
      titlePadding: const EdgeInsets.all(12),
      contentPadding: EdgeInsets.zero,
      content: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: FutureBuilder(
            future: _localFile,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot){
              if(snapshot.hasError)
                return Center(child: Text(translate.markdownError));
              if(snapshot.hasData)
                return MarkdownBody(
                  data: snapshot.data,
                  styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                  onTapLink: (url) => _launchURL(url, context),
                );
              return const SizedBox.shrink();
            }
          )
        )
      ),
      actions: <Widget>[
        FlatButton(
          textColor: Theme.of(context).accentColor,
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
          onPressed: () async {
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}

class ProjectButtons extends StatelessWidget{
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
        Expanded(
          child: Card(
            child: FlatButton.icon(
              onPressed: () => _launchURL(github, context),
              icon: Icon(Icons.code, color: Theme.of(context).iconTheme.color,),
              label: Flexible(child: FittedBox(child: Text('Github', style: Theme.of(context).textTheme.body2, overflow: TextOverflow.fade,),))
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: FlatButton.icon(
              onPressed: () => _launchURL(reportIssue, context),
              icon: Icon(Icons.bug_report, color: Theme.of(context).iconTheme.color),
              label: Flexible(child: FittedBox(child: Text(S.of(context).reportBug, style: Theme.of(context).textTheme.body2, overflow: TextOverflow.fade),)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveCollection extends StatelessWidget{
  static final Screenshot _screenshot = Screenshot();

  Future<Set<String>> _dialog(BuildContext context) async {
    return await showDialog<Set<String>>(
      context: context,
      builder: (context) => _SaveCollectionDialog()
    );
  }

  Future<void> _save(BuildContext context, Set<String> collection) async {
    final ScaffoldState scaffoldState = Scaffold.of(context, nullOk: true);
    final S translate = S.of(context);
    final String message = _screenshot.isRecording ?
      translate.recordMessage : translate.savingCollectionMessage;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
    if(!_screenshot.isRecording) {
      final String time = DateTime.now().toString().substring(0,10);
      final String name = 'My${
        collection.containsAll(['Figure', 'Yarn', 'Card']) ? 'Amiibo' :
        collection.contains('Card') ? 'Card' : 'Figure'
      }Collection_$time';
      var file = await createFile(name, 'png');
      _screenshot.update(context);
      await _screenshot.saveCollection(collection, file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return CardSettings(title: translate.saveCollection,
      subtitle: translate.saveCollectionSubtitle,
      icon: const Icon(Icons.save),
      onTap: () async {
        Set<String> collection = await _dialog(context);
        if(collection == null) return;
        if(collection.isNotEmpty) await _save(context, collection);
        else{
          final PermissionHandler _permissionHandler = PermissionHandler();
          final PermissionStatus status =
           await _permissionHandler.checkPermissionStatus(PermissionGroup.storage);
          final ScaffoldState scaffoldState = Scaffold.of(context, nullOk: true);
          if(scaffoldState?.mounted ?? false)
          scaffoldState?.hideCurrentSnackBar();
          scaffoldState?.showSnackBar(
            SnackBar(
              content: Text(translate.storagePermission(status)),
              action: SnackBarAction(
              label: translate.openAppSettings,
              onPressed: () async => await _permissionHandler.openAppSettings(),
            ),
            )
          );
        }
      }
    );
  }
}

class _SaveCollectionDialog extends StatefulWidget{
  @override
  _SaveCollectionDialogState createState() => _SaveCollectionDialogState();
}

class _SaveCollectionDialogState extends State<_SaveCollectionDialog> {
  Set<String> select = {};

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return SimpleDialog(
      semanticLabel: translate.saveCollection,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Text(translate.saveCollectionTitleDialog, style: Theme.of(context).textTheme.display1),
          ),
          const Divider(),
        ],
      ),
      titlePadding: const EdgeInsets.only(top: 12.0),
      contentPadding: const EdgeInsets.only(bottom: 8.0),
      children: <Widget>[
        CheckboxListTile(
          value: select.contains('Figure') && select.contains('Yarn'),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value){
            setState(() {
              if(value) select.addAll(['Figure', 'Yarn']);
              else select.removeAll(['Figure', 'Yarn']);
            });
          },
          title: Text(translate.figures),
        ),
        CheckboxListTile(
          value: select.contains('Card'),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value){
            setState(() {
              if(value) select.add('Card');
              else select.remove('Card');
            });
          },
          title: Text(translate.cards),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            onPressed: select.isEmpty ? null : () async {
              final Map<PermissionGroup, PermissionStatus> response =
              await PermissionHandler().requestPermissions([PermissionGroup.storage]);
              final bool permission = checkPermission(response[PermissionGroup.storage]);
              Navigator.of(context).pop(permission ? select : <String>{});
            },
            child: Text(MaterialLocalizations.of(context).okButtonLabel)
          )
        ),
      ],
    );
  }
}

class ResetCollection extends StatelessWidget{

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
    final AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    return CardSettings(
      title: translate.reset,
      subtitle: translate.resetSubtitle,
      icon: const Icon(Icons.warning),
      onTap: () async {
        final bool reset = await _dialog(context);
        if(reset ?? false){
          final ScaffoldState scaffoldState = Scaffold.of(context, nullOk: true);
          try{
            await amiiboProvider.resetCollection();
            _message(scaffoldState, translate.collectionReset);
          }catch(e){
            _message(scaffoldState, translate.splashError);
          }
        }
      },
    );
  }

}

class DropMenu extends StatelessWidget {
  DropMenu({Key key}): super(key :key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return Selector<ThemeProvider, ThemeMode>(
      builder: (context, themeMode, _) {
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
          onChanged: Provider.of<ThemeProvider>(context, listen: false).themeDB,
          //underline: const SizedBox.shrink(),
          iconEnabledColor: Theme.of(context).appBarTheme.iconTheme.color,
          hint: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const Icon(Icons.color_lens),
                  Padding(padding: const EdgeInsets.only(left: 8),
                    child: Text(translate.themeMode(themeMode), style: Theme.of(context).appBarTheme.textTheme.subtitle,),
                  )
                ]
            )
        );
      },
      selector: (context, theme) => theme.preferredTheme,
    );
  }
}

class BottomBar extends StatefulWidget {
  BottomBar({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  S translate;
  ScaffoldState scaffoldState;
  AmiiboProvider amiiboProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
    scaffoldState = Scaffold.of(context, nullOk: true);
    amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
  }

  void openSnackBar(String message){
    if(!(scaffoldState?.mounted ?? false)) return;
    scaffoldState?.hideCurrentSnackBar();
    scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFileExplorer() async {
    try{
      //final String _path = await FilePicker.getFilePath(type: FileType.ANY);
      final file = await FilePicker.getFile(type: FileType.CUSTOM, fileExtension: 'json');
      final String _path = file?.path;
      if(_path == null) return;
      else if(_path.substring(_path.lastIndexOf('.')) != '.json') {
        openSnackBar(translate.errorImporting);
      }
      else{
        //var copyFile = await createCacheFile(_path);
        //Map<String,dynamic> map = await compute(readFile1, copyFile);
        Map<String,dynamic> map = await compute(readFile, _path);
        if(map == null)
          openSnackBar(translate.errorImporting);
        else{
          final _service = Service();
          AmiiboLocalDB amiibos = await compute(entityFromMap, map);
          await _service.update(amiibos);
          amiiboProvider.refreshPagination();
          openSnackBar(translate.successImport);
        }
      }
    } on PlatformException catch(e){
      debugPrint(e.message);
      openSnackBar(translate.storagePermission('denied'));
    }
    /*final String _path = await FilePicker.getFilePath(type: FileType.any);
    if(_path == null) return;
    else if(_path.substring(_path.lastIndexOf('.')) != '.json') {
      openSnackBar(scaffold, translate.errorImporting);
    }
    else{
      Map<String,dynamic> map = await compute(readFile, _path);
      if(map == null && scaffold.mounted)
        openSnackBar(scaffold, translate.errorImporting);
      else{
        final _service = Service();
        AmiiboLocalDB amiibos = await compute(entityFromMap, map);
        await _service.update(amiibos);
        amiiboProvider.refreshPagination();
        openSnackBar(scaffold, translate.successImport);
      }
    }*/
  }

  Future<void> _requestWritePermission() async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    final Map<PermissionGroup, PermissionStatus> response =
    await _permissionHandler.requestPermissions([PermissionGroup.storage]);
    final bool permission = checkPermission(response[PermissionGroup.storage]);
    if(permission){
      final _service = Service();
      final Map<String, dynamic> args = Map<String, dynamic>();
      args['amiibos'] = await _service.fetchAllAmiiboDB();
      args['file'] = await createFile();
      final bool saved = args['file'].existsSync();
      final String fileSaved = saved ? translate.overwritten : translate.saved;
      await compute(writeFile, args);
      final String response = '${translate.fileSaved} $fileSaved';
      openSnackBar(response);
    }
    else{
      final String message = translate.storagePermission(response[PermissionGroup.storage]);
      openSnackBar(message);
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
            child: FlatButton.icon(
              color: Theme.of(context).buttonColor,
              shape: BeveledRectangleBorder(),
              textColor: Theme.of(context).textTheme.title.color,
              onPressed: () async => await _requestWritePermission(),
              icon: const Icon(Icons.file_upload),
              label: Text(translate.export)
            ),
          ),
          const Padding(padding: const EdgeInsets.symmetric(horizontal: 0.5)),
          Expanded(
            child: FlatButton.icon(
              color: Theme.of(context).buttonColor,
              shape: BeveledRectangleBorder(),
              textColor: Theme.of(context).textTheme.title.color,
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

class CardSettings extends StatelessWidget{
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  CardSettings({
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
        textColor: Theme.of(context).textTheme.body1.color,
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