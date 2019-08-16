import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/theme_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:launch_review/launch_review.dart';

class SettingsPage extends StatelessWidget{
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
                child: DropMenu(),
              ),
            )
          ],
          title: const SizedBox(child: Text('Settings')),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                ResetCollection(),
                CardSettings(title: 'Changelog', subtitle: 'Changing for better...', icon: Icons.build,),
                CardSettings(title: 'Credits', subtitle: 'Those who make it possible', icon: Icons.theaters,),
                CardSettings(title: 'Privacy Policy', subtitle: 'Therms and conditions', icon: Icons.help,),
                Row(
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
                          label: Text('Rate me', style: Theme.of(context).textTheme.body2),
                        ),
                      )
                    ),
                    /*Expanded(
                      child: Card(
                        child: FlatButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.monetization_on, color: Theme.of(context).iconTheme.color,),
                          label: Text('Donate', style: Theme.of(context).textTheme.body2),
                        ),
                      )
                    ),*/
                  ],
                )
              ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomBar()
      )
    );
  }
}

class ResetCollection extends StatelessWidget{
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();

  Future<void> _dialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset your collection'),
          titlePadding: EdgeInsets.all(12),
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          content: Text('Are you sure? This action can\'t be undone'),
          actions: <Widget>[
            FlatButton(
              child: Text('Wait no!'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('Sure'),
              onPressed: () async {
                Navigator.of(context).maybePop();
                await _bloc.resetCollection();
              }
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
      icon: Icons.warning,
      onTap: () => _dialog(context),
    );
  }

}

class DropMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DropMenuState();
}

class DropMenuState extends State<DropMenu>{
  static final ThemeBloc _themeBloc = $Provider.of<ThemeBloc>();
  String _value = _themeBloc.savedTheme;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: [
        DropdownMenuItem<String>(
          value: 'Auto',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.brightness_auto, color: Colors.amber),
              Padding(child: Text('Auto'), padding: EdgeInsets.only(left: 8))
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Light',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wb_sunny, color: Colors.amber),
              Padding(child: Text('Light'), padding: EdgeInsets.only(left: 8))
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
      onChanged: (String x) async{
        _value = x;
        await _themeBloc.themeDB(x);
        setState(() {});
      },
      underline: const SizedBox.shrink(),
      iconEnabledColor: Theme.of(context).appBarTheme.iconTheme.color,
      hint: Row(
        children: <Widget>[
          const Icon(Icons.color_lens),
          Padding(padding: EdgeInsets.only(left: 8),
            child: Text(_value, style: Theme.of(context).appBarTheme.textTheme.subtitle,),
          )
        ]
      )
    );
  }
}

class BottomBar extends StatelessWidget{
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  
  void _openFileExplorer(BuildContext context) async {
    final String _path = await FilePicker.getFilePath(type: FileType.ANY);
    bool _fileRead = false;
    if(_path == null) return;
    if(_path.substring(_path.lastIndexOf('.')) == '.json')
      _fileRead = await Storage().readFile(_path);
    if(!_fileRead)
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('This isn\'t an Amiibo List'))
      );
    else {
      _bloc.refreshPagination();
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text('Amiibo List updated'))
      );
    }
  }

  Future<bool> _checkPermission(BuildContext context) async {
    final PermissionStatus permission =
      await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    String value;
    Future<bool> permissionGranted;
    switch(permission){
      case(PermissionStatus.granted):
        permissionGranted = Future.value(true);
        break;
      case(PermissionStatus.denied):
        value = 'Storage permission denied';
        permissionGranted = Future.value(false);
        break;
      case(PermissionStatus.disabled):
        value = 'Storage permission disabled';
        permissionGranted = Future.value(false);
        break;
      case(PermissionStatus.restricted):
        value = 'Storage permission restricted';
        permissionGranted = Future.value(false);
        break;
      case(PermissionStatus.unknown):
        value = 'Unknown Error';
        permissionGranted = Future.value(false);
        break;
    }
    if(!(await permissionGranted))
      Scaffold.of(context).showSnackBar(
        SnackBar(content: Text(value), duration: const Duration(seconds: 2),
        )
      );
    return await permissionGranted;
  }

  Future<void> _exportDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save your amiibos'),
          titlePadding: EdgeInsets.all(12),
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          content: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              child: TextField(
                textInputAction: TextInputAction.done,
                maxLength: 15,
                autocorrect: false,
                autofocus: true,
                decoration: InputDecoration(labelText: 'Name of the File'),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Save'),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        );
      }
    );
  }

  _requestWritePermission(BuildContext context) async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    if(await _checkPermission(context))
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(await Storage().writeFile()),
          duration: const Duration(seconds: 2),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row (
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExpandedIconButton(icon: Icons.file_upload, text: 'Export',
            onTap: () => _requestWritePermission(context)
          ),
          const SizedBox(height: 35, child: const VerticalDivider(width: 1)),
          ExpandedIconButton(icon: Icons.file_download, text: 'Import',
            onTap: () => _openFileExplorer(context),
          )
        ],
      ),
    );
  }
}

class ExpandedIconButton extends StatelessWidget{
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ExpandedIconButton({this.icon, this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        containedInkWell: true, splashFactory: InkRipple.splashFactory,
        highlightShape: BoxShape.rectangle,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon),
              SizedBox(child: Text(text))
            ],
          ),
        )
      ),
    );
  }
}

class CardSettings extends StatelessWidget{
  final String title;
  final String subtitle;
  final IconData icon;
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
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle, softWrap: false, overflow: TextOverflow.ellipsis),
          onTap: onTap ?? () => Navigator.pushNamed(context, "/settingsdetail", arguments: title),
          trailing: onTap == null ? const Icon(Icons.navigate_next) : null,
          leading: Container(
            padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(width: 1, color: Theme.of(context).dividerColor))
            ),
            child: Icon(icon),
          )
        ),
      )
    );
  }
}