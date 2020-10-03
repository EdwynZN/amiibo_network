import 'package:amiibo_network/provider/query_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/service/service.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/widget/theme_widget.dart';
import 'package:amiibo_network/provider/stat_provider.dart';
import 'package:amiibo_network/provider/theme_provider.dart';
import 'package:amiibo_network/utils/amiibo_category.dart';
import 'package:amiibo_network/generated/l10n.dart';
import '../model/query_builder.dart';
import '../widget/selected_chip.dart';

class CollectionDrawer extends StatefulWidget{
  final VoidCallback restart;

  CollectionDrawer({Key key, this.restart}) : super(key: key);

  @override
  _CollectionDrawerState createState() => _CollectionDrawerState();
}

class _CollectionDrawerState extends State<CollectionDrawer> {
  static bool _figureExpand = false;
  static bool _cardExpand = false;
  final Service _service = Service();
  Future<List<String>> __listOfFigures;
  Future<List<String>> __listOfCards;
  QueryProvider queryProvider;

  @override
  void didChangeDependencies() {
    queryProvider = Provider.of<QueryProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  Future<List<String>> get _listOfFigures => __listOfFigures ??= _service.fetchDistinct(column: ['amiiboSeries'],
      expression: InCond.inn('type', ['Figure', 'Yarn']), orderBy: 'amiiboSeries');
  Future<List<String>> get _listOfCards => __listOfCards ??= _service.fetchDistinct(column: ['amiiboSeries'],
      expression: Cond.eq('type', 'Card'), orderBy: 'amiiboSeries');

  void figureExpand(bool x) => _figureExpand = x;
  void cardExpand(bool x) => _cardExpand = x;

  _onTapTile(AmiiboCategory category, String tile){
    if(queryProvider.strFilter != tile || queryProvider.category != category) {
      queryProvider.resetPagination(category, tile);
      widget.restart();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return ListTileTheme(
      iconColor: Theme.of(context).iconTheme.color,
      textColor: Theme.of(context).textTheme.bodyText2.color,
      style: ListTileStyle.drawer,
      selectedColor: Theme.of(context).toggleableActiveColor,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: _HeaderDrawer(),
                  ),
                  SliverToBoxAdapter(
                    child: Consumer<StatProvider>(
                      child: Text(translate.showPercentage, overflow: TextOverflow.fade,),
                      builder: (ctx, statMode, child){
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: child,
                          value: statMode.isPercentage,
                          onChanged: statMode.toggleStat,
                          checkColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
                        );
                      },
                    ),
                  ),
                  Consumer<QueryProvider>(
                    builder: (context, filter, child){
                      final String _selected = filter.strFilter;
                      final AmiiboCategory _category = filter.category;
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          ListTile(
                            onTap: () => _onTapTile(AmiiboCategory.Custom, 'Custom'),
                            onLongPress: () async {
                              final List<String> figures = filter.customFigures;
                              final List<String> cards = filter.customCards;
                              bool save = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) =>
                                  CustomQueryWidget(translate.category(AmiiboCategory.Custom),
                                    figureSeriesList: __listOfFigures,
                                    cardSeriesList: __listOfCards,
                                    figures: figures,
                                    cards: cards,
                                  )
                              ) ?? false;
                              if(save) await filter.updateCustom(figures, cards);
                            },
                            leading: const Icon(Icons.create),
                            title: Text(translate.category(AmiiboCategory.Custom)),
                            selected: _selected == 'Custom',
                          ),
                          ListTile(
                            onTap: () => _onTapTile(AmiiboCategory.All,'All'),
                            leading: const Icon(Icons.all_inclusive),
                            title: Text(translate.category(AmiiboCategory.All)),
                            selected: _selected == 'All',
                          ),
                          ListTile(
                            onTap: () => _onTapTile(AmiiboCategory.Owned,'Owned'),
                            leading: const Icon(iconOwned),
                            title: Text(translate.category(AmiiboCategory.Owned)),
                            selected: _selected == 'Owned',
                          ),
                          ListTile(
                            onTap: () => _onTapTile(AmiiboCategory.Wishlist,'Wishlist'),
                            leading: const Icon(iconWished),
                            title: Text(translate.category(AmiiboCategory.Wishlist)),
                            selected: _selected == 'Wishlist',
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context,"/stats");
                            },
                            leading: const Icon(Icons.timeline),
                            title: Text(translate.stats),
                            selected: _selected == 'Stats',
                          ),
                          FutureProvider<List<String>>(
                            create: (_) => _listOfFigures,
                            child: Consumer<List<String>>(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).accentColor,
                                  foregroundColor: Theme.of(context).accentIconTheme.color,
                                  radius: 12,
                                  child: const Icon(Icons.all_inclusive, size: 16,),
                                ),
                                title: Text(translate.category(AmiiboCategory.Figures)),
                                onTap: () => _onTapTile(AmiiboCategory.Figures,'Figures'),
                                selected: _selected == 'Figures',
                              ),
                              builder: (context, snapshot, child){
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    dividerColor: Colors.transparent,
                                    accentColor: Theme.of(context).iconTheme.color,
                                  ),
                                  child: ExpansionTile(
                                    leading: const Icon(Icons.toys),
                                    title: Text(translate.figures),
                                    initiallyExpanded: _figureExpand,
                                    onExpansionChanged: figureExpand,
                                    children: <Widget>[
                                      child,
                                      if(snapshot != null)
                                        for(String series in snapshot)
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Theme.of(context).accentColor,
                                              foregroundColor: Theme.of(context).accentIconTheme.color,
                                              radius: 12,
                                              child: Text(series[0]),
                                            ),
                                            title: Text(series),
                                            onTap: () => _onTapTile(AmiiboCategory.FigureSeries,series),
                                            selected: _category == AmiiboCategory.FigureSeries && _selected == series,
                                          ),
                                      ],
                                    )
                                );
                              },
                            ),
                          ),
                          FutureProvider<List<String>>(
                            create: (_) => _listOfCards,
                            child: Consumer<List<String>>(
                              child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).accentColor,
                                    foregroundColor: Theme.of(context).accentIconTheme.color,
                                    radius: 12,
                                    child: const Icon(Icons.all_inclusive, size: 16,),
                                  ),
                                  title: Text(translate.category(AmiiboCategory.Cards)),
                                  onTap: () => _onTapTile(AmiiboCategory.Cards,'Cards'),
                                  selected: _selected == 'Cards',
                                ),
                              builder: (context, snapshot, child){
                                return Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                      accentColor: Theme.of(context).iconTheme.color,
                                    ),
                                    child: ExpansionTile(
                                      leading: const Icon(Icons.view_carousel),
                                      title: Text(translate.cards),
                                      initiallyExpanded: _cardExpand,
                                      onExpansionChanged: cardExpand,
                                      children: <Widget>[
                                        child,
                                        if(snapshot != null)
                                          for(String series in snapshot)
                                            ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor: Theme.of(context).accentColor,
                                                foregroundColor: Theme.of(context).accentIconTheme.color,
                                                radius: 12,
                                                child: Text(series[0]),
                                              ),
                                              title: Text(series),
                                              onTap: () => _onTapTile(AmiiboCategory.CardSeries,series),
                                              selected: _category == AmiiboCategory.CardSeries && _selected == series,
                                            ),
                                      ],
                                    )
                                );
                              },
                            ),
                          ),
                        ]),
                      );
                    }
                  )
                ],
              )
            ),
            const Divider(height: 1.0),
            ListTile(
              dense: true,
              onTap: () {
                Navigator.popAndPushNamed(context,"/settings");
              },
              leading: const Icon(Icons.settings),
              title: Text(translate.settings),
              trailing: ThemeButton(openDialog: true)
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
        color: Theme.of(context).primaryColorBrightness == Brightness.dark
          ? Colors.white54 : null,
      ),
    );
  }
}