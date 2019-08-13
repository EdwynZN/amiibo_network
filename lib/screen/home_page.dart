import 'package:flutter/material.dart';
import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/theme_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/widget/radial_progression.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  static List<String> list = <String>['All', 'Owned', 'Wishlist', 'Cards'];
  static String _filter = 'All';
  static bool _multipleSelection = false;
  static const double initialFAB = 0.35;
  final Map<ValueKey<String>, int> map = Map();
  ScrollController _controller;
  AnimationController _animationController;

  checkMultipleSelection(){
    final bool val = _multipleSelection;
    _multipleSelection = map.isNotEmpty;
    if(_multipleSelection != val) setState(() {});
    _bloc.setFilter = _multipleSelection ?
    '${map.length.toString()}' : '$_filter | Search Amiibo';
  }

  _updateSelection({int wished = 0, int owned = 0}) async {
    AmiiboLocalDB amiibos = AmiiboLocalDB(amiibo: List<AmiiboDB>.of(
      map.keys.map((x) => AmiiboDB(id: x.value,
        wishlist: wished, owned: owned))
      )
    );
    map.clear();
    await _bloc.updateAmiiboDB(amiibos: amiibos);
    await _bloc.refreshPagination();
    setState(() => _multipleSelection = false);
  }

  _cancelSelection() {
    map.clear();
    _bloc.setFilter = '$_filter | Search Amiibo';
    setState(() => _multipleSelection = false);
  }

  initBloc() async{
    list.addAll(await _bloc.listOfGames());
    await _bloc.fetchAllAmiibosDB();
    _bloc.setFilter = '$_filter | Search Amiibo';
  }

  @override
  void initState(){
    initBloc();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this)..value = initialFAB;
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

  _scrollListener() {
    if((_controller?.hasClients ?? false) && !_animationController.isAnimating){
      switch(_controller.position.userScrollDirection){
        case ScrollDirection.forward:
          if(!_animationController.isCompleted)
            _animationController.animateBack(initialFAB);
          break;
        case ScrollDirection.reverse:
          _animationController.animateBack(0.0);
          break;
        case ScrollDirection.idle:
          break;
      }
    }
  }

  _onTapPopMenu(String value){
    if(_filter != value){
      _animationController.value = initialFAB;
      _filter = value;
      _bloc.resetPagination(_filter, false);
      _controller.position.jumpTo(0);
    }
  }

  _search(){
    Navigator.pushNamed(context,"/search").then((value) {
      if(value != null && value != '') {
        _filter = value;
        _bloc.resetPagination(_filter, true);
        _controller.position.jumpTo(0);
        _animationController.value = initialFAB;
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
          body: Scrollbar(
            child: CustomScrollView(
              controller: _controller, cacheExtent: 150,
              slivers: <Widget>[
                SliverFloatingBar(
                  backgroundColor: Theme.of(context).backgroundColor,
                  floating: !_multipleSelection,
                  snap: !_multipleSelection,
                  pinned: _multipleSelection,
                  leading: _multipleSelection ? IconButton(
                    icon: Icon(Icons.clear, size: 30),
                    onPressed: _cancelSelection,
                    tooltip: 'Cancel',)
                      : PopUpMenu(list, _onTapPopMenu),
                  title: GestureDetector(
                    child: StreamBuilder(
                      stream: _bloc.filter,
                      builder: (BuildContext context, AsyncSnapshot<String> filter){
                        if(filter.hasData)
                          return Text(filter.data,
                            style: Theme.of(context).textTheme.body2, softWrap: false,
                            overflow: TextOverflow.fade, maxLines: 1);
                        else return const SizedBox.shrink();
                      }
                    ),
                    onTap: _multipleSelection ? null : _search
                  ),
                  trailing: _multipleSelection ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _updateSelection(),
                        tooltip: 'Remove',
                      ),
                      IconButton(
                        icon: Icon(Icons.star),
                        onPressed: () => _updateSelection(owned: 1),
                        tooltip: 'Owned',
                      ),
                      IconButton(
                        icon: Icon(Icons.card_giftcard),
                        onPressed: () => _updateSelection(wished: 1),
                        tooltip: 'Wished',
                      ),
                    ],
                  ) : CircleAvatar(
                      child: IconButton(
                        icon: Icon(Icons.settings, color: Theme.of(context).accentIconTheme.color),
                        onPressed: () => Navigator.pushNamed(context, "/settings"),
                        tooltip: 'Settings',
                      )
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  sliver: SliverToBoxAdapter(
                    child: StreamBuilder(
                      initialData: null,
                      stream: _bloc.wished,
                      builder: (context, AsyncSnapshot<Map<String,dynamic>> statList){
                        if(statList.hasData)
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              if(_filter != 'Wishlist')
                                Flexible(
                                  child: Chip(
                                    avatar: AnimatedProgression(
                                      key: Key('Owned'),
                                      fraction: statList.data['Owned'].toDouble(),
                                      total: statList.data['Total'].toDouble(),
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
                                    avatar: AnimatedProgression(
                                      key: Key('Owned'),
                                      fraction: statList.data['Wished'].toDouble(),
                                      total: statList.data['Total'].toDouble(),
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
                          );
                        else return const SizedBox.shrink();
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
                          AmiiboGrid(amiibo: snapshot.data.amiibo[index], key: Key(snapshot.data.amiibo[index].id),
                            map: map, functionSelection: checkMultipleSelection, multipleSelection: _multipleSelection,
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
          floatingActionButton: FAB(_animationController, initialFAB,
            () => _controller.jumpTo(0)
          ),
        )
      )
    );
  }
}

class AnimatedProgression extends StatefulWidget {
  final double fraction;
  final double total;
  final Widget child;

  const AnimatedProgression({
    Key key, this.fraction, this.total, this.child
  }) : super(key: key);

  @override
  _AnimatedProgressionState createState() => _AnimatedProgressionState();
}

class _AnimatedProgressionState extends State<AnimatedProgression>
    with SingleTickerProviderStateMixin {
  double percentage;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this)
    ..value = percentage = widget.fraction / widget.total;
  }

  @override
  void didUpdateWidget(AnimatedProgression oldWidget) {
    percentage = widget.fraction / widget.total;
    _controller.animateTo(percentage);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: percentage == 1 ? widget.child : const SizedBox(width: 24, height: 24),
      ),
      builder: (_, Widget child){
        return CustomPaint(
          painter: RadialProgression(_controller.value),
          child: child,
          isComplex: true,
          willChange: true,
        );
      },
    );
  }
}

class FAB extends StatelessWidget{
  final Animation<double> scale;
  final Animation<double> fabAnimation;
  final Animation<double> rotation;
  final AnimationController controller;
  final VoidCallback goTop;
  final double initialValue;

  FAB(this.controller, this.initialValue, this.goTop):
    scale = Tween<double>(begin: 0.0, end: 1.0)
      .animate(
      CurvedAnimation(parent: controller,
          curve: Interval(0.0, initialValue, curve: Curves.linear)
      )
    ),
    fabAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(
      CurvedAnimation(parent: controller,
          curve: Interval(0.5, 1.0, curve: Curves.easeInOutExpo)
      )
    ),
    rotation = Tween<double>(begin: 0.0, end: 0.625)
      .animate(
      CurvedAnimation(parent: controller,
          curve: Interval(initialValue, 1, curve: Curves.easeOutBack)
      )
    );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: ScaleTransition(
              scale: fabAnimation,
              child: FloatingActionButton.extended(
                heroTag: 'GoTopFAB',
                onPressed: () => controller.isAnimating ? null : goTop(),
                label: Icon(Icons.keyboard_arrow_up),
                icon: Text('Go to top'),
              )
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: ScaleTransition(
              scale: fabAnimation,
              child: FloatingActionButton.extended(
                heroTag: 'GoStats',
                onPressed: () => controller.isAnimating ? null : Navigator.pushNamed(context,"/stats"),
                label: Icon(Icons.show_chart),
                icon: Text('Your Stats'),
              )
          ),
        ),
        ScaleTransition(
          scale: scale,
          child: RotationTransition(
            turns: rotation,
            child: FloatingActionButton(
                heroTag: 'MenuFAB',
                onPressed: () => controller.isCompleted ? controller.animateBack(0.35) : controller.forward(),
                child: Icon(Icons.add)
            ),
          )
        ),
      ],
    );
  }
}

class PopUpMenu extends StatelessWidget{
  final List<String> list;
  final PopupMenuItemSelected<String> onTap;

  PopUpMenu(this.list, this.onTap);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        PopupMenuDivider(),
        for(String series in list) PopupMenuItem(
          value: series,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if(series == 'All') const Icon(Icons.all_inclusive)
              else if(series == 'Owned') const Icon(Icons.star, color: Colors.pinkAccent,)
              else if(series == 'Wishlist') const Icon(Icons.card_giftcard, color: Colors.amber,)
              else if(series == 'Cards') const Icon(Icons.view_carousel, color: Colors.amber)
              else CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                foregroundColor: Theme.of(context).accentIconTheme.color,
                child: Text(series[0]), radius: 14,),
              Expanded(child: Padding(padding: EdgeInsets.only(left: 8),
                child: Text(series, overflow: TextOverflow.fade, softWrap: false),
                ),
              )
            ],
          ),
        ),
      ],
      icon: Icon(Icons.sort, size: 30),
      tooltip: 'Categories',
      onSelected: onTap,
      offset: Offset(-100, 0),
    );
  }
}

class AmiiboGrid extends StatefulWidget {
  final AmiiboDB amiibo;
  final Map<ValueKey<String>, int> map;
  final VoidCallback functionSelection;
  final bool multipleSelection;

  const AmiiboGrid({
    Key key,
    this.amiibo,
    this.map,
    this.multipleSelection,
    this.functionSelection,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AmiiboGridState();
}

class AmiiboGridState extends State<AmiiboGrid> {
  static final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  bool _isSelected;
  Widget _widget;

  @override
  void initState(){
    _isSelected = widget.map.containsKey(widget.key);
    _widget = _changeWidget();
    super.initState();
  }

  @override
  void didUpdateWidget(AmiiboGrid oldWidget) {
    _isSelected = widget.map.containsKey(widget.key);
    _widget = _changeWidget();
    super.didUpdateWidget(oldWidget);
  }

  Widget _changeWidget(){
    if(widget.amiibo?.wishlist?.isOdd ?? false)
      return const Icon(Icons.card_giftcard, key: ValueKey(2),  color: Colors.limeAccent);
    else if(widget.amiibo?.owned?.isOdd ?? false)
      return const Icon(Icons.star, key: ValueKey(1),  color: Colors.pinkAccent);
    else return const SizedBox.shrink();
  }

  _onDoubleTap()
    => Navigator.pushNamed(context, "/details", arguments: widget.amiibo);

  _onTap() {
    switch(widget.amiibo?.owned ?? 0){
      case 1:
        _bloc.countOwned = widget.amiibo.owned = 0;
        _bloc.countWished = widget.amiibo.wishlist = 1;
        break;
      case 0:
        if((widget.amiibo?.wishlist ?? 0) == 0)
          _bloc.countOwned = widget.amiibo.owned = 1;
        else _bloc.countWished = widget.amiibo.wishlist = 0;
        break;
    }
    _bloc.updateAmiiboDB(amiibo: widget.amiibo);
    _bloc.updateList();
    setState(() {_widget = _changeWidget();});
  }

  _onLongPress() {
    setState(() {
      _isSelected ^= true;
      if(_isSelected) widget.map.putIfAbsent(widget.key, () => 1);
      else widget.map.remove(widget.key);
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
      onLongPress: widget.multipleSelection ? null : _onLongPress,
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
                    tag: widget.amiibo.id,
                    child: Image.asset(
                      'assets/collection/icon_${widget.amiibo.id?.substring(0,8)}-'
                          '${widget.amiibo.id?.substring(8)}.png',
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
                      color: Theme.of(context).unselectedWidgetColor,
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