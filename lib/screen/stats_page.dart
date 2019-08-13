import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/widget/radial_progression.dart';

class StatsPage extends StatelessWidget{
  static final _service = Service();

  Future<List<Map<String, dynamic>>> get _retrieveStats
    => _service.fetchSum(all: true, group: true);

  Future<List<Map<String, dynamic>>> get _generalStats
    => _service.fetchSum(all: true);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Scrollbar(
          child: CustomScrollView(
            slivers: <Widget>[
              FutureBuilder(
                future: _generalStats,
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                      SingleStat(
                        key: ValueKey(index),
                        title: 'Amiibo Network',
                        owned: snapshot.data[index]['Owned'],
                        total: snapshot.data[index]['Total'],
                        wished: snapshot.data[index]['Wished'],
                      ),
                      addRepaintBoundaries: false, addAutomaticKeepAlives: false,
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
                        addRepaintBoundaries: false, addAutomaticKeepAlives: false,
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
                      addRepaintBoundaries: false, addAutomaticKeepAlives: false,
                      childCount: snapshot.hasData ? snapshot.data.length : 0,
                    )
                  );
                }
              ),
            ],
          ),
        )
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
    this.wrapAlignment = WrapAlignment.spaceAround}) :  super(key: key);

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
              avatar: CustomPaint(
                size: Size(24, 24),
                painter: RadialProgression(owned.toDouble()/total.toDouble()),
                child: owned.toDouble() == total.toDouble() ?
                  const Icon(Icons.check, color: Colors.green) : null,
              ),
            ),
            Chip(
              label: Text('$wished/$total Wished', softWrap: false,
              overflow: TextOverflow.fade),
              avatar: CustomPaint(
                size: Size(24, 24),
                painter: RadialProgression(wished.toDouble()/total.toDouble()),
                child: wished.toDouble() == total.toDouble() ?
                  const Icon(Icons.whatshot, color: Colors.amber) : null,
              ),
            )
          ],
        ),
      )
    );
  }
}