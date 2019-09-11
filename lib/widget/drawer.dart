import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';

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
    AmiiboProvider provider = Provider.of<AmiiboProvider>(context, listen: false);
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
                  highlightColor: Theme.of(context).accentColor
                ),
                child: Scrollbar(
                  child: Selector<AmiiboProvider, String>(
                    builder: (context, _selected, child) {
                      return CustomScrollView(
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildListDelegate([
                              child,
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
                                      accentColor: Theme.of(context).textTheme.subhead.color,
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
                                          accentColor: Theme.of(context).textTheme.subhead.color,
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
              trailing: ThemeButton()
            ),
          ],
        )
      ),
    );
  }
}

class ThemeButton extends StatelessWidget{

  Widget _selectWidget(String value){
    switch(value){
      case 'Light':
        return const Icon(Icons.wb_sunny);
      case 'Dark':
        return const Icon(Icons.brightness_3, color: Colors.amber);
      default:
        return const Icon(Icons.brightness_auto);
    }
  }

  void changeTheme(BuildContext context, String strTheme){
    switch(strTheme){
      case 'Light':
        Provider.of<ThemeProvider>(context, listen: false).themeDB('Dark');
        break;
      case 'Dark':
        Provider.of<ThemeProvider>(context, listen: false).themeDB('Auto');
        break;
      default:
        Provider.of<ThemeProvider>(context, listen: false).themeDB('Light');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ThemeProvider, String>(
      builder: (context, strTheme, _) {
        return InkResponse(
          radius: 18,
          splashFactory: InkRipple.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Theme.of(context).primaryColorDark,
          child: Tooltip(
            message: '$strTheme Theme',
            child: _selectWidget(strTheme),
          ),
          onTap: () => changeTheme(context, strTheme),
        );
      },
      selector: (context, theme) => theme.savedTheme,
    );
  }
}

class _HeaderDrawer extends StatelessWidget {
  const _HeaderDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).selectedRowColor
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