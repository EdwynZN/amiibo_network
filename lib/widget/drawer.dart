import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:amiibo_network/provider/stat_provider.dart';

class CollectionDrawer extends StatefulWidget{
  final VoidCallback restart;

  CollectionDrawer({Key key, this.restart}) : super(key: key);

  @override
  _CollectionDrawerState createState() => _CollectionDrawerState();
}

class _CollectionDrawerState extends State<CollectionDrawer> {
  static final Service _service = Service();
  static bool _figureExpand = false;
  static bool _cardExpand = false;

  Future<List<String>> get _listOfFigures => _service.fetchDistinct();
  Future<List<String>> get _listOfCards => _service.fetchDistinct(false);

  void figureExpand(bool x) => _figureExpand = x;
  void cardExpand(bool x) => _cardExpand = x;

  void _onTapTile(String tile){
    final AmiiboProvider provider = Provider.of<AmiiboProvider>(context, listen: false);
    if(provider.strFilter != tile) {
      provider.resetPagination(tile);
      widget.restart();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      iconColor: Theme.of(context).iconTheme.color,
      textColor: Theme.of(context).textTheme.body1.color,
      style: ListTileStyle.drawer,
      selectedColor: Theme.of(context).accentColor,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: Theme.of(context).selectedRowColor
                ),
                child: Scrollbar(
                  child: Selector<AmiiboProvider, String>(
                    builder: (context, _selected, child) {
                      return CustomScrollView(
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              child,
                              Consumer<StatProvider>(
                                child: Text('Show percentage', overflow: TextOverflow.fade,),
                                builder: (ctx, _statMode, child){
                                  return SwitchListTile.adaptive(
                                    secondary: const SizedBox(),
                                    title: child,
                                    value: _statMode.prefStat,
                                    onChanged: Provider.of<StatProvider>(ctx, listen: false).spStat,
                                  );
                                },
                              ),
                              ListTile(
                                onTap: () => _onTapTile('All'),
                                leading: const Icon(Icons.all_inclusive),
                                title: Text('All',),
                                selected: _selected == 'All',
                              ),
                              ListTile(
                                onTap: () => _onTapTile('Owned'),
                                leading: const Icon(Icons.star),
                                title: Text('Owned'),
                                selected: _selected == 'Owned',
                              ),
                              ListTile(
                                onTap: () => _onTapTile('Wishlist'),
                                leading: const Icon(Icons.card_giftcard),
                                title: Text('Wishlist'),
                                selected: _selected == 'Wishlist',
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context,"/stats");
                                },
                                leading: const Icon(Icons.timeline),
                                title: Text('Stats',),
                                selected: _selected == 'Stats',
                              ),
                              FutureBuilder(
                                future: _listOfFigures,
                                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                      accentColor: Theme.of(context).iconTheme.color,
                                    ),
                                    child: ExpansionTile(
                                      leading: const Icon(Icons.toys),
                                      title: Text('Figures'),
                                      initiallyExpanded: _figureExpand,
                                      onExpansionChanged: figureExpand,
                                      children: <Widget>[
                                        if(snapshot.hasData)
                                          for(String series in snapshot.data)
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Theme.of(context).accentColor,
                                                foregroundColor: Theme.of(context).accentIconTheme.color,
                                                radius: 12,
                                                child: Text(series[0]),
                                              ),
                                              title: Text(series),
                                              onTap: () => _onTapTile(series),
                                              selected: _selected == series,
                                            ),
                                      ],
                                    )
                                  );
                                }
                              ),
                              FutureBuilder(
                                future: _listOfCards,
                                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                      accentColor: Theme.of(context).iconTheme.color,
                                    ),
                                    child: ExpansionTile(
                                      leading: const Icon(Icons.view_carousel),
                                      title: Text('Cards'),
                                      initiallyExpanded: _cardExpand,
                                      onExpansionChanged: cardExpand,
                                      children: <Widget>[
                                        if(snapshot.hasData)
                                          for(String series in snapshot.data)
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Theme.of(context).accentColor,
                                                foregroundColor: Theme.of(context).accentIconTheme.color,
                                                radius: 12,
                                                child: Text(series[0]),
                                              ),
                                              title: Text(series),
                                              onTap: () => _onTapTile(series),
                                              selected: _selected == series,
                                            ),
                                      ],
                                    )
                                  );
                                }
                              ),
                            ]),
                          )
                        ],
                      );
                    },
                    selector: (context, filter) => filter.strFilter,
                    child: _HeaderDrawer(),
                  )
                )
              )
            ),
            const Divider(height: 1.0),
            ListTile(
              dense: true,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context,"/settings");
              },
              leading: const Icon(Icons.settings),
              title: Text('Settings',),
              trailing: ThemeButton(openDialog: true,)
            ),
          ],
        )
      ),
    );
  }
}

class _HeaderDrawer extends StatelessWidget {
  const _HeaderDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor
      ),
      padding: EdgeInsets.zero,
      child: Image.asset('assets/images/icon_app.png',
        fit: BoxFit.fitHeight,
        color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white54 : null,
      ),
    );
  }
}