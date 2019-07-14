import 'package:flutter/material.dart';
import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/theme_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  static List<String> list = <String>['All', 'Owned', 'Wishlist', 'Cards'];
  static String _filter = 'All';
  ScrollController _controller;
  AnimationController _animationController;

  initBloc() async{
    await _bloc.fetchAllAmiibosDB();
    list.addAll(await _bloc.listOfGames());
  }

  @override
  void initState(){
    initBloc();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      animationBehavior: AnimationBehavior.preserve,
      vsync: this)..value = 1.0;
    super.initState();
  }

  @override
  dispose() {
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

  _onTapPopMenu(String value){
    if(_filter != value){
      _animationController.forward();
      _filter = value;
      _bloc.resetPagination(_filter, false);
      _controller.position.jumpTo(0);
    }
  }

  bool _onGestureAmiibo(AmiiboDB amiibo){
    _bloc.updateAmiiboDB(amiibo: amiibo);
    bool remove = false;
    switch(_filter) {
      case 'Owned':
        remove = amiibo.owned != 1;
        break;
      case 'Wishlist':
        remove = amiibo.wishlist != 1;
        break;
    }
    return remove;
  }

  _search(){
    Navigator.pushNamed(context,"/search").then((value) {
      if(value != null && value != '') {
        _filter = value;
        _bloc.resetPagination(_filter, true);
        _controller.position.jumpTo(0);
        _animationController.value = 1.0;
      }
    });
  }

  Future<bool> _exitApp() async{
    await ConnectionFactory().close();
    _controller?.removeListener(_scrollListener);
    _controller?.dispose();
    _animationController?.dispose();
    _bloc.dispose();
    $Provider.dispose<ThemeBloc>();
    return await Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _exitApp,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: CustomScrollView(
            controller: _controller, cacheExtent: 150,
            slivers: <Widget>[
              SliverFloatingBar(
                backgroundColor: Theme.of(context).backgroundColor,
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                leading: PopUpMenu(list, _onTapPopMenu),
                title: GestureDetector(
                  child: StreamBuilder(
                    initialData: 'All',
                    stream: _bloc.filter,
                    builder: (BuildContext context, AsyncSnapshot<String> filter){
                      return Text('${filter.data} | Search Amiibo',
                      style: Theme.of(context).textTheme.body2,
                      overflow: TextOverflow.ellipsis, maxLines: 1);
                    }),
                  onTap: _search
                ),
                trailing: CircleAvatar(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/settings"),
                    child: Tooltip(message: 'Settings',
                      child: Icon(Icons.settings,
                        color: Theme.of(context).accentIconTheme.color,
                      )
                    ),
                  )
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: StreamBuilder(
                    initialData: null,
                    stream: _bloc.wished,
                    builder: (context, AsyncSnapshot<List<String>> strList){
                      if(strList.hasData)
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if(_filter != 'Wishlist')
                              SizedBox(child: Text(strList.data[0], style: Theme.of(context).textTheme.display1)),
                            if(_filter != 'Owned')
                              SizedBox(child: Text(strList.data[1], style: Theme.of(context).textTheme.display1)),
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
                    if((snapshot.data?.amiibo?.length ?? 1) == 0)
                      return const SliverToBoxAdapter(
                        child: const Align(alignment: Alignment.center, heightFactor: 10,
                          child: Text('Nothing to see here',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          )
                        )
                      );
                    else return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6),
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) =>
                        AmiiboGrid(amiibo: snapshot.data.amiibo[index],
                          onDoubleTap: () {
                            Navigator.pushNamed(context, "/details", arguments: snapshot.data.amiibo[index])
                                .then((_) {
                              bool remove = _onGestureAmiibo(snapshot.data.amiibo[index]);
                              if(remove) {
                                snapshot.data.amiibo.removeAt(index);
                                _bloc.removeFromList = 2;
                              }
                              _bloc.updateList();
                            });
                          },
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
          floatingActionButton: FAB(_animationController,
            () => _controller.jumpTo(0),
          )
        )
      )
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
        onPressed: controller.isAnimating ? null : goTop,
        child: const Icon(Icons.keyboard_arrow_up),
      )
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
        for(String series in list) PopupMenuItem(
          value: series,
          child: Row(
            children: <Widget>[
              if(series == 'All') const Icon(Icons.all_inclusive)
              else if(series == 'Owned') const Icon(Icons.star, color: Colors.pinkAccent,)
              else if(series == 'Wishlist') const Icon(Icons.card_giftcard, color: Colors.amber,)
              else if(series == 'Cards') const Icon(Icons.view_carousel, color: Colors.amber)
              else CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                foregroundColor: Theme.of(context).accentIconTheme.color,
                child: Text(series[0]), radius: 14,),
              Padding(child: Text(series), padding: EdgeInsets.only(left: 8),)
            ],
          ),
        ),
      ],
      icon: Icon(Icons.sort, size: 30,),
      tooltip: 'Categories',
      onSelected: onTap
    );
  }
}

class AmiiboGrid extends StatefulWidget {
  final AmiiboDB amiibo;
  final GestureTapCallback onDoubleTap;

  const AmiiboGrid({Key key, this.amiibo, this.onDoubleTap});
  @override
  State<StatefulWidget> createState() => AmiiboGridState();
}

class AmiiboGridState extends State<AmiiboGrid> {
  static final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTap: widget.onDoubleTap,
    onTap: () {
      switch(widget.amiibo?.owned ?? 0){
        case 1:
          _bloc.countOwned = widget.amiibo.owned = 0;
          _bloc.countWished = widget.amiibo.wishlist = 1;
          break;
        case 0:
          if((widget.amiibo?.wishlist ?? 0) == 0) {
            _bloc.countOwned = widget.amiibo.owned = 1;
          } else{
            _bloc.countWished = widget.amiibo.wishlist = 0;
          }
          break;
      }
      _bloc.updateAmiiboDB(amiibo: widget.amiibo);
      _bloc.updateList();
      setState(() {});
    },
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
                    alignment: Alignment.center,
                  )
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
        if(widget.amiibo.owned?.isOdd ?? false) const Align(
          alignment: Alignment.topLeft,
          child: const Icon(Icons.star, color: Colors.pinkAccent),
        ),
        if(widget.amiibo.wishlist?.isOdd ?? false) const Align(
          alignment: Alignment.topLeft,
          child: const Icon(Icons.card_giftcard, color: Colors.yellowAccent),
        ),
      ],
    ),
  );
}