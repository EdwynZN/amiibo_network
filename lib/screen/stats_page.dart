import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/generated/l10n.dart';
/*import 'package:flutter_local_notifications/flutter_local_notifications.dart';*/
import 'package:android_intent/android_intent.dart';
import 'package:amiibo_network/widget/stat_widget.dart';

class StatsPage extends StatefulWidget{

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _service = Service();
  ScrollController _controller;
  Set<String> select = <String>{};

  @override
  void initState(){
    super.initState();
    _controller = ScrollController();
  }

  void _updateSet(Set<String> value){
    if(_controller.offset != _controller.initialScrollOffset) _controller.jumpTo(0);
    setState(() => select..clear()..addAll(value));
  }

  Future<List<Map<String, dynamic>>> get _retrieveStats
  => _service.fetchSum(group: true, expression: InCond.inn('type', select.toList()));

  Future<List<Map<String, dynamic>>> get _generalStats
  => _service.fetchSum(expression: InCond.inn('type', select.toList()));

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return SafeArea(
      child: Scaffold(
        body: Scrollbar(
          controller: _controller,
          child: CustomScrollView(
            controller: _controller,
            cacheExtent: 150,
            slivers: <Widget>[
              FutureBuilder(
                future: _generalStats,
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                        SingleStat(
                          key: Key('Amiibo Network'),
                          title: 'Amiibo Network',
                          owned: snapshot.data[index]['Owned'],
                          total: snapshot.data[index]['Total'],
                          wished: snapshot.data[index]['Wished'],
                        ),
                      childCount: snapshot.hasData ? snapshot.data.length : 0,
                    ),
                  );
                }
              ),
              FutureBuilder(
                future: _retrieveStats,
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if(MediaQuery.of(context).size.width <= 600)
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                          SingleStat(
                            key: ValueKey(index),
                            title: snapshot.data[index]['amiiboSeries'],
                            owned: snapshot.data[index]['Owned'],
                            total: snapshot.data[index]['Total'],
                            wished: snapshot.data[index]['Wished'],
                          ),
                        semanticIndexOffset: 1,
                        childCount: snapshot.hasData ? snapshot.data.length : 0,
                      ),
                    );
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      childAspectRatio: 1.22,
                      mainAxisSpacing: 8.0,
                    ),
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                        SingleStat(
                          key: ValueKey(index),
                          title: snapshot.data[index]['amiiboSeries'],
                          owned: snapshot.data[index]['Owned'],
                          total: snapshot.data[index]['Total'],
                          wished: snapshot.data[index]['Wished'],
                        ),
                      semanticIndexOffset: 1,
                      childCount: snapshot.hasData ? snapshot.data.length : 0,
                    )
                  );
                }
              ),
              const SliverToBoxAdapter(
                child: const SizedBox(height: 80),
              )
            ],
          )
        ),
        floatingActionButton: _FAB(select),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).appBarTheme.color,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      side: BorderSide(
                        color: Theme.of(context).indicatorColor,
                        width: 2,
                      )
                    ),
                    textColor: select.isEmpty ?
                    Theme.of(context).textTheme.title.color : Theme.of(context).appBarTheme.textTheme.title.color,
                    color: select.isEmpty ? Theme.of(context).indicatorColor : null,
                    onPressed: () => select.isEmpty ? null : _updateSet(Set<String>()),
                    child: Text(translate.all),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    shape: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).indicatorColor,
                        width: 2,
                      ),
                      top: BorderSide(
                        color: Theme.of(context).indicatorColor,
                        width: 2,
                      ),
                      left: BorderSide(
                        color: Theme.of(context).indicatorColor,
                        width: 0.0
                      ),
                      right: BorderSide(
                        color: Theme.of(context).indicatorColor,
                        width: 0.0
                      ),
                    ),
                    textColor: select.contains('Figure') ?
                    Theme.of(context).textTheme.title.color : Theme.of(context).appBarTheme.textTheme.title.color,
                    color: select.contains('Figure') ?
                    Theme.of(context).indicatorColor : null,
                    onPressed: () => select.contains('Figure') ? null : _updateSet(<String>{'Figure', 'Yarn'}),
                    child: Text(translate.figures),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      side: BorderSide(
                        color: Theme.of(context).indicatorColor,
                        width: 2,
                      )
                    ),
                    textColor: select.contains('Card') ?
                    Theme.of(context).textTheme.title.color : Theme.of(context).appBarTheme.textTheme.title.color,
                    color: select.contains('Card') ? Theme.of(context).indicatorColor : null,
                    onPressed: () => select.contains('Card') ? null : _updateSet(<String>{'Card'}),
                    child: Text(translate.cards),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}

class _FAB extends StatelessWidget{
  final Screenshot _screenshot = Screenshot();
  final Set<String> _select;

  _FAB(this._select);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return FloatingActionButton(
      child: const Icon(Icons.save),
      tooltip: translate.saveStatsTooltip,
      heroTag: 'MenuFAB',
      onPressed: () async {
        final ScaffoldState scaffoldState = Scaffold.of(context, nullOk: true);
        final Map<PermissionGroup, PermissionStatus> response =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
        final bool permission = checkPermission(response[PermissionGroup.storage]);
        String message = translate.storagePermission(response[PermissionGroup.storage]);
        if(permission) message = translate.savingCollectionMessage;
        if(_screenshot.isRecording) message = translate.recordMessage;
        scaffoldState?.hideCurrentSnackBar();
        scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
        if(permission && !_screenshot.isRecording) {
          _screenshot.update(context);
          final String time = DateTime.now().toString().substring(0,10);
          final String name = 'My${_select.isEmpty ? 'Amiibo' :
            _select.contains('Card') ? 'Card' : 'Figure'}Stats';
          final file = await createFile(name, 'png');
          await _screenshot.saveStats(_select, file);
          /*FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'Export', 'Export Collection', 'Save and export your collection or wishlist',
            importance: Importance.Low, priority: Priority.Default, ticker: 'Stats saved', playSound: false, enableVibration: false,
            autoCancel: true, setAsGroupSummary: true, groupKey: 'Stat', style: AndroidNotificationStyle.BigPicture,
              styleInformation: BigPictureStyleInformation(
                file.path, BitmapSource.FilePath,
            ));
          var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, null);
          await flutterLocalNotificationsPlugin.cancel(notification);
          await flutterLocalNotificationsPlugin.show(
            1, 'Export complete', name, platformChannelSpecifics,
            payload: file.path);*/
          if((scaffoldState?.mounted ?? false)){
            final AndroidIntent intent = AndroidIntent(
              action: 'action_view',
              data: 'content://media/external/images/media/${name}_$time',
              type: 'image/*',
              flags: [1, 2]
            );
            scaffoldState?.hideCurrentSnackBar();
            scaffoldState?.showSnackBar(SnackBar(
              content: Text('Stats saved'),
              action: SnackBarAction(label: 'View', onPressed: () async => await intent.launch()),
            ));
          }
        }
      },
    );
  }
}

class SingleStat extends StatelessWidget{
  final String title;
  final int owned;
  final int wished;
  final int total;
  final WrapAlignment wrapAlignment;

  SingleStat({Key key, this.title, this.owned, this.wished, this.total,
    this.wrapAlignment = WrapAlignment.spaceAround}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          alignment: wrapAlignment,
          children: <Widget>[
            SizedBox(
              height: 21.24,
              width: double.infinity,
              child: FittedBox(
                alignment: Alignment.center,
                child: Text(title, softWrap: false, textAlign: TextAlign.center,
                  overflow: TextOverflow.fade, style: Theme.of(context).textTheme.display1,),
              ),
            ),
            const Divider(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: StatWidget(
                num: owned.toDouble(),
                den: total.toDouble(),
                text: translate.owned,
                icon: Icon(iconOwnedDark, color: Colors.green[800])
              )
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: StatWidget(
                num: wished.toDouble(),
                den: total.toDouble(),
                text: translate.wished,
                icon: Icon(Icons.whatshot, color: Colors.amber[800]),
              )
            ),
          ],
        ),
      )
    );
  }
}