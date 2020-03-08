import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:amiibo_network/widget/theme_widget.dart';

class SettingsPage extends StatelessWidget{
  static final Screenshot _screenshot = Screenshot();
  const SettingsPage({Key key}): super(key: key);

  @override
  Widget build(BuildContext context){
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
          title: const SizedBox(child: Text('Settings')),
        ),
        body: Scrollbar(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  ResetCollection(),
                  Builder(builder: (ctx){
                    return CardSettings(title: 'Save Collection',
                      subtitle: 'Create a picture of your collection',
                      icon: const Icon(Icons.save),
                      onTap: () async {
                        Map<String,dynamic> collection = await showDialog(
                          context: ctx,
                          builder: (ctx) => _SaveCollection()
                        );
                        if(collection != null){
                          final bool permission = collection['permission'];
                          final ScaffoldState scaffoldState = Scaffold.of(ctx, nullOk: true);
                          String message = collection['message'];
                          if(permission) message = permissionMessage;
                          if(_screenshot.isRecording) message = recordMessage;
                          scaffoldState?.hideCurrentSnackBar();
                          scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
                          if(permission && !_screenshot.isRecording) {
                            _screenshot..theme = Theme.of(context).copyWith()
                              ..statProvider = Provider.of<StatProvider>(context, listen: false);
                            final Set<String> select = Set.of(collection['selected']);
                            final String response = await _screenshot.saveCollection(select);
                            if(response.isNotEmpty && (scaffoldState?.mounted ?? false)){
                              scaffoldState?.hideCurrentSnackBar();
                              scaffoldState?.showSnackBar(SnackBar(content: Text(response)));
                            }
                          }
                        }
                      }
                    );
                  }),
                  CardSettings(title: 'Appearance', subtitle: 'More personalization', icon: const Icon(Icons.color_lens),
                    onTap: () => ThemeButton.dialog(context)//() => _dialog(context),
                  ),
                  CardSettings(title: 'Changelog', subtitle: 'Changing for better...', icon: const Icon(Icons.build)),
                  CardSettings(title: 'Credits', subtitle: 'Those who make it possible', icon: const Icon(Icons.theaters)),
                  CardSettings(title: 'Privacy Policy', subtitle: 'Therms and conditions', icon: const Icon(Icons.help)),
                  ProjectButtons(),
                  Card(
                    child: FlatButton.icon(
                      onPressed: LaunchReview.launch,
                      icon: Image.asset('assets/images/icon_app.png',
                        height: 30, width: 30, fit: BoxFit.fill,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54 : null,
                      ),
                      label: Text('Rate me', style: Theme.of(context).textTheme.body2),
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

class ProjectButtons extends StatelessWidget{
  _launchURL(String url, BuildContext ctx) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Could not launch $url')));
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
              onPressed: () => _launchURL('https://github.com/EdwynZN/amiibo_network', context),
              icon: Icon(Icons.code, color: Theme.of(context).iconTheme.color,),
              label: Flexible(child: FittedBox(child: Text('Github', style: Theme.of(context).textTheme.body2, overflow: TextOverflow.fade,),))
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: FlatButton.icon(
              onPressed: () => _launchURL('https://github.com/EdwynZN/amiibo_network/issues', context),
              icon: Icon(Icons.bug_report, color: Theme.of(context).iconTheme.color),
              label: Flexible(child: FittedBox(child: Text('Report bug', style: Theme.of(context).textTheme.body2, overflow: TextOverflow.fade),)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveCollection extends StatefulWidget{
  @override
  _SaveCollectionState createState() => _SaveCollectionState();
}

class _SaveCollectionState extends State<_SaveCollection> {
  Set<String> select = {};

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      semanticLabel: 'Save',
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Text('Select your Collection', style: Theme.of(context).textTheme.display1),
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
          title: Text('Figure'),
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
          title: Text('Cards'),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            onPressed: select.isEmpty ? null : () async {
              final Map<PermissionGroup, PermissionStatus> response =
              await PermissionHandler().requestPermissions([PermissionGroup.storage]);
              final Map<String,dynamic> permission = checkPermission(
                response[PermissionGroup.storage]
              );
              if(permission['permission']) permission['selected'] = select;
              Navigator.of(context).pop(permission);
            },
            child: Text('Save')
          )
        ),
      ],
    );
  }
}

class ResetCollection extends StatelessWidget{

  Future<void> _dialog(BuildContext context) async {
    final AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset your collection'),
          titlePadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          content: Text('Are you sure? This action can\'t be undone'),
          actions: <Widget>[
            FlatButton(
              child: Text('Wait no!'),
              onPressed: Navigator.of(context).pop,
              textColor: Theme.of(context).accentColor,
            ),
            FlatButton(
              textColor: Theme.of(context).accentColor,
              child: Text('Sure'),
              onPressed: () async {
                Navigator.of(context).maybePop();
                await amiiboProvider.resetCollection();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardSettings(
      title: 'Reset',
      subtitle: 'Reset your wishlist and collection',
      icon: const Icon(Icons.warning),
      onTap: () => _dialog(context),
    );
  }

}

class DropMenu extends StatelessWidget {
  DropMenu({Key key}): super(key :key);

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, String>(
      builder: (context, strTheme, _) {
        return DropdownButton<String>(
          items: [
            DropdownMenuItem<String>(
              value: 'Auto',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.brightness_auto, color: Colors.amber),
                  Padding(child: Text('Auto'), padding: const EdgeInsets.only(left: 8))
                ],
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Light',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.wb_sunny, color: Colors.amber),
                  Padding(child: Text('Light'), padding: const EdgeInsets.only(left: 8))
                ],
              ),
            ),
            DropdownMenuItem<String>(
              value: 'Dark',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.brightness_3, color: Colors.amber),
                  Padding(child: Text('Dark'), padding: EdgeInsets.only(left: 8))
                ],
              ),
            ),
          ],
          onChanged: Provider.of<ThemeProvider>(context, listen: false).themeDB,
          underline: const SizedBox.shrink(),
          iconEnabledColor: Theme.of(context).appBarTheme.iconTheme.color,
          hint: Row(
            children: <Widget>[
              const Icon(Icons.color_lens),
              Padding(padding: const EdgeInsets.only(left: 8),
                child: Text(strTheme, style: Theme.of(context).appBarTheme.textTheme.subtitle,),
              )
            ]
          )
        );
      },
      selector: (context, theme) => theme.savedTheme,
    );
  }
}

class BottomBar extends StatelessWidget{

  void _openFileExplorer(BuildContext context) async {
    final AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    final ScaffoldState scaffold = Scaffold.of(context);
    final String _path = await FilePicker.getFilePath(type: FileType.ANY);
    if(_path == null) return;
    else if(_path.substring(_path.lastIndexOf('.')) != '.json') {
      scaffold.showSnackBar(SnackBar(content: Text('This isn\'t an Amiibo List')));
    }
    else{
      Map<String,dynamic> map = await compute(readFile, _path);
      if(map == null && scaffold.mounted)
        scaffold.showSnackBar(SnackBar(content: Text('This isn\'t an Amiibo List')));
      else{
        final _service = Service();
        AmiiboLocalDB amiibos = await compute(entityFromMap, map);
        await _service.update(amiibos);
        amiiboProvider.refreshPagination();
        if(scaffold.mounted)
          scaffold.showSnackBar(SnackBar(content: Text('Amiibo List updated')));
      }
    }
  }

  _requestWritePermission(BuildContext context) async {
    final Map<PermissionGroup, PermissionStatus> response =
      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    final Map<String, dynamic> permission = checkPermission(
      response[PermissionGroup.storage]
    );
    if(permission['permission']){
      final _service = Service();
      final AmiiboLocalDB amiibos = await _service.fetchAllAmiiboDB();
      String response = await compute(writeFile, amiibos);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(response),
          duration: const Duration(seconds: 2),
        )
      );
    }else
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(permission['message']),
          duration: const Duration(seconds: 2),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => _requestWritePermission(context),
              icon: const Icon(Icons.file_upload),
              label: Text('Export')
            ),
          ),
          const Padding(padding: const EdgeInsets.symmetric(horizontal: 0.5)),
          Expanded(
            child: FlatButton.icon(
              color: Theme.of(context).buttonColor,
              shape: BeveledRectangleBorder(),
              textColor: Theme.of(context).textTheme.title.color,
              onPressed: () => _openFileExplorer(context),
              icon: const Icon(Icons.file_download),
              label: Text('Import')
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
            onTap: onTap ?? () => Navigator.pushNamed(context, "/settingsdetail", arguments: title),
            trailing: onTap == null ? const Icon(Icons.navigate_next) : null,
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