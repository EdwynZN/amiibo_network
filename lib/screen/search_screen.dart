import 'package:flutter/material.dart';
import 'package:amiibo_network/provider/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:flutter/services.dart';
import 'package:amiibo_network/widget/floating_bar.dart';
import 'package:amiibo_network/utils/amiibo_category.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>{
  static final RegExp _regWhiteList = RegExp('^[A-Za-zÀ-ÿ0-9 .\/-]*\$');
  final _textController = TextEditingController();
  SearchProvider _search;

  @override
  void initState() {
    super.initState();
    _textController.addListener(onChangedText);
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
    _search = Provider.of<SearchProvider>(context, listen: false);
  }

  void onChangedText() => _search?.searchValue(_textController.text);

  @override
  dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverFloatingBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
              title: TextField(
                controller: _textController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(25),
                  WhitelistingTextInputFormatter(_regWhiteList)
                ],
                textInputAction: TextInputAction.search,
                autofocus: true,
                onSubmitted: Navigator.of(context).pop,
                //onChanged: _search.searchValue,
                style: Theme.of(context).textTheme.display1,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: Provider.of<AmiiboProvider>(context).strFilter,
                  hintStyle: Theme.of(context).textTheme.display1.copyWith(
                    color: Theme.of(context).textTheme.display1.color.withOpacity(0.5)
                  ),
                  border: InputBorder.none
                )
              ),
              trailing: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                child: const SizedBox(),
                builder: (context, text, child){
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: text.text.isEmpty ? child : IconButton(
                      highlightColor: Colors.transparent,
                      icon: const Icon(Icons.close),
                      onPressed: () => _textController?.clear(),
                      tooltip: 'Clear',
                    ),
                  );
                },
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverPersistentHeader(),
              pinned: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.0),
              sliver: StreamBuilder<List<String>>(
                stream: _search.search,
                builder: (context, snapshot) => SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    if(snapshot.hasData)
                      return AnimatedSwitcher(duration: const Duration(milliseconds: 200),
                        child: Card(
                          key: Key(snapshot.data[index]),
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(),
                          child: ListTile(
                            onTap: () => Navigator.of(context).pop(snapshot.data[index]),
                            title: Text('${snapshot.data[index]}'),
                            //subtitle: Text('AmiiboSeries'),
                          )
                        ),
                      );
                    else return const SizedBox.shrink();
                  },
                    childCount: snapshot.hasData ? snapshot.data.length : 10,
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class _SliverPersistentHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Color _color = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: [0.4, 0.7, 0.9],
          colors: [
            _color,
            _color.withOpacity(0.85),
            _color.withOpacity(0.2),
          ]
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: maxExtent,
      child: CategoryControl(),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate)
    => maxExtent != oldDelegate.maxExtent || minExtent != oldDelegate.minExtent;
}

class CategoryControl extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CategoryControlState();
}

class CategoryControlState extends State<CategoryControl>{

  void _selectCategory(AmiiboCategory category){
    final SearchProvider _search = Provider.of<SearchProvider>(context, listen: false);
    if(_search.category == category) return;
    _search.category = category;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final SearchProvider _search = Provider.of<SearchProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: FlatButton.icon(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            textColor: Theme.of(context).textTheme.title.color,
            color: _search.category == AmiiboCategory.Name ? Theme.of(context).accentColor : null,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
              side: BorderSide(
                color: Theme.of(context).accentColor,
                width: 2,
              )
            ),
            onPressed: () => _selectCategory(AmiiboCategory.Name),
            icon: const Icon(Icons.group, size: 20,),
            label: Flexible(child: FittedBox(child: Text('Name'),)),
          ),
        ),
        Expanded(
          child: FlatButton.icon(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            textColor: Theme.of(context).textTheme.title.color,
            color: _search.category == AmiiboCategory.Game ? Theme.of(context).accentColor : null,
            shape: Border(
              bottom: BorderSide(
                color: Theme.of(context).accentColor,
                width: 2,
              ),
              top: BorderSide(
                color: Theme.of(context).accentColor,
                width: 2,
              ),
              left: BorderSide(
                color: Theme.of(context).accentColor,
                width: 0.0
              ),
              right: BorderSide(
                color: Theme.of(context).accentColor,
                width: 0.0
              ),
            ),
            onPressed: () => _selectCategory(AmiiboCategory.Game),
            icon: const Icon(Icons.games, size: 20,),
            label: Flexible(child: FittedBox(child: Text('Game'),)),
          ),
        ),
        Expanded(
          child: FlatButton.icon(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            textColor: Theme.of(context).textTheme.title.color,
            color: _search.category == AmiiboCategory.AmiiboSeries ? Theme.of(context).accentColor : null,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
              side: BorderSide(
                color: Theme.of(context).accentColor,
                width: 2,
              )
            ),
            onPressed: () => _selectCategory(AmiiboCategory.AmiiboSeries),
            icon: const Icon(Icons.nfc, size: 20,),
            label: Flexible(child: FittedBox(child: Text('Serie'),)),
          ),
        ),
      ],
    );
  }
}