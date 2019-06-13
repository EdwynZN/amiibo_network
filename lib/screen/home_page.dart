import 'package:flutter/material.dart';
import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:amiibo_network/data/cacheDB.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  static List<String> list = <String>['All', 'New', 'Owned', 'Wishlist'];
  static String _filter = 'All';
  static const double initialFAB = 0.35;
  ScrollController _controller;
  AnimationController _animationController;
  static final lightTheme = SystemUiOverlayStyle.light
    .copyWith(systemNavigationBarColor: Colors.red);
  static final darkTheme = SystemUiOverlayStyle.light
    .copyWith(systemNavigationBarColor: Colors.blueGrey[800]);

  initBloc() async{
    await _bloc.fetchAllAmiibosDB();
    list.addAll(await _bloc.listOfGames());
  }

  @override
  void initState(){
    initBloc();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      animationBehavior: AnimationBehavior.preserve,
      vsync: this)..value = initialFAB;
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
      _animationController.animateBack(initialFAB);
      _filter = value;
      _bloc.resetPagination(_filter, false);
      _controller.position.jumpTo(0);
    }
  }

  bool _onGestureAmiibo(AmiiboDB amiibo){
    _bloc.updateAmiiboDB(amiibo: amiibo);
    bool remove = false;
    switch(_filter) {
      case 'New':
        remove = amiibo.brandNew != null;
        break;
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
      if(value != null) {
        _filter = value;
        _bloc.resetPagination(_filter, true);
        _controller.position.jumpTo(0);
        _animationController.value = initialFAB;
      }
    });
  }

  Future<bool> _exitApp() async{
    await ConnectionFactory().close();
    _controller?.removeListener(_scrollListener);
    _controller?.dispose();
    _animationController?.dispose();
    $Provider.dispose<AmiiboBloc>();
    return await Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
    MediaQuery.platformBrightnessOf(context) == Brightness.light ? lightTheme : darkTheme);
    return WillPopScope(
      onWillPop: _exitApp,
      child: Scaffold(
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
                      style: TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis, maxLines: 1);
                  }),
                onTap: _search
              ),
              trailing: CircleAvatar(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/settings"),
                  child: Tooltip(message: 'Settings', child: Icon(Icons.settings)),
                )
              ),
            ),
            SliverPadding(padding: EdgeInsets.symmetric(horizontal: 5),
              sliver: StreamBuilder(
                stream: _bloc.allAmiibosDB,
                builder: (context, AsyncSnapshot<AmiiboLocalDB> snapshot) {
                  if((snapshot.data?.amiibo?.length ?? 1) == 0)
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        Container(alignment: Alignment.center, height: 250,
                          child: Text('Nothing to see here',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          )
                        )
                      ])
                    );
                  else return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
                            Navigator.pushNamed(context, "/details", arguments: snapshot.data.amiibo[index])
                              .then((_) {
                              bool remove = _onGestureAmiibo(snapshot.data.amiibo[index]);
                              if(remove) snapshot.data.amiibo.removeAt(index);
                            });
                          },
                          child: AmiiboGrid(amiibo: snapshot.data.amiibo[index]),
                        );
                      },
                      addRepaintBoundaries: false, addAutomaticKeepAlives: false,
                      childCount: snapshot.hasData ? snapshot.data.amiibo.length : 0,
                    )
                  );
                }
              )
            ),
          ],
        ),
        floatingActionButton: FAB(_animationController, initialFAB,
          () => _controller.jumpTo(0),
          () => _bloc.cleanBrandNew(_filter)
        )
      )
    );
  }
}

class FAB extends StatelessWidget{
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  final Animation<double> scale;
  final Animation<double> fabAnimation;
  final Animation<double> rotation;
  final AnimationController controller;
  final VoidCallback goTop;
  final VoidCallback clean;
  final double initialValue;

  FAB(this.controller, this.initialValue, this.goTop, this.clean):

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
                onPressed: controller.isAnimating ? null : goTop,
                label: Icon(Icons.keyboard_arrow_up),
                icon: Text('Go to top'),
              )
          ),
        ),
        StreamBuilder(
            initialData: false,
            stream: _bloc.findNew,
            builder: (context, AsyncSnapshot<bool> snapshotNew){
              if(snapshotNew.data)
                return Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ScaleTransition(
                    scale: fabAnimation,
                    child: FloatingActionButton.extended(
                      heroTag: 'CleanNewFAB',
                      onPressed: controller.isAnimating ? null : clean,
                      label: const Icon(Icons.new_releases, color: Colors.yellowAccent),
                      icon: Text('Clean new'),
                    ),
                  ),
                );
              else return const SizedBox();
            }
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
        for(var series in list) PopupMenuItem(
          value: series,
          child:  Row(
            children: <Widget>[
              if(series == 'All') const Icon(Icons.all_inclusive)
              else if(series == 'New') const Icon(Icons.new_releases, color: Colors.yellowAccent,)
              else if(series == 'Owned') const Icon(Icons.star, color: Colors.pinkAccent,)
              else if(series == 'Wishlist') const Icon(Icons.cake, color: Colors.yellowAccent,)
              else CircleAvatar(child: Text(series[0]), radius: 14,),
              Container(child: Text(series), margin: EdgeInsets.only(left: 8),)
            ],
          ),
        ),
      ],
      icon: Icon(Icons.filter_list, color: Colors.black),
      offset: Offset(-16, 50),
      tooltip: 'Categories',
      onSelected: onTap
    );
  }
}

class AmiiboGrid extends StatelessWidget{
  final AmiiboDB amiibo;

  AmiiboGrid({
    Key key,
    this.amiibo
  });

  @override
  Widget build(BuildContext context){
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(4),
                  child: Hero(
                    tag: amiibo.id,
                    child: CachedNetworkImage(
                      cacheManager: CacheManager(),
                      imageUrl: 'https://raw.githubusercontent.com/N3evin/AmiiboAPI/master/images/icon_'
                          '${amiibo.toMap()['id']?.toString()?.substring(0,8)}-'
                          '${amiibo.toMap()['id']?.toString()?.substring(8)}.png',
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.redAccent),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
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
                  child: Text('${amiibo.name}',
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
        if(amiibo.brandNew?.isEven ?? true) const Align(
          alignment: Alignment.topRight,
          child: const Icon(Icons.new_releases, color: Colors.yellowAccent),
        ),
        if(amiibo.owned?.isOdd ?? false) const Align(
          alignment: Alignment.topLeft,
          child: const Icon(Icons.star, color: Colors.pinkAccent),
        ),
        if(amiibo.wishlist?.isOdd ?? false) const Align(
          alignment: Alignment.topLeft,
          child: const Icon(Icons.cake, color: Colors.yellowAccent),
        ),
      ],
    );
  }
}