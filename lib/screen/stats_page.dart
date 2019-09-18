import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/widget/radial_progression.dart';

class StatsPage extends StatefulWidget{
  static final _service = Service();

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  ScrollController _controller;
  Set<String> select = {};

  @override
  void initState(){
    super.initState();
    _controller = ScrollController();
  }

  Future<List<Map<String, dynamic>>> get _retrieveStats
    => StatsPage._service.fetchSum(group: true, column: 'type', args: select.toList());

  Future<List<Map<String, dynamic>>> get _generalStats
    => StatsPage._service.fetchSum(column: 'type', args: select.toList());

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
          child: CustomScrollView(
            controller: _controller,
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
                        childCount: snapshot.hasData ? snapshot.data.length : 0,
                      ),
                    );
                  else return SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      childAspectRatio: 1.25,
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
                      childCount: snapshot.hasData ? snapshot.data.length : 0,
                    )
                  );
                }
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.tight,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                      side: BorderSide(
                        color: Theme.of(context).indicatorColor,//const Color(0xFFE8C2BF),
                        width: 2,
                      )
                    ),
                    textColor: select.isEmpty ?
                    Theme.of(context).textTheme.title.color : Theme.of(context).appBarTheme.textTheme.title.color,
                    color: select.isEmpty ?
                    Theme.of(context).indicatorColor : null,//Theme.of(context).buttonColor,
                    onPressed: () => select.isEmpty ? null : setState(() {
                      select.clear();
                      if(_controller.offset != _controller.initialScrollOffset)
                        _controller.jumpTo(0);
                    }),
                    child: Text('All'),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: FlatButton(
                    shape: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).indicatorColor,//const Color(0xFFE8C2BF),
                        width: 2,
                      ),
                      top: BorderSide(
                        color: Theme.of(context).indicatorColor,//const Color(0xFFE8C2BF),
                        width: 2,
                      ),
                    ),
                    textColor: select.contains('Figure') ?
                    Theme.of(context).textTheme.title.color : Theme.of(context).appBarTheme.textTheme.title.color,
                    color: select.contains('Figure') ?
                    Theme.of(context).indicatorColor : null,//Theme.of(context).buttonColor,
                    onPressed: () => select.contains('Figure') ? null : setState(() {
                      select.clear();
                      select = {'Figure', 'Yarn'};
                      if(_controller.offset != _controller.initialScrollOffset)
                        _controller.jumpTo(0);
                    }),
                    child: Text('Figures'),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                      side: BorderSide(
                        color: Theme.of(context).indicatorColor,//const Color(0xFFE8C2BF),
                        width: 2,
                      )
                    ),
                    textColor: select.contains('Card') ?
                    Theme.of(context).textTheme.title.color : Theme.of(context).appBarTheme.textTheme.title.color,
                    color: select.contains('Card') ?
                    Theme.of(context).indicatorColor : null,//Theme.of(context).buttonColor,
                    onPressed: () => select.contains('Card') ? null : setState(() {
                      select.clear();
                      select = {'Card'};
                      if(_controller.offset != _controller.initialScrollOffset)
                        _controller.jumpTo(0);
                    }),
                    child: Text('Cards'),
                  ),
                ),
              ],
            ),
          ),
          /*
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 9,
                  child: FlatButton(
                    textColor: Theme.of(context).textTheme.title.color,
                    color: select.isEmpty ?
                    Theme.of(context).indicatorColor : Theme.of(context).buttonColor,
                    onPressed: () => select.isEmpty ? null : setState(() {
                      select.clear();
                      if(_controller.offset != _controller.initialScrollOffset)
                        _controller.jumpTo(0);
                    }),
                    child: Text('All'),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 9,
                  child: FlatButton(
                    textColor: Theme.of(context).textTheme.title.color,
                    color: select.contains('Figure') ?
                    Theme.of(context).indicatorColor : Theme.of(context).buttonColor,
                    onPressed: () => select.contains('Figure') ? null : setState(() {
                      select.clear();
                      select = {'Figure', 'Yarn'};
                      if(_controller.offset != _controller.initialScrollOffset)
                        _controller.jumpTo(0);
                    }),
                    child: Text('Figures'),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 9,
                  child: FlatButton(
                    textColor: Theme.of(context).textTheme.title.color,
                    color: select.contains('Card') ?
                    Theme.of(context).indicatorColor : Theme.of(context).buttonColor,
                    onPressed: () => select.contains('Card') ? null : setState(() {
                      select.clear();
                      select = {'Card'};
                      if(_controller.offset != _controller.initialScrollOffset)
                        _controller.jumpTo(0);
                    }),
                    child: Text('Cards'),
                  ),
                ),
              ],
            ),
          )
          * */
        ),
      )
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
            FittedBox(
              alignment: Alignment.center,
              child: Text(title, softWrap: false, textAlign: TextAlign.center,
                overflow: TextOverflow.fade, style: Theme.of(context).textTheme.display1,),
            ),
            const Divider(),
            Chip(label: Text('$owned/$total Owned', softWrap: false,
              overflow: TextOverflow.fade,),
              avatar: AnimatedRadial(
                key: Key('Owned'),
                percentage: owned.toDouble() / total.toDouble(),
                child: const Icon(Icons.check, color: Colors.green),
              ),
            ),
            Chip(
              label: Text('$wished/$total Wished', softWrap: false,
              overflow: TextOverflow.fade),
              avatar: AnimatedRadial(
                key: Key('Owned'),
                percentage: wished.toDouble() / total.toDouble(),
                child: const Icon(Icons.whatshot, color: Colors.amber),
              ),
            )
          ],
        ),
      )
    );
  }
}