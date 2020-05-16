import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/query_provider.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/service/screenshot.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:amiibo_network/service/storage.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/widget/stat_widget.dart';
import 'package:amiibo_network/service/notification_service.dart';
import '../model/query_builder.dart';
import '../utils/amiibo_category.dart';

class StatsPage extends StatefulWidget{

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  AmiiboCategory category = AmiiboCategory.All;
  Expression expression = And();
  QueryProvider _queryProvider;
  static const Color _selectedColor = Colors.black;
  Color _appBarColor, _indicatorColor, _unselectedColor;

  @override
  void initState(){
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _queryProvider = context.read<QueryProvider>();
    final ThemeData theme = Theme.of(context);
    _appBarColor = theme.appBarTheme.color;
    _indicatorColor = theme.indicatorColor;
    _unselectedColor = theme.appBarTheme.textTheme.headline6.color;
    super.didChangeDependencies();
  }

  void _updateCategory(AmiiboCategory newCategory){
    if(newCategory == category) return;
    setState(() {
      category = newCategory;
      switch(category){
        case AmiiboCategory.All:
          expression = And();
          break;
        case AmiiboCategory.Custom:
          expression =
            Bracket(InCond.inn('type', ['Figure', 'Yarn']) & InCond.inn('amiiboSeries', _queryProvider.customFigures))
            | Bracket(Cond.eq('type', 'Card') & InCond.inn('amiiboSeries', _queryProvider.customCards));
          break;
        case AmiiboCategory.Figures:
          expression = InCond.inn('type', ['Figure', 'Yarn']);
          break;
        case AmiiboCategory.Cards:
          expression = Cond.eq('type', 'Card');
          break;
        default:
          break;
      }
    });
  }

  bool get _canSave => AmiiboCategory.Custom != category ||
    (_queryProvider.customFigures.isNotEmpty || _queryProvider.customCards.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    final Size size = MediaQuery.of(context).size;
    if(size.longestSide >= 800)
      return SafeArea(
        child: Scaffold(
          body: Scrollbar(
            child: Row(
              children: <Widget>[
                NavigationRail(
                  destinations: <NavigationRailDestination>[
                    NavigationRailDestination(
                        icon: const Icon(Icons.all_inclusive),
                        label: Text(translate.all)
                    ),
                    NavigationRailDestination(
                        icon: const Icon(Icons.edit),
                        label: Text(translate.category(AmiiboCategory.Custom))
                    ),
                    NavigationRailDestination(
                        icon: const Icon(Icons.toys),
                        label: Text(translate.figures)
                    ),
                    NavigationRailDestination(
                        icon: const Icon(Icons.view_carousel),
                        label: Text(translate.cards)
                    )
                  ],
                  selectedIndex: category.index,
                  trailing: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation){
                        return ScaleTransition(
                          scale: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _canSave ? _FAB(category, expression) : const SizedBox(),
                    ),
                  ),
                  onDestinationSelected: (selected) =>
                    _updateCategory(AmiiboCategory.values[selected]),
                ),
                Expanded(
                  child: _BodyStats(expression)
                )
              ],
            )
          ),
        )
      );
    return SafeArea(
      child: Scaffold(
        body: _BodyStats(expression),
        floatingActionButton: _canSave ? _FAB(category, expression) : null,
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
                    textColor: category == AmiiboCategory.All ? _selectedColor : _unselectedColor,
                    color: category == AmiiboCategory.All ? _indicatorColor : null,
                    onPressed: () => category == AmiiboCategory.All ? null : _updateCategory(AmiiboCategory.All),
                    child: Text(translate.all, softWrap: false, overflow: TextOverflow.fade),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    shape: Border(
                      top: BorderSide(
                        color: _indicatorColor,
                        width: 2,
                      ),
                      bottom: BorderSide(
                        color: _indicatorColor,
                        width: 2,
                      ),
                      right: BorderSide(
                        color: _indicatorColor,
                        width: 2,
                      ),
                    ),
                    textColor: category == AmiiboCategory.Custom ? _selectedColor : _unselectedColor,
                    color: category == AmiiboCategory.Custom ? _indicatorColor : null,
                    onPressed: () => category == AmiiboCategory.Custom ? null : _updateCategory(AmiiboCategory.Custom),
                    child: Text(translate.category(AmiiboCategory.Custom), softWrap: false, overflow: TextOverflow.fade),
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
                    textColor: category == AmiiboCategory.Figures ? _selectedColor : _unselectedColor,
                    color: category == AmiiboCategory.Figures ? _indicatorColor : null,
                    onPressed: () => category == AmiiboCategory.Figures ? null : _updateCategory(AmiiboCategory.Figures),
                    child: Text(translate.figures, softWrap: false, overflow: TextOverflow.fade),
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
                    textColor: category == AmiiboCategory.Cards ? _selectedColor : _unselectedColor,
                    color: category == AmiiboCategory.Cards ? _indicatorColor : null,
                    onPressed: () => category == AmiiboCategory.Cards ? null : _updateCategory(AmiiboCategory.Cards),
                    child: Text(translate.cards, softWrap: false, overflow: TextOverflow.fade),
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

class _BodyStats extends StatelessWidget {
  final _service = Service();
  final Expression expression;

  _BodyStats(this.expression);

  Future<List<Map<String, dynamic>>> get _stats async{
    return <Map<String, dynamic>>[
      ... await _service.fetchSum( expression: expression),
      ... await _service.fetchSum(group: true, expression: expression)
    ];
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _stats,
      builder: (context, snapshot){
        if(snapshot.hasData){
          final Map<String, dynamic> generalStats = snapshot.data.first;
          final List<Map<String, dynamic>> stats = snapshot.data.sublist(1);
          if(generalStats.isNotEmpty && stats.isNotEmpty)
            return Scrollbar(
                child: CustomScrollView(
                  slivers: <Widget>[
                    if(stats.length > 1)
                      SliverToBoxAdapter(
                          key: Key('Amiibo Network'),
                          child: SingleStat(
                            title: 'Amiibo Network',
                            owned: generalStats['Owned'],
                            total: generalStats['Total'],
                            wished: generalStats['Wished'],
                          )
                      ),
                    if(MediaQuery.of(context).size.width <= 600)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                            SingleStat(
                              key: ValueKey(index),
                              title: stats[index]['amiiboSeries'],
                              owned: stats[index]['Owned'],
                              total: stats[index]['Total'],
                              wished: stats[index]['Wished'],
                            ),
                          semanticIndexOffset: 1,
                          childCount: stats.length,
                        ),
                      ),
                    if(MediaQuery.of(context).size.width > 600)
                      SliverGrid(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 230,
                            childAspectRatio: 1.22,
                            mainAxisSpacing: 8.0,
                          ),
                          delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                              SingleStat(
                                key: ValueKey(index),
                                title: stats[index]['amiiboSeries'],
                                owned: stats[index]['Owned'],
                                total: stats[index]['Total'],
                                wished: stats[index]['Wished'],
                              ),
                            semanticIndexOffset: 1,
                            childCount: stats.length,
                          )
                      ),
                    const SliverToBoxAdapter(child: const SizedBox(height: 80))
                  ],
                )
            );
          return DefaultTextStyle(
              style: Theme.of(context).textTheme.headline4,
              child: Center(
                child: Text(translate.emptyPage,),
              )
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _FAB extends StatelessWidget{
  final Screenshot _screenshot = Screenshot();
  final AmiiboCategory _category;
  final Expression _expression;

  _FAB(this._category, this._expression);

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
          switch(_category){
            case AmiiboCategory.Cards:
              name = 'MyCardStats';
              id = 2;
              break;
            case AmiiboCategory.Figures:
              name = 'MyFigureStats';
              id = 3;
              break;
            case AmiiboCategory.Custom:
              name = 'MyCustomStats';
              id = 7;
              break;
            case AmiiboCategory.All:
            default:
              name = 'MyAmiiboStats';
              id = 1;
              break;
          }
          final file = await createFile(name, 'png');
          final bool saved = await _screenshot.saveStats(_expression, file);
          final Map<String, dynamic> notificationArgs = <String, dynamic>{
            'title': translate.notificationTitle,
            'path': file.path,
            'actionTitle': translate.actionText,
            'id': id
          };
          if(saved) await NotificationService.sendNotification(notificationArgs);
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

  const SingleStat({Key key, this.title, this.owned, this.wished, this.total,
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