import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/widget/stat_widget.dart';
import 'package:amiibo_network/service/notification_service.dart';

class StatsPage extends StatefulWidget{

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _service = Service();
  ScrollController _controller;
  Set<String> select = <String>{};
  static const Color _selectedColor = Colors.black;
  Color _appBarColor, _indicatorColor, _unselectedColor;

  @override
  void initState(){
    super.initState();
    _controller = ScrollController();
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _appBarColor = theme.appBarTheme.color;
    _indicatorColor = theme.indicatorColor;
    //_selectedColor = theme.accentIconTheme.color;
    _unselectedColor = theme.appBarTheme.textTheme.headline6.color;
    super.didChangeDependencies();
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
          color: _appBarColor,
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
                        color: _indicatorColor,
                        width: 2,
                      )
                    ),
                    textColor: select.isEmpty ? _selectedColor : _unselectedColor,
                    color: select.isEmpty ? _indicatorColor : null,
                    onPressed: () => select.isEmpty ? null : _updateSet(Set<String>()),
                    child: Text(translate.all),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    shape: Border.symmetric(
                      vertical: BorderSide(
                        color: _indicatorColor,
                        width: 2,
                      ),
                      horizontal: BorderSide.none
                    ),
                    textColor: select.contains('Figure') ? _selectedColor : _unselectedColor,
                    color: select.contains('Figure') ? _indicatorColor : null,
                    onPressed: () => select.contains('Figure') ? null : _updateSet(<String>{'Figure', 'Yarn'}),
                    child: Text(translate.figures),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      side: BorderSide(
                        color: _indicatorColor,
                        width: 2,
                      )
                    ),
                    textTheme: ButtonTextTheme.normal,
                    colorBrightness: select.contains('Card') ? Brightness.dark : Brightness.light,
                    textColor: select.contains('Card') ? _selectedColor : _unselectedColor,
                    color: select.contains('Card') ? _indicatorColor : null,
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
        String message = translate.savingCollectionMessage;
        if(_screenshot.isRecording) message = translate.recordMessage;
        scaffoldState?.hideCurrentSnackBar();
        scaffoldState?.showSnackBar(SnackBar(content: Text(message),));
        final permission = true;
        if(permission && !_screenshot.isRecording) {
          _screenshot.update(context);
          String name;
          int id;
          if(_select.isEmpty){
            name = 'MyAmiiboStats';
            id = 1;
          } else if(_select.contains('Card')){
            name = 'MyCardStats';
            id = 2;
          } else{
            name = 'MyFigureStats';
            id = 3;
          }
          final file = await createFile(name, 'png');
          await _screenshot.saveStats(_select, file);
          final Map<String, dynamic> notificationArgs = <String, dynamic>{
            'title': translate.notificationTitle,
            'path': file.path,
            'actionTitle': translate.actionText,
            'id': id
          };
          await NotificationService.sendNotification(notificationArgs);
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
                  overflow: TextOverflow.fade, style: Theme.of(context).textTheme.headline4,),
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