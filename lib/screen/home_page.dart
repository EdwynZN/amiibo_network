import 'package:amiibo_network/provider/lock_provider.dart';
import 'package:amiibo_network/provider/query_provider.dart';
import 'package:amiibo_network/provider/search_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:amiibo_network/provider/select_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:amiibo_network/data/database.dart';
import 'package:flutter/rendering.dart';
import 'package:amiibo_network/widget/drawer.dart';
import 'package:amiibo_network/widget/animated_widgets.dart';
import 'package:amiibo_network/widget/floating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'dart:math' as math;
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/widget/stat_widget.dart';
import '../utils/preferences_constants.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ProxyProvider<QueryProvider, AmiiboProvider>(
          create: (_) => AmiiboProvider(),
          update: (_, query, amiiboProvider) => amiiboProvider..update(query.where, query.orderCategory, query.sort),
          dispose: (_, amiiboProvider) => amiiboProvider.dispose(),
        ),
        StreamProvider<AmiiboLocalDB>(
          create: (context) => Provider.of<AmiiboProvider>(context, listen: false).amiiboList,
        ),
        StreamProvider<Map<String,dynamic>>(
          initialData: {'Owned' : 0, 'Wished' : 0, 'Total' : 0},
          create: (context) => Provider.of<AmiiboProvider>(context, listen: false).collectionList,
          updateShouldNotify: (prev, curr) =>
          prev['Owned'] != curr['Owned'] ||
              prev['Wished'] != curr['Wished'] ||
              prev['Total'] != curr['Total']
        ),
        ChangeNotifierProvider<SelectProvider>(
          create: (_) => SelectProvider(),
        )
      ],
      child: SafeArea(child: HomePage()),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin{
  ScrollController _controller;
  AnimationController _animationController;
  AmiiboProvider amiiboProvider;
  QueryProvider queryProvider;
  SearchProvider _searchProvider;
  SelectProvider selected;
  S translate;
  static Widget _defaultLayoutBuilder(Widget currentChild, List<Widget> previousChildren) {
    List<Widget> children = previousChildren;
    if (currentChild != null)
      children = children.toList()..add(currentChild);
    return Stack(
      children: children,
      alignment: Alignment.centerRight,
    );
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    queryProvider = context.read<QueryProvider>();
    amiiboProvider = context.read<AmiiboProvider>();
    selected = context.read<SelectProvider>();
    _searchProvider = context.read<SearchProvider>();
    translate = S.of(context);
  }

  void _restartAnimation(){
    _controller.jumpTo(0);
    _animationController.forward();
    _cancelSelection();
  }

  void _updateSelection({int wished = 0, int owned = 0}) async {
    AmiiboLocalDB amiibos = AmiiboLocalDB(amiibo: List<AmiiboDB>.of(
        selected.set.map((x) => AmiiboDB(key: x.value, wishlist: wished, owned: owned))
      )
    );
    selected.clearSelected();
    amiiboProvider..updateAmiiboDB(amiibos: amiibos)..refreshAmiibos;
  }

  void _cancelSelection() => selected.clearSelected();

  void initBloc() async =>
    await Provider.of<QueryProvider>(context, listen: false).fetchAllAmiibosDB();

  @override
  void initState(){
    super.initState();
    initBloc();
    _controller = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this)..value = 1.0;
  }

  @override
  void dispose(){
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
    String value = await Navigator.pushNamed(context,"/search");
    if(value != null) {
      if(value.trim().isNotEmpty){
        queryProvider.resetPagination(_searchProvider.category, value);
        _restartAnimation();
      }
    }
  }

  Future<bool> _exitApp() async{
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
    return WillPopScope(
      onWillPop: _exitApp,
      child: Selector<SelectProvider, bool>(
        selector: (_, select) => select.multipleSelected,
        child: SliverPersistentHeader(
          delegate: _SliverPersistentHeader(),
          pinned: true,
        ),
        builder: (_, _multipleSelection, child){
          return Scaffold(
            resizeToAvoidBottomInset: false,
            drawer: _multipleSelection ? null : CollectionDrawer(restart: _restartAnimation),
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
                        icon: Hero(
                          tag: 'MenuButton',
                          child: ImplicitIcon(key: Key('Menu'),forward: _multipleSelection)
                        ),
                        tooltip: _multipleSelection ? MaterialLocalizations.of(context).cancelButtonLabel
                          : MaterialLocalizations.of(context).openAppDrawerTooltip,
                        onPressed: _multipleSelection ? _cancelSelection : () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    title: Selector2<QueryProvider, SelectProvider, String>(
                      selector: (context, query, count) => count.multipleSelected ? count.selected.toString() : query.strFilter,
                      builder: (context, title, _) {
                        return Tooltip(
                          message: num.tryParse(title) == null ?
                              MaterialLocalizations.of(context).searchFieldLabel
                            : MaterialLocalizations.of(context).selectedRowCountTitle(num.parse(title)),
                          child: Text(translate.category(title) ?? ''),
                        );
                      },
                    ),
                    onTap: _multipleSelection ? null : _search,
                    trailing: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      layoutBuilder: _defaultLayoutBuilder,
                      child: _multipleSelection ? Row(
                        key: Key('MultipleSelected'),
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _updateSelection,
                            tooltip: translate.removeTooltip,
                          ),
                          IconButton(
                            icon: const Icon(iconOwned),
                            onPressed: () => _updateSelection(owned: 1),
                            tooltip: translate.ownTooltip,
                          ),
                          IconButton(
                            icon: const Icon(iconWished),
                            onPressed: () => _updateSelection(wished: 1),
                            tooltip: translate.wishTooltip,
                          ),
                        ],
                      ) :
                      Row(
                        key: Key('NoSelected'),
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Consumer<LockProvider>(
                            child: const Icon(Icons.lock_open),
                            builder: (context, ignore, child){
                              return IconButton(
                                icon: ignore.lock ? const Icon(Icons.lock) : child,
                                onPressed: () async => await ignore.update(!ignore.lock),
                                tooltip: S.of(context).lockTooltip(ignore.lock),
                              );
                            },
                          ),
                          _SortCollection()
                        ],
                      ),
                    )
                  ),
                  child,
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    sliver: Consumer2<AmiiboLocalDB, LockProvider>(
                      child: SliverFillRemaining(
                        hasScrollBody: false,
                        child: Align(alignment: Alignment.center, heightFactor: 10,
                          child: Text(translate.emptyPage,
                            textAlign: TextAlign.center,
                          )
                        )
                      ),
                      builder: (ctx, data, ignore, child){
                        if((data?.amiibo?.length ?? 1) == 0)
                          return DefaultTextStyle(
                            style: Theme.of(context).textTheme.headline4,
                            child: child,
                          );
                        final bool bigGrid = MediaQuery.of(context).size.width >= 600;
                        return SliverIgnorePointer(
                          ignoring: ignore.lock,
                          sliver: SliverGrid(
                            gridDelegate: bigGrid ?
                            SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 192,
                              mainAxisSpacing: 8.0,
                            ) :
                            SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8.0
                            ),
                            delegate: SliverChildBuilderDelegate((BuildContext _, int index) {
                              return ChangeNotifierProxyProvider<AmiiboLocalDB, SingleAmiibo>(
                                  create: (_) => SingleAmiibo(),
                                  update: (_, amiiboList, amiibo) => amiibo
                                    ..update = amiiboList?.amiibo[index],
                                  child: FadeSwitchAnimation(
                                    key: ValueKey<int>(index),
                                    child: AmiiboGrid(
                                      key: ValueKey<int>(data?.amiibo[index].key),
                                    ),
                                  )
                              );
                            },
                              //addRepaintBoundaries: false, addAutomaticKeepAlives: false,
                              childCount: data?.amiibo != null ? data?.amiibo?.length : 0,
                            )
                          ),
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
    );
  }
}

class _SliverPersistentHeader extends SliverPersistentHeaderDelegate {

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Color _color = Theme.of(context).appBarTheme.color;
    final S translate = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: [0.35, 0.65, 0.9],
          colors: [
            _color,
            _color.withOpacity(0.75),
            _color.withOpacity(0.0),
          ]
        ),
      ),
      height: math.max(minExtent, maxExtent - shrinkOffset),
      child: Consumer<Map<String,dynamic>>(
        child: const SizedBox(),
        builder: (context, statList, child){
          if(statList == null) return child;
          final double total = statList['Total'].toDouble();
          final double owned = statList['Owned'].toDouble();
          final double wished = statList['Wished'].toDouble();
          if(total == 0 && owned == 0 && wished == 0) return child;
          return Row(
            children: <Widget>[
              Expanded(
                child: StatWidget(
                  num: owned,
                  den: total,
                  text: translate.owned,
                  icon: Icon(iconOwnedDark, color: Colors.green[800])
                )
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: StatWidget(
                  num: wished,
                  den: total,
                  text: translate.wished,
                  icon: Icon(Icons.whatshot, color: Colors.amber[800]),
                )
              ),
            ],
          );
        },
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
  QueryProvider queryProvider;
  ButtonTextTheme _buttonTextTheme;
  Color _accentColor, _accentTextThemeColor;

  @override
  void didChangeDependencies() {
    queryProvider = context.read<QueryProvider>();
    final ThemeData theme = Theme.of(context);
    _accentColor = theme.accentColor;
    _accentTextThemeColor = theme.accentTextTheme.headline6.color;
    _buttonTextTheme = ThemeData.estimateBrightnessForColor(theme.primaryColor) == Brightness.light
        ? ButtonTextTheme.normal : ButtonTextTheme.accent;
    super.didChangeDependencies();
  }

  void _selectOrder(String order) async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(sharedOrder, order);
    queryProvider.orderCategory = order;
  }

  void _sortOrder(String sort) async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(sharedSort, sort);
    queryProvider.sort = sort;
  }

  Future<void> _bottomSheet() async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0.0,
      builder: (context) {
        final S translate = S.of(context);
        final Size size = MediaQuery.of(context).size;
        final double height = (460.0 / size.height).clamp(0.25, 0.66);
        EdgeInsetsGeometry padding = EdgeInsets.zero;
        if(size.longestSide >= 800) padding = EdgeInsets.symmetric(
          horizontal: (size.width/2 - 210).clamp(0.0, double.infinity)
        );
        return Padding(
          padding: padding,
          child: DraggableScrollableSheet(
            key: Key('Draggable'),
            maxChildSize: height, expand: false, initialChildSize: height,
            builder: (context, scrollController){
              return Material(
                color: Theme.of(context).backgroundColor,
                shape: Theme.of(context).bottomSheetTheme.shape,
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _BottomSheetHeader(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(translate.sort, style: Theme.of(context).textTheme.headline6),
                            MaterialButton(
                              height: 34,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              highlightColor: Colors.transparent,
                              textColor: _accentColor,
                              splashColor: Theme.of(context).selectedRowColor,
                              onPressed: () => Navigator.pop(context),
                              child: Text(translate.done),
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      sliver: SliverToBoxAdapter(
                        child: SizedBox(
                          height: 36,
                          child: Selector<QueryProvider, String>(
                            builder: (context, sortBy, _){
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Expanded(
                                    child: FlatButton.icon(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      textTheme: _buttonTextTheme,
                                      textColor: sortBy.contains('ASC') ? _accentTextThemeColor : null,
                                      color: sortBy.contains('ASC') ? _accentColor : null,
                                      shape: Border.all(
                                        color: _accentColor,
                                        width: 2,
                                      ),
                                      onPressed: () => _sortOrder('ASC'),
                                      icon: const Icon(Icons.arrow_downward, size: 20,),
                                      label: Flexible(child: FittedBox(child: Text(translate.asc),)),
                                    ),
                                  ),
                                  Expanded(
                                    child: FlatButton.icon(
                                      key: Key('DESC'),
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      textTheme: _buttonTextTheme,
                                      textColor: sortBy.contains('DESC') ? _accentTextThemeColor : null,
                                      color: sortBy.contains('DESC') ? _accentColor : null,
                                      shape: Border(
                                        bottom: BorderSide(
                                          color: _accentColor,
                                          width: 2,
                                        ),
                                        top: BorderSide(
                                          color: _accentColor,
                                          width: 2,
                                        ),
                                        left: BorderSide(
                                            color: _accentColor,
                                            width: 0.0
                                        ),
                                        right: BorderSide(
                                            color: _accentColor,
                                            width: 2.0
                                        ),
                                      ),
                                      onPressed: () => _sortOrder('DESC'),
                                      icon: const Icon(Icons.arrow_upward, size: 20),
                                      label: Flexible(child: FittedBox(child: Text(translate.desc),)),
                                    ),
                                  ),
                                ],
                              );
                            },
                            selector: (_, query) => query.sort,
                            shouldRebuild: (prev, curr) => prev != curr,
                          )
                        )
                      ),
                    ),
                    Selector<QueryProvider, String>(
                      builder: (context, order, _){
                        return SliverList(
                          delegate: SliverChildListDelegate([
                            RadioListTile<String>(
                              value: 'name',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.sortName),
                              selected: order.contains('name'),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                            RadioListTile<String>(
                              value: 'owned',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.owned),
                              selected: order.contains('owned'),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                            RadioListTile<String>(
                              value: 'wishlist',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.wished),
                              selected: order.contains('wishlist'),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                            RadioListTile<String>(
                              value: 'na',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.na),
                              selected: order == 'na',
                              secondary: Image.asset(
                                'assets/images/na.png',
                                height: 16, width: 25,
                                fit: BoxFit.fill,
                                semanticLabel: translate.na,
                              ),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                            RadioListTile<String>(
                              value: 'eu',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.eu),
                              selected: order.contains('eu'),
                              secondary: Image.asset(
                                'assets/images/eu.png',
                                height: 16, width: 25,
                                fit: BoxFit.fill,
                                semanticLabel: translate.eu,
                              ),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                            RadioListTile<String>(
                              value: 'jp',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.jp),
                              selected: order.contains('jp'),
                              secondary: DecoratedBox(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 0.75)
                                ),
                                position: DecorationPosition.foreground,
                                child: Image.asset(
                                  'assets/images/jp.png',
                                  height: 16, width: 25,
                                  fit: BoxFit.fill,
                                  semanticLabel: translate.jp,
                                ),
                              ),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                            RadioListTile<String>(
                              value: 'au',
                              groupValue: order,
                              onChanged: _selectOrder,
                              title: Text(translate.au),
                              selected: order.contains('au'),
                              secondary: Image.asset(
                                'assets/images/au.png',
                                height: 16, width: 25,
                                fit: BoxFit.fill,
                                semanticLabel: translate.au,
                              ),
                              activeColor: Theme.of(context).toggleableActiveColor,
                            ),
                          ]),
                        );
                      },
                      selector: (_, query) => query.orderCategory,
                      shouldRebuild: (prev, curr) => prev != curr,
                    ),
                  ],
                )
              );
            },
          ),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return IconButton(
      onPressed: _bottomSheet,
      icon: const Icon(Icons.sort_by_alpha),
      tooltip: translate.sort,
    );
  }
}

class _BottomSheetHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  _BottomSheetHeader({@required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: kToolbarHeight,
      child: Material(
        color: Theme.of(context).backgroundColor,
        shape: Theme.of(context).bottomSheetTheme.shape,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 24, right: 16),
              child: child,
            ),
            const Divider()
          ],
        ),
      )
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
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
        tooltip: S.of(context).upToolTip,
        heroTag: 'MenuFAB',
        onPressed: goTop,
        child: const Icon(Icons.keyboard_arrow_up, size: 36),
      )
    );
  }
}

class AmiiboGrid extends StatefulWidget {

  const AmiiboGrid({Key key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AmiiboGridState();
}

class AmiiboGridState extends State<AmiiboGrid> {
  AmiiboProvider amiiboProvider;
  SelectProvider mSelected;
  SingleAmiibo amiiboDB;
  bool _multipleSelected;
  AmiiboDB amiibo;

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    amiiboDB = context.read<SingleAmiibo>();
    mSelected = context.read<SelectProvider>();
    amiiboProvider = context.read<AmiiboProvider>();
  }

  _onDoubleTap() =>
    Navigator.pushNamed(context, "/details", arguments: <String, dynamic>{'singleAmiibo': amiiboDB, 'amiiboProvider': amiiboProvider});

  _onTap(){
    amiiboDB.shift();
    amiiboProvider.updateAmiiboDB(amiibo: amiibo);
  }

  _onLongPress(){
    if(!mSelected.addSelected(widget.key)) mSelected.removeSelected(widget.key);
    mSelected.notifyListeners();
  }

  @override
  Widget build(BuildContext context){
    _multipleSelected = mSelected.multipleSelected;
    amiibo = amiiboDB.amiibo;
    return Selector<SelectProvider,bool>(
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                      child: Hero(
                        placeholderBuilder: (context, size, child){
                          final Color color = Theme.of(context).scaffoldBackgroundColor == Colors.black
                              ? Colors.white24 : Colors.black54;
                          return ColorFiltered(
                            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                            child: child
                          );
                        },
                        transitionOnUserGestures: true,
                        tag: amiibo.key,
                        child: Image.asset(
                          'assets/collection/icon_${amiibo.key}.png',
                          fit: BoxFit.scaleDown,
                        )
                      ),
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
                      child: Text('${amiibo.name}',
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).primaryTextTheme.headline2
                      ),
                    ),
                    flex: 2,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Consumer<SingleAmiibo>(
                builder: (ctx, amiiboP, _){
                  final AmiiboDB amiibo = amiiboP.amiibo;
                  Widget icon = const SizedBox.shrink();
                  if(amiibo?.wishlist?.isOdd ?? false)
                    icon = const Icon(iconWished, size: 28, key: ValueKey(2), color: colorWished,);
                  else if(amiibo?.owned?.isOdd ?? false)
                    icon = Theme.of(context).brightness == Brightness.light ?
                    const Icon(iconOwned, size: 28, key: ValueKey(1), color: colorOwned) :
                    const Icon(iconOwnedDark, size: 28, key: ValueKey(1), color: colorOwned);
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    switchInCurve: Curves.easeInToLinear,
                    switchOutCurve: Curves.easeOutCirc,
                    transitionBuilder: (Widget child, Animation <double> animation)
                    => ScaleTransition(scale: animation, child: child,),
                    child: icon
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}