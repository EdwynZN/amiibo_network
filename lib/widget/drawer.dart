import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';

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
      dense: false,
      child: Drawer(
        child: CustomScrollView(
          cacheExtent: 150,
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  _HeaderDrawer(),
                  /*SizedBox(height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      children: <Widget>[
                        ChoiceChip(label: Text('Europe'), selected: true,
                          avatar: Image.asset('assets/images/eu.png',
                            fit: BoxFit.scaleDown,
                            height: 24, width: 24,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'), selected: false,
                            avatar: Icon(Icons.all_inclusive)
                        ),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'),
                            selected: true,
                            avatar: Icon(Icons.sort)),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'), selected: true,
                            avatar: Icon(Icons.forward)
                        ),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'), selected: false,
                            avatar: Icon(Icons.all_inclusive)
                        ),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'),
                            selected: true,
                            avatar: Icon(Icons.sort)),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'), selected: true,
                            avatar: Icon(Icons.forward)
                        ),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'), selected: false,
                            avatar: Icon(Icons.all_inclusive)
                        ),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'),
                            selected: true,
                            avatar: Icon(Icons.sort)),
                        const SizedBox(width: 8.0),
                        ChoiceChip(label: Text('All'),
                            selected: true,
                            avatar: Icon(Icons.sort)),
                      ],
                    ),
                  ),*/
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      accentColor: Theme.of(context).textTheme.subhead.color,
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.sort_by_alpha),
                      title: Text('Sort by: '),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ChoiceChip(label: Text('Name'),
                                selected: true,
                                avatar: Icon(Icons.keyboard_arrow_up)),
                            ChoiceChip(label: Text('Name'),
                                selected: true,
                                avatar: Icon(Icons.keyboard_arrow_down))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ChoiceChip(label: Text('Wished'),
                                selected: true,
                                avatar: Icon(Icons.keyboard_arrow_up)),
                            ChoiceChip(label: Text('Wished'),
                                selected: true,
                                avatar: Icon(Icons.keyboard_arrow_down))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            ChoiceChip(label: Text('Owned'), selected: true,
                                avatar: Icon(Icons.keyboard_arrow_up)
                            ),
                            ChoiceChip(label: Text('Owned'), selected: false,
                              avatar: Icon(Icons.keyboard_arrow_down)
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                  const Divider(height: 1.0),
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
                  const Divider(height: 1.0),
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
                                  //contentPadding: const EdgeInsets.only(left: 72),
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
                ],
              )
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