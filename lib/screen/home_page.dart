import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/widget/radial_progression.dart';
import 'package:amiibo_network/widget/drawer.dart';
import 'package:amiibo_network/widget/animated_widgets.dart';
import 'package:amiibo_network/widget/floating_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  ScrollController _controller;
  AnimationController _animationController;
  static Widget _defaultLayoutBuilder(Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    if (currentChild != null)
      children = children.toList()..add(currentChild);
    return Stack(
      children: children,
      alignment: Alignment.centerRight,
    );
  }

  void _restartAnimation(){
    _controller.jumpTo(0);
    _animationController.forward();
  }

  void _updateSelection({int wished = 0, int owned = 0}) async {
    AmiiboProvider selected = Provider.of<AmiiboProvider>(context, listen: false);
    AmiiboLocalDB amiibos = AmiiboLocalDB(amiibo: List<AmiiboDB>.of(
        selected.set.map((x) => AmiiboDB(key: x.value, wishlist: wished, owned: owned))
    )
    );
    selected.clearSelected();
    await selected.updateAmiiboDB(amiibos: amiibos);
    await selected.refreshPagination();
  }

  void _cancelSelection(){
    AmiiboProvider selected = Provider.of<AmiiboProvider>(context, listen: false);
    selected.clearSelected();
  }

  void initBloc() async =>
      await Provider.of<AmiiboProvider>(context, listen: false).fetchAllAmiibosDB();

  @override
  void initState(){
    initBloc();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this)..value = 1.0;
    super.initState();
  }

  @override
  void dispose(){
    //ConnectionFactory().close();
    _controller?.removeListener(_scrollListener);
    _controller?.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _scrollListener(){
    if((_controller?.hasClients ?? false) && !_animationController.isAnimating){
      switch(_controller.position.userScrollDirection){
        case ScrollDirection.forward:
          if(_animationController.isDismissed) _animationController.forward();
          break;
        case ScrollDirection.reverse:
          if(_animationController.isCompleted) _animationController.reverse();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
  }

  void _search() async{
    var value = await Navigator.pushNamed(context,"/search");
    if(value != null && value != '') {
      Provider.of<AmiiboProvider>(context, listen: false)
          .resetPagination(value, search: true);
      _restartAnimation();
    }
  }

  Future<bool> _exitApp() async{
    final AmiiboProvider selected = Provider.of<AmiiboProvider>(context, listen: false);
    if(selected.multipleSelected){
      selected.clearSelected();
      return false;
    } else {
      await ConnectionFactory().close();
      return await Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
          onWillPop: _exitApp,
          child: Selector<AmiiboProvider, bool>(
            selector: (_, amiibo) => amiibo.multipleSelected,
            child: SliverPersistentHeader(
              delegate: _SliverPersistentHeader(),
              pinned: true,
            ),
            builder: (_, _multipleSelection, child){
              return Scaffold(
                resizeToAvoidBottomInset: false,
                drawer: _multipleSelection ? null : CollectionDrawer(restart: _restartAnimation,),
                body: Scrollbar(
                    child: CustomScrollView(
                      controller: _controller,
                      slivers: <Widget>[
                        SliverFloatingBar(
                          floating: true,
                          forward: _multipleSelection,
                          snap: true,
                          leading: Builder(
                              builder: (context) => IconButton(
                                icon: ImplicitIcon(forward: _multipleSelection),
                                tooltip: _multipleSelection ? 'close' : 'drawer',
                                onPressed: _multipleSelection ? _cancelSelection : () => Scaffold.of(context).openDrawer(),
                              )
                          ),
                          title: Selector<AmiiboProvider, String>(
                            selector: (context, text) => text.strFilter,
                            builder: (context, text, _) {
                              return Tooltip(
                                message: '${num.tryParse(text) == null ?
                                'Search Amiibo' : '$text Selected' }',
                                child: Text(text ?? ''),
                              );
                            },
                          ),
                          onTap: _multipleSelection ? null : _search,
                          trailing: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            layoutBuilder: _defaultLayoutBuilder,
                            child: _multipleSelection ? Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: _updateSelection,
                                  tooltip: 'Remove',
                                ),
                                IconButton(
                                  icon: Icon(Icons.star),
                                  onPressed: () => _updateSelection(owned: 1),
                                  tooltip: 'Own',
                                ),
                                IconButton(
                                  icon: Icon(Icons.card_giftcard),
                                  onPressed: () => _updateSelection(wished: 1),
                                  tooltip: 'Wish',
                                ),
                              ],
                            ) : _SortCollection(),
                          )
                      ),
                        child,
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          sliver: Selector<AmiiboProvider, AmiiboLocalDB>(
                            child: const SliverToBoxAdapter(
                              child: const Align(alignment: Alignment.center, heightFactor: 10,
                                child: const Text('Nothing to see here',
                                  textAlign: TextAlign.center,
                                )
                              )
                            ),
                            selector: (context, amiibo) => amiibo.amiibosDB,
                            builder: (context, data, child){
                              if((data?.amiibo?.length ?? 1) == 0)
                                return DefaultTextStyle(
                                  style: Theme.of(context).textTheme.display1,
                                  child: child,
                                );
                              else return SliverGrid(
                                gridDelegate: MediaQuery.of(context).size.width >= 600 ?
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  mainAxisSpacing: 8.0,
                                ) :
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8.0
                                ),
                                delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                                  return FadeSwitchAnimation(
                                    key: ValueKey<int>(index),
                                    child: AmiiboGrid(
                                      key: ValueKey<int>(data?.amiibo[index].key),
                                      amiibo: data?.amiibo[index],
                                    ),
                                  );
                                },
                                  addRepaintBoundaries: false, addAutomaticKeepAlives: false,
                                  childCount: data?.amiibo != null ? data?.amiibo?.length : 0,
                                )
                              );
                            },
                          )
                        ),
                    ],
                  )
                ),
                floatingActionButton: FAB(_animationController, () => _controller.jumpTo(0)),
              );
            },
          ),
        )
    );
  }
}

class _SliverPersistentHeader extends SliverPersistentHeaderDelegate {

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.75),
              ]
          )
      ),
      height: kToolbarHeight,
      child: StreamBuilder<Map<String,dynamic>>(
          initialData: {'Owned' : 0, 'Wished' : 0, 'Total' : 0},
          stream: Provider.of<AmiiboProvider>(context, listen: false).collectionList,
          builder: (context , statList) {
            if(statList.data['Total'] == 0 || statList == null)
              return const SizedBox();
            return Row(
              children: <Widget>[
                Expanded(
                    child: FlatButton.icon(
                        onPressed: null,
                        icon: AnimatedRadial(
                          key: Key('Owned'),
                          percentage:
                          statList.data['Owned'].toDouble()
                              / statList.data['Total'].toDouble(),
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        label: FittedBox(
                          fit: BoxFit.contain,
                          child: Text('${statList.data['Owned']}/'
                              '${statList.data['Total']} Owned', softWrap: false,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subhead,
                          ),
                        )
                    )
                ),
                Expanded(
                    child: FlatButton.icon(
                        onPressed: null,
                        icon: AnimatedRadial(
                          key: Key('Wished'),
                          percentage:
                          statList.data['Wished'].toDouble()
                              / statList.data['Total'].toDouble(),
                          child: const Icon(Icons.whatshot, color: Colors.amber),
                        ),
                        label: FittedBox(
                          fit: BoxFit.contain,
                          child: Text('${statList.data['Wished']}/'
                              '${statList.data['Total']} Wished',
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subhead,
                          ),
                        )
                    )
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _SortCollection extends StatefulWidget{
  @override
  _SortCollectionState createState() => _SortCollectionState();
}

class _SortCollectionState extends State<_SortCollection> {

  void _selectOrder(String sort) async{
    AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    amiiboProvider.strOrderBy = sort;
    await amiiboProvider.refreshPagination();
    Navigator.pop(context);
  }

  Future<void> _dialog(BuildContext context) async {
    String _sortBy = Provider.of<AmiiboProvider>(context).orderBy;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            semanticLabel: 'Sort',
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  child: Text('Sort By'),
                ),
                const Divider(),
              ],
            ),
            titlePadding: const EdgeInsets.only(top: 12.0),
            contentPadding: const EdgeInsets.only(bottom: 8.0),
            children: <Widget>[
              RadioListTile(
                value: 'name',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('Name'),
                selected: _sortBy == 'name',
              ),
              RadioListTile(
                value: 'owned DESC',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                selected: _sortBy == 'owned DESC',
                title: Text('Owned'),
              ),
              RadioListTile(
                value: 'wishlist DESC',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('Wished'),
                selected: _sortBy == 'wishlist DESC',
              ),
              RadioListTile(
                value: 'na DESC',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('American Date'),
                selected: _sortBy == 'na DESC',
                secondary: Image.asset(
                  'assets/images/na.png',
                  height: 16, width: 25,
                  fit: BoxFit.fill,
                  semanticLabel: 'American Date',
                ),
              ),
              RadioListTile(
                value: 'eu DESC',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('European Date'),
                selected: _sortBy == 'eu DESC',
                secondary: Image.asset(
                  'assets/images/eu.png',
                  height: 16, width: 25,
                  fit: BoxFit.fill,
                  semanticLabel: 'European date',
                ),
              ),
              RadioListTile(
                  value: 'jp DESC',
                  groupValue: _sortBy,
                  onChanged: _selectOrder,
                  dense: true,
                  title: Text('Japanese Date'),
                  selected: _sortBy == 'jp DESC',
                  secondary: DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.75)
                    ),
                    position: DecorationPosition.foreground,
                    child: Image.asset(
                      'assets/images/jp.png',
                      height: 16, width: 25,
                      fit: BoxFit.fill,
                      semanticLabel: 'Japanese date',
                    ),
                  )
              ),
              RadioListTile(
                value: 'au DESC',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('Australian Date'),
                selected: _sortBy == 'au DESC',
                secondary: Image.asset(
                  'assets/images/au.png',
                  height: 16, width: 25,
                  fit: BoxFit.fill,
                  semanticLabel: 'Australian date',
                ),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _dialog(context),
      icon: const Icon(Icons.sort_by_alpha),
      tooltip: 'Sort',
    );
  }
}

class FAB extends StatelessWidget{
  final Animation<double> scale;
  final AnimationController controller;
  final VoidCallback goTop;

  FAB(this.controller, this.goTop):
    scale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
        CurvedAnimation(parent: controller,
          curve: Interval(0.0, 1, curve: Curves.decelerate),
        )
    );

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: scale,
        child: FloatingActionButton(
          tooltip: 'Up',
          mini: true,
          heroTag: 'MenuFAB',
          onPressed: goTop,
          child: const Icon(Icons.keyboard_arrow_up),
        )
    );
  }
}

class AmiiboGrid extends StatefulWidget {
  final AmiiboDB amiibo;

  const AmiiboGrid({
    Key key,
    this.amiibo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AmiiboGridState();
}

class AmiiboGridState extends State<AmiiboGrid> {
  Widget _widget;

  @override
  void initState(){
    super.initState();
    _widget = _changeWidget();
  }

  @override
  void didUpdateWidget(AmiiboGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    _widget = _changeWidget();
  }

  Widget _changeWidget(){
    if(widget.amiibo?.wishlist?.isOdd ?? false)
      return const Icon(Icons.card_giftcard, key: ValueKey(2), color: Colors.limeAccent,);
    else if(widget.amiibo?.owned?.isOdd ?? false)
      return const Icon(Icons.star, key: ValueKey(1), color: Colors.pinkAccent,);
    else return const SizedBox.shrink();
  }

  _onDoubleTap()
  => Navigator.pushNamed(context, "/details", arguments: widget.amiibo);

  _onTap(){
    AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    switch(widget.amiibo?.owned ?? 0){
      case 1:
        amiiboProvider.countOwned = widget.amiibo.owned = 0;
        amiiboProvider.countWished = widget.amiibo.wishlist = 1;
        break;
      case 0:
        if((widget.amiibo?.wishlist ?? 0) == 0)
          amiiboProvider.countOwned = widget.amiibo.owned = 1;
        else amiiboProvider.countWished = widget.amiibo.wishlist = 0;
        break;
    }
    amiiboProvider.updateAmiiboDB(amiibo: widget.amiibo);
    amiiboProvider.updateList();
    setState(() {_widget = _changeWidget();});
  }

  _onLongPress(){
    AmiiboProvider mSelected = Provider.of<AmiiboProvider>(context, listen: false);
    if(!mSelected.addSelected(widget.key)) mSelected.removeSelected(widget.key);
    mSelected.notifyWidgets();
  }

  @override
  Widget build(BuildContext context){
    bool _multipleSelected = Provider.of<AmiiboProvider>(context, listen: false).multipleSelected;
    return Selector<AmiiboProvider,bool>(
      builder: (context, _isSelected, child){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linearToEaseOut,
          margin: _isSelected ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : EdgeInsets.zero,
          padding: _isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
          decoration: BoxDecoration(
              color: _isSelected ? Theme.of(context).selectedRowColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8)
          ),
          child: child
        );
      },
      selector: (context, selected) => selected.isSelected(widget.key),
      child: GestureDetector(
        onDoubleTap: _multipleSelected ? null : _onDoubleTap,
        onTap: _multipleSelected ? _onLongPress : _onTap,
        onLongPress: _onLongPress,
        child: Stack(
          children: <Widget>[
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Expanded(
                    child: Hero(
                        transitionOnUserGestures: true,
                        tag: widget.amiibo.key,
                        child: Image.asset('assets/collection/icon_${widget.amiibo.key}.png',
                          fit: BoxFit.scaleDown,
                        )
                    ),
                    flex: 9,
                  ),
                  Expanded(
                    child: Container(
                      decoration: ShapeDecoration(
                          color: Theme.of(context).primaryColorLight,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)))),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('${widget.amiibo.name}',
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    flex: 2,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeInToLinear,
                  switchOutCurve: Curves.easeOutCirc,
                  transitionBuilder: (Widget child, Animation <double> animation)
                  => ScaleTransition(scale: animation, child: child,),
                  child: _widget
              ),
            ),
          ],
        ),
      )
    );
  }
}