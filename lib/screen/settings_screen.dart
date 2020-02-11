import 'package:amiibo_network/model/amiibo_local_db.dart';
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
import 'dart:ui' as ui;
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:amiibo_network/widget/theme_widget.dart';

Future<void> saveCollection(StatProvider statProvider, ThemeData theme, Set<String> select) async{
  //final StatProvider statProvider = Provider.of<StatProvider>(context, listen: false);
  //final ThemeData theme = Theme.of(context).copyWith();
  final _service = Service();
  AmiiboLocalDB amiibos = await _service.fetchByCategory('type', select.toList(),
    'CASE WHEN type = "Figure" THEN 1 '
    'WHEN type = "Yarn" THEN 2 ELSE 3 END, amiiboSeries DESC, na DESC');
  if(amiibos?.amiibo?.isEmpty ?? true) return;

  Map<String,dynamic> _listStat = Map<String, dynamic>.from(
      (await _service.fetchSum(column: 'type', args: select.toList())).first);
  final Map<String,dynamic> file = Map<String,dynamic>();
  final String time = DateTime.now().toString().substring(0,10);
  final Directory dir = await Directory('/storage/emulated/0/Download').create();
  final String path = '${dir.path}/My${
      select.containsAll(['Figure', 'Yarn', 'Card']) ? 'Amiibo' :
      select.containsAll(['Figure', 'Yarn']) ? 'Figure' : 'Card'
  }Collection$time.png';
  final Paint ownedCardPaint = Paint()..color = colorOwned[100];
  final Paint wishedCardPaint = Paint()..color = colorWished[100];
  final Color textColor = theme.textTheme.title.color;
  final Paint unselectedCardPaint = Paint()..color = Colors.grey.withOpacity(0.5);
  final double margin = 20.0;
  final double maxSize = 60.0;
  final double padding = 10.0;
  final double space = 0.25;
  final double width = (amiibos.amiibo.length / 25.0).ceilToDouble().clamp(15.0, 30.0);
  final double maxX = (width * (1 + space) - space) * (maxSize + 2*padding) + 2*margin;
  final double maxY = ((amiibos.amiibo.length / width).ceilToDouble()
      * (1 + 0.5*space) - 0.5*space) * (1.5*maxSize + 2*padding) + 100 + 2*margin;

  double xOffset = margin;
  double yOffset = margin;
  ui.Picture pic;

  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paint = Paint()..color = theme.scaffoldBackgroundColor;

  canvas.drawColor(paint.color, BlendMode.src);

  final TextSpan aNetwork = TextSpan(
      style: TextStyle(color: textColor, fontSize: 50),
      text: 'Amiibo Network',
      children: <InlineSpan>[
        TextSpan(
            style: TextStyle(color: textColor, fontSize: 15, wordSpacing: maxSize),
            text: '\u24C7 '
        ),
        TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 30, height: 1.15,
                fontWeight: FontWeight.w300, background: ownedCardPaint),
            text: ' ${statProvider.statLabel(_listStat['Owned'].toDouble(), _listStat['Total'].toDouble())} '
        ),
        TextSpan(
            style: TextStyle(color: textColor, fontSize: 35),
            text: ' Owned'
        ),
        TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 35, wordSpacing: maxSize),
            text: ' '
        ),
        TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 30, height: 1.15,
                fontWeight: FontWeight.w300, background: wishedCardPaint),
            text: ' ${statProvider.statLabel(_listStat['Wished'].toDouble(), _listStat['Total'].toDouble())} '
        ),
        TextSpan(
            style: TextStyle(color: textColor, fontSize: 35),
            text: ' Wished'
        ),
      ]
  );
  TextPainter(text: aNetwork,
      textDirection: TextDirection.ltr
  )..layout(minWidth: maxX-125-margin)
    ..paint(canvas, Offset(125, maxY - margin - 65));

  TextSpan createdDate = TextSpan(
      style: TextStyle(color: textColor, fontSize: 25),
      text: 'created on: $time'
  );
  TextPainter(text: createdDate, textDirection: TextDirection.rtl,)
    ..layout(minWidth: maxX-125-margin)
    ..paint(canvas, Offset(125, maxY - margin - 25));

  final _ima = await rootBundle.load('assets/images/icon_app.png');
  final ui.Image appIcon = await ui.instantiateImageCodec(
      _ima.buffer.asUint8List(),
      targetWidth: 80, targetHeight: 80
  ).then((codec) => codec.getNextFrame())
      .then((frame) => frame.image).catchError((e) => print(e));

  if(theme.brightness == Brightness.dark)
    canvas.drawImage(appIcon, Offset(margin, maxY - margin - 80),
        Paint()..colorFilter = ColorFilter.mode(Colors.white54, BlendMode.srcIn)
    );
  else canvas.drawImage(appIcon, Offset(margin, maxY - margin - 80), paint);

  appIcon.dispose();

  for(AmiiboDB amiibo in amiibos.amiibo) {
    final String strImage = 'assets/collection/icon_${amiibo.key}.png';
    final Offset _offset = Offset(xOffset, yOffset);
    final Path cardPath = Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromPoints(
            _offset,
            _offset.translate(maxSize + 2*padding, 1.5*maxSize + 2*padding)
        ),
        Radius.circular(8.0)
    ));
    final ByteData imageAsset = await rootBundle.load(strImage);

    //canvas.drawPath(cardPath, amiibo?.owned?.isOdd ?? false ? ownedCardPaint :
    //amiibo?.wishlist?.isOdd ?? false ? wishedCardPaint : unselectedCardPaint);

    if((amiibo?.owned?.isOdd ?? false) || (amiibo?.wishlist?.isOdd ?? false)){
      canvas.drawPath(cardPath,
          amiibo?.owned?.isOdd ?? false ? ownedCardPaint : wishedCardPaint);
    }

    ui.Image _image = await ui.instantiateImageCodec(
      imageAsset.buffer.asUint8List(),
      targetWidth: maxSize.toInt(),
    ).then((codec) => codec.getNextFrame()).then((frame)=> frame.image);

    final bool taller = _image.width > 1.3*_image.height;
    canvas.drawImageNine(_image,
        Rect.fromCenter(
            center: Offset.zero,
            width: _image.height.toDouble()*1.5,
            height: _image.width.toDouble()
        ),
        Rect.fromLTRB(
            _offset.dx + padding,
            (taller ? _offset.dy + 1.4 * maxSize - _image.height : _offset.dy) + padding,
            _offset.dx + maxSize + padding,
            _offset.dy + 1.5*maxSize + padding
        ),
        paint
    );

    _image.dispose();

    xOffset += (1 + space) * (maxSize + 2*padding);
    if(xOffset >= maxX - margin){
      xOffset = margin;
      yOffset += (1 + 0.5*space)*(1.5*maxSize + 2*padding);
    }
  }

  pic = pictureRecorder.endRecording();
  try{
    ui.Image img = await pic.toImage(maxX.toInt(), maxY.toInt());
    pic.dispose();
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    List<int> buffer = byteData.buffer.asUint8List();
    file['path'] = path;
    file['buffer'] = buffer;
    compute(writeCollectionFile, file);
  }catch(e){
    print(e);
  }
}

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
                        final bool permission = collection['permission'] ?? false;
                        final String message = permission ?
                        'Saving your file. This could take a while depending on your device' :
                        collection['message'];
                        Scaffold.of(ctx).showSnackBar(SnackBar(content: Text(message)));
                        if(permission) {
                          final StatProvider statProvider = Provider.of<StatProvider>(context, listen: false);
                          final ThemeData theme = Theme.of(context).copyWith();
                          final Set<String> select = Set.of(collection['selected']);
                          await saveCollection(statProvider, theme, select);
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
          value: select.contains('Figure') && select.contains('Figure'),
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
              PermissionHandler().requestPermissions([PermissionGroup.storage]);
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
                await Provider.of<AmiiboProvider>(context, listen: false).resetCollection();
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