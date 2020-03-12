import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/widget/radial_progression.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui show FontFeature;
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';
import 'package:amiibo_network/service/storage.dart';

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
                    child: Text('All'),
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
                    child: Text('Figures'),
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
                    child: Text('Cards'),
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
    return FloatingActionButton(
      child: const Icon(Icons.save),
      tooltip: 'save stats',
      heroTag: 'MenuFAB',
      onPressed: () async {
        final ScaffoldState scaffoldState = Scaffold.of(context, nullOk: true);
        final Map<PermissionGroup, PermissionStatus> response =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
        final Map<String,dynamic> permission = checkPermission(
          response[PermissionGroup.storage]
        );
        String message = permission['message'];
        if(permission['permission']) message = permissionMessage;
        if(_screenshot.isRecording) message = recordMessage;
        scaffoldState?.hideCurrentSnackBar();
        scaffoldState?.showSnackBar(SnackBar(content: Text(message)));
        if(permission['permission'] && !_screenshot.isRecording) {
          _screenshot..theme = Theme.of(context).copyWith()
            ..statProvider = Provider.of<StatProvider>(context, listen: false);
          final String response = await _screenshot.drawStats(_select);
          if(response.isNotEmpty && (scaffoldState?.mounted ?? false)){
            scaffoldState?.hideCurrentSnackBar();
            scaffoldState?.showSnackBar(SnackBar(content: Text(response)));
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
    return Card(
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              child: Radial(
                icon: AnimatedRadial(
                  key: Key('Owned'),
                  percentage: owned.toDouble() / total.toDouble(),
                  child: Icon(iconOwnedDark, color: Colors.green[800]),
                ),
                label: Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Consumer<StatProvider>(
                      builder: (ctx, stat, _){
                        final String ownedStat = stat.statLabel(
                            owned.toDouble(),
                            total.toDouble()
                        );
                        return RichText(
                          text: TextSpan(
                              text: ownedStat,
                              style: Theme.of(context).textTheme.subhead.copyWith(
                                fontSize: stat.prefStat ? null : 22,
                                fontFeatures: [
                                  if(!stat.prefStat) ui.FontFeature.enable('frac'),
                                  if(stat.prefStat) ui.FontFeature.tabularFigures()
                                ],
                              ),
                              children: [
                                TextSpan(
                                  style: Theme.of(context).textTheme.subhead,
                                  text: ' Owned'
                                )
                              ]
                          ),
                        );
                      }
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Radial(
                icon: AnimatedRadial(
                  key: Key('Wished'),
                  percentage: wished.toDouble() / total.toDouble(),
                  child: Icon(Icons.whatshot, color: Colors.amber[800]),
                ),
                label: Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Consumer<StatProvider>(
                      builder: (ctx, stat, _){
                        final String wishedStat = stat.statLabel(
                            wished.toDouble(),
                            total.toDouble()
                        );
                        return RichText(
                          text: TextSpan(
                            text: wishedStat,
                            style: Theme.of(context).textTheme.subhead.copyWith(
                              fontSize: stat.prefStat ? null : 22,
                              fontFeatures: [
                                if(!stat.prefStat) ui.FontFeature.enable('frac'),
                                if(stat.prefStat) ui.FontFeature.tabularFigures()
                              ],
                            ),
                            children: [
                              TextSpan(
                                  style: Theme.of(context).textTheme.subhead,
                                  text: ' Wished'
                              )
                            ]
                          ),
                        );
                      }
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}