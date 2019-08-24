import 'package:flutter/material.dart';
import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/theme_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/widget/radial_progression.dart';
import 'package:amiibo_network/widget/drawer.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  static final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  static String _filter = _bloc.strFilter;
  static bool _multipleSelection = false;
  final Set<ValueKey<int>> set = Set<ValueKey<int>>();
  ScrollController _controller;
  AnimationController _animationController;

  void checkMultipleSelection(){
    final bool val = _multipleSelection;
    _multipleSelection = set.isNotEmpty;
    if(_multipleSelection != val) setState(() {});
    _bloc.setFilter = _multipleSelection ?
    '${set.length}' : '$_filter | Search Amiibo';
  }

  void _updateSelection({int wished = 0, int owned = 0}) async {
    AmiiboLocalDB amiibos = AmiiboLocalDB(amiibo: List<AmiiboDB>.of(
        set.map((x) => AmiiboDB(key: x.value, wishlist: wished, owned: owned))
      )
    );
    set.clear();
    await _bloc.updateAmiiboDB(amiibos: amiibos);
    await _bloc.refreshPagination();
    setState(() => _multipleSelection = false);
  }

  void  _cancelSelection() {
    set.clear();
    _bloc.setFilter = '$_filter | Search Amiibo';
    setState(() => _multipleSelection = false);
  }

  void initBloc() async{
    await _bloc.fetchAllAmiibosDB();
    _bloc.setFilter = '$_filter | Search Amiibo';
  }

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
  void dispose() {
    ConnectionFactory().close();
    _controller?.removeListener(_scrollListener);
    _controller?.dispose();
    _animationController?.dispose();
    $Provider.dispose<AmiiboBloc>();
    super.dispose();
  }

  void _scrollListener() {
    if((_controller?.hasClients ?? false) && !_animationController.isAnimating){
      switch(_controller.position.userScrollDirection){
        case ScrollDirection.forward:
            _animationController.forward();
          break;
        case ScrollDirection.reverse:
          _animationController.reverse();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
  }

  void _onTapTile(String tile){
    if(_filter != tile){
      _filter = tile;
      _bloc.resetPagination(_filter, false);
      _animationController.forward();
      _controller.position.jumpTo(0);
    }
    setState(() {});
  }

  void _search(){
    Navigator.pushNamed(context,"/search").then((value) {
      if(value != null && value != '') {
        _filter = value;
        _bloc.resetPagination(_filter, true);
        _controller.position.jumpTo(0);
        _animationController.forward();
      }
    });
  }

  Future<bool> _exitApp() async{
    if(_multipleSelection){
      _cancelSelection();
      return false;
    } else {
      await ConnectionFactory().close();
      _controller?.removeListener(_scrollListener);
      _controller?.dispose();
      _animationController?.dispose();
      _bloc.dispose();
      $Provider.dispose<ThemeBloc>();
      return await Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _exitApp,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: !_multipleSelection ? CollectionDrawer(
            key: Key('Drawer'),
            selected: _filter, onTap: _onTapTile,
          ) : null,
          body: Scrollbar(
            child: CustomScrollView(
              controller: _controller,
              slivers: <Widget>[
                SliverFloatingBar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  floating: !_multipleSelection,
                  snap: !_multipleSelection,
                  pinned: _multipleSelection,
                  leading: _multipleSelection ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _cancelSelection,
                    tooltip: 'Cancel') : null,
                  title: GestureDetector(
                    child: StreamBuilder(
                      stream: _bloc.filter,
                      builder: (BuildContext context, AsyncSnapshot<String> filter){
                        if(filter.hasData)
                          return Text(filter.data,
                              style: Theme.of(context).textTheme.body2, softWrap: false,
                              overflow: TextOverflow.fade, maxLines: 1);
                        else return const SizedBox();
                      }
                    ),
                    onTap: _multipleSelection ? null : _search
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if(_multipleSelection) IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _updateSelection,
                        tooltip: 'Remove',
                      ),
                      if(_multipleSelection) IconButton(
                        icon: Icon(Icons.star),
                        onPressed: () => _updateSelection(owned: 1),
                        tooltip: 'Owned',
                      ),
                      if(_multipleSelection) IconButton(
                        icon: Icon(Icons.card_giftcard),
                        onPressed: () => _updateSelection(wished: 1),
                        tooltip: 'Wished',
                      ),
                      if(!_multipleSelection) _SortCollection(),
                    ],
                  )
                ),
                /*SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(_filter)
                ),*/
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  sliver: SliverToBoxAdapter(
                    child: StreamBuilder(
                      initialData: null,
                      stream: _bloc.collectionList,
                      builder: (context, AsyncSnapshot<Map<String,dynamic>> statList){
                        if(statList.hasData)
                          return Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  if(_filter != 'Wishlist')
                                    Flexible(
                                      child: Chip(
                                          avatar: AnimatedRadial(
                                            key: Key('Owned'),
                                            percentage:
                                            statList.data['Owned'].toDouble() / statList.data['Total'].toDouble(),
                                            child: const Icon(Icons.check, color: Colors.green),
                                          ),
                                          label: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text('${statList.data['Owned']}/'
                                                '${statList.data['Total']} Owned', softWrap: false,
                                              overflow: TextOverflow.fade,
                                            ),
                                          )
                                      ),
                                    ),
                                  if(_filter != 'Owned')
                                    Flexible(
                                      child: Chip(
                                          avatar: AnimatedRadial(
                                            key: Key('Owned'),
                                            percentage:
                                            statList.data['Wished'].toDouble() / statList.data['Total'].toDouble(),
                                            child: const Icon(Icons.whatshot, color: Colors.amber),
                                          ),
                                          label: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text('${statList.data['Wished']}/'
                                                '${statList.data['Total']} Wished', softWrap: false,
                                              overflow: TextOverflow.fade,
                                            ),
                                          )
                                      ),
                                    )
                                ],
                              ),
                              /*Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: DropMenu(),
                                  ),
                                  const Icon(Icons.keyboard_arrow_up, size: 28,)
                                ],
                              )*/
                            ],
                          );
                        else return const SizedBox();
                      }
                    )
                  ),
                ),
                SliverPadding(padding: EdgeInsets.symmetric(horizontal: 5),
                  sliver: StreamBuilder(
                    stream: _bloc.allAmiibosDB,
                    builder: (context, AsyncSnapshot<AmiiboLocalDB> snapshot) {
                      if((snapshot.data?.amiibo?.length ?? 1) == 0) return DefaultTextStyle(
                        style: Theme.of(context).textTheme.display1,
                        child: const SliverToBoxAdapter(
                          child: const Align(alignment: Alignment.center, heightFactor: 10,
                             child: Text('Nothing to see here',
                              textAlign: TextAlign.center,
                            )
                          )
                        )
                      );
                      else return
                        SliverGrid(
                        gridDelegate: MediaQuery.of(context).size.width >= 600 ?
                          SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            mainAxisSpacing: 8.0,
                          ) :
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8.0
                          ),
                        //MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 3),
                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                          AmiiboGrid(amiibo: snapshot.data.amiibo[index], key: ValueKey<int>(snapshot.data.amiibo[index].key),
                            set: set, functionSelection: checkMultipleSelection, multipleSelection: _multipleSelection,
                          ),
                          addRepaintBoundaries: false, addAutomaticKeepAlives: false,
                          childCount: snapshot.hasData ? snapshot.data.amiibo.length : 0,
                        )
                      );
                    }
                  )
                ),
              ],
            ),
          ),
          floatingActionButton: FAB(_animationController, () => _controller.jumpTo(0)
          ),
        )
      )
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final _filter;
  static final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();

  _SliverAppBarDelegate(this._filter);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent,) {
    return StreamBuilder(
        initialData: null,
        stream: _bloc.collectionList,
        builder: (context, AsyncSnapshot<Map<String,dynamic>> statList){
          if(statList.hasData)
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).backgroundColor
              ),
              height: 66,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if(_filter != 'Wishlist')
                  Flexible(
                    child: Chip(
                      avatar: AnimatedRadial(
                        key: Key('Owned'),
                        percentage:
                        statList.data['Owned'].toDouble() / statList.data['Total'].toDouble(),
                        child: const Icon(Icons.check, color: Colors.green),
                      ),
                      label: FittedBox(
                        fit: BoxFit.contain,
                        child: Text('${statList.data['Owned']}/'
                          '${statList.data['Total']} Owned', softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      )
                    ),
                  ),
                if(_filter != 'Owned')
                  Flexible(
                    child: Chip(
                      avatar: AnimatedRadial(
                        key: Key('Owned'),
                        percentage:
                        statList.data['Wished'].toDouble() / statList.data['Total'].toDouble(),
                        child: const Icon(Icons.whatshot, color: Colors.amber),
                      ),
                      label: FittedBox(
                        fit: BoxFit.contain,
                        child: Text('${statList.data['Wished']}/'
                            '${statList.data['Total']} Wished', softWrap: false,
                          overflow: TextOverflow.fade,
                        ),
                      )
                    ),
                  )
              ],
            ),
            );
          else return const SizedBox(height: 66,);
        }
    );
  }

  @override
  double get maxExtent => 66.0;

  @override
  double get minExtent => 66.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

class _SortCollection extends StatefulWidget{
  @override
  _SortCollectionState createState() => _SortCollectionState();
}

class _SortCollectionState extends State<_SortCollection> {
  static final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  String _sortBy = _bloc.orderBy;

  void _selectOrder(String sort) async{
    _bloc.strOrderBy = _sortBy = sort;
    await _bloc.refreshPagination();
    Navigator.pop(context);
  }

  Future<void> _dialog(BuildContext context) async {
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              value: 'owned',
              groupValue: _sortBy,
              onChanged: _selectOrder,
              dense: true,
              selected: _sortBy == 'owned',
              title: Text('Owned'),
            ),
            RadioListTile(
              value: 'wishlist',
              groupValue: _sortBy,
              onChanged: _selectOrder,
              dense: true,
              title: Text('Wished'),
              selected: _sortBy == 'wishlist',
            ),
            RadioListTile(
              value: 'na',
              groupValue: _sortBy,
              onChanged: _selectOrder,
              dense: true,
              title: Text('American Date'),
              selected: _sortBy == 'na',
              secondary: Image.asset(
                'assets/images/na.png',
                height: 16, width: 25,
                fit: BoxFit.fill,
                semanticLabel: 'American Date',
              ),
            ),
            RadioListTile(
              value: 'eu',
              groupValue: _sortBy,
              onChanged: _selectOrder,
              dense: true,
              title: Text('European Date'),
              selected: _sortBy == 'eu',
              secondary: Image.asset(
                'assets/images/eu.png',
                height: 16, width: 25,
                fit: BoxFit.fill,
                semanticLabel: 'European date',
              ),
            ),
            RadioListTile(
              value: 'jp',
              groupValue: _sortBy,
              onChanged: _selectOrder,
              dense: true,
              title: Text('Japanese Date'),
              selected: _sortBy == 'jp',
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
              value: 'au',
              groupValue: _sortBy,
              onChanged: _selectOrder,
              dense: true,
              title: Text('Australian Date'),
              selected: _sortBy == 'au',
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

  Future<void> _bottomModal(BuildContext context) async{
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (BuildContext context) {
        return Container(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('Sort By', style: Theme.of(context).textTheme.body2,),
              ),
              const Divider(),
              RadioListTile(
                value: 'name',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('Name'),
                selected: _sortBy == 'name',
              ),
              RadioListTile(
                value: 'owned',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                selected: _sortBy == 'owned',
                title: Text('Owned'),
              ),
              RadioListTile(
                value: 'wishlist',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('Wished'),
                selected: _sortBy == 'wishlist',
              ),
              RadioListTile(
                value: 'na',
                groupValue: _sortBy,
                onChanged: _selectOrder,
                dense: true,
                title: Text('American Date'),
                selected: _sortBy == 'na',
                secondary: Image.asset(
                  'assets/images/na.png',
                  height: 16, width: 25,
                  fit: BoxFit.fill,
                  semanticLabel: 'American Date',
                ),
              ),
            ],
          ),
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
  final Set<ValueKey<int>> set;
  final VoidCallback functionSelection;
  final bool multipleSelection;
  static final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();

  const AmiiboGrid({
    Key key,
    this.amiibo,
    this.set,
    this.multipleSelection,
    this.functionSelection,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AmiiboGridState();
}

class AmiiboGridState extends State<AmiiboGrid> {
  bool _isSelected;
  Widget _widget;

  @override
  void initState(){
    _isSelected = widget.set.contains(widget.key);
    _widget = _changeWidget();
    super.initState();
  }

  @override
  void didUpdateWidget(AmiiboGrid oldWidget) {
    _isSelected = widget.set.contains(widget.key);
    _widget = _changeWidget();
    super.didUpdateWidget(oldWidget);
  }

  Widget _changeWidget(){
    if(widget.amiibo?.wishlist?.isOdd ?? false)
      return const Icon(Icons.card_giftcard, key: ValueKey(2),  color: Colors.limeAccent);
    else if(widget.amiibo?.owned?.isOdd ?? false)
      return const Icon(Icons.star, key: ValueKey(1), color: Colors.pinkAccent);
    else return const SizedBox.shrink();
  }

  _onDoubleTap()
    => Navigator.pushNamed(context, "/details", arguments: widget.amiibo);

  _onTap() {
    switch(widget.amiibo?.owned ?? 0){
      case 1:
        AmiiboGrid._bloc.countOwned = widget.amiibo.owned = 0;
        AmiiboGrid._bloc.countWished = widget.amiibo.wishlist = 1;
        break;
      case 0:
        if((widget.amiibo?.wishlist ?? 0) == 0)
          AmiiboGrid._bloc.countOwned = widget.amiibo.owned = 1;
        else AmiiboGrid._bloc.countWished = widget.amiibo.wishlist = 0;
        break;
    }
    AmiiboGrid._bloc.updateAmiiboDB(amiibo: widget.amiibo);
    AmiiboGrid._bloc.updateList();
    setState(() {_widget = _changeWidget();});
  }

  _onLongPress() {
    setState(() {
      _isSelected = widget.set.add(widget.key) ? true : !widget.set.remove(widget.key);
    });
    widget.functionSelection();
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.linearToEaseOut,
    margin: _isSelected ? EdgeInsets.symmetric(horizontal: 8, vertical: 4) : EdgeInsets.all(0),
    padding: _isSelected ? EdgeInsets.all(8) : EdgeInsets.all(0),
    decoration: BoxDecoration(
      color: _isSelected ? Theme.of(context).selectedRowColor : Colors.transparent,
      borderRadius: BorderRadius.circular(8)
    ),
    child: GestureDetector(
      onDoubleTap: widget.multipleSelection ? null : _onDoubleTap,
      onTap: widget.multipleSelection ? _onLongPress : _onTap,
      onLongPress: _onLongPress,
      /*(LongPressMoveUpdateDetails details) {
        //print('Local: ${details.localPosition}');
        //print('Global: ${details.globalPosition}');
        //print('Local Offset: ${details.localOffsetFromOrigin}');
        //print(widget.scrollController.offset);
        //print(widget.scrollController.position.maxScrollExtent);
        //print(widget.scrollController.position.isScrollingNotifier.value);
        //print('Local: ${details.localPosition}');
        //print(widget.scrollController.offset);
        /*if(details.globalPosition.dy >= 0.85 * MediaQuery.of(context).size.height &&
            widget.scrollController.offset < widget.scrollController.position.maxScrollExtent &&
            !widget.scrollController.position.isScrollingNotifier.value){
          widget.scrollController.animateTo(
            widget.scrollController.offset + 250,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear);
        }*/
      },*/
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
                    tag: widget.amiibo.key,
                    child: Image.asset('assets/collection/icon_${widget.amiibo.key}.png',
                      fit: BoxFit.scaleDown,
                    )
                    /*Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/collection/icon_${widget.amiibo.id?.substring(0,8)}-'
                              '${widget.amiibo.id?.substring(8)}.png'),
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                        ),
                      ),
                    ))*/
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
    ),
  );
}