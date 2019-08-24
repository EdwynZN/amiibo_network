import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:amiibo_network/bloc/theme_bloc.dart';

typedef StringCallback = void Function(String string);

class CollectionDrawer extends StatefulWidget{
  final String selected;
  final StringCallback onTap;
  CollectionDrawer({Key key, this.selected, this.onTap}) : super(key: key);

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

  void _onTapTile(BuildContext context, String tile){
    widget.onTap(tile);
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
                  highlightColor: Theme.of(context).accentColor,
                ),
                child: Scrollbar(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate([
                          _HeaderDrawer(),
                          ListTile(
                            onTap: () => _onTapTile(context, 'All'),
                            leading: const Icon(Icons.all_inclusive),
                            title: Text('All',),
                            selected: widget.selected == 'All',
                          ),
                          ListTile(
                            onTap: () => _onTapTile(context, 'Owned'),
                            leading: const Icon(Icons.star),
                            title: Text('Owned'),
                            selected: widget.selected == 'Owned',
                          ),
                          ListTile(
                            onTap: () => _onTapTile(context, 'Wishlist'),
                            leading: const Icon(Icons.card_giftcard),
                            title: Text('Wishlist'),
                            selected: widget.selected == 'Wishlist',
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context,"/stats");
                            },
                            leading: const Icon(Icons.timeline),
                            title: Text('Stats',),
                            selected: widget.selected == 'Stats',
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
                                        onTap: () => _onTapTile(context, series),
                                        selected: widget.selected == series,
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
                                        onTap: () => _onTapTile(context, series),
                                        selected: widget.selected == series,
                                      ),
                                  ],
                                )
                              );
                            }
                          ),
                        ]),
                      )
                    ],
                  )
                )
              ),
            ),
            const Divider(height: 1.0),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context,"/settings");
              },
              leading: const Icon(Icons.settings),
              title: Text('Settings',),
              selected: widget.selected == 'Stats',
              trailing: ThemeButton()
            ),
          ],
        )
      ),
    );
  }
}

class ThemeButton extends StatefulWidget{
  static final ThemeBloc _themeBloc = $Provider.of<ThemeBloc>();

  @override
  _ThemeButtonState createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton> {
  Widget _icon;

  @override
  void initState(){
    _icon = _changeWidget();
    super.initState();
  }

  @override
  void didUpdateWidget(ThemeButton oldWidget) {
    _icon = _changeWidget();
    super.didUpdateWidget(oldWidget);
  }

  Widget _changeWidget(){
    switch(ThemeButton._themeBloc.savedTheme){
      case 'Light':
        return const Icon(Icons.wb_sunny);
      case 'Dark':
        return const Icon(Icons.brightness_3, color: Colors.amber);
      default:
        return const Icon(Icons.brightness_auto);
    }
  }

  void changeTheme(){
    switch(ThemeButton._themeBloc.savedTheme){
      case 'Light':
        ThemeButton._themeBloc.themeDB('Dark');
        break;
      case 'Dark':
        ThemeButton._themeBloc.themeDB('Auto');
        break;
      default:
        ThemeButton._themeBloc.themeDB('Light');
        break;
    }
    setState(() => _icon = _changeWidget());
  }

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 18,
      highlightColor: Colors.transparent,
      splashColor: Theme.of(context).unselectedWidgetColor,
      child: _icon,
      onTap: changeTheme,
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