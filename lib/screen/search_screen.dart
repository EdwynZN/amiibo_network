import 'package:flutter/material.dart';
import 'package:amiibo_network/provider/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:flutter/services.dart';
import 'package:amiibo_network/widget/floating_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>{
  final SearchProvider _search = SearchProvider();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.addListener(onChangedText);
  }

  void onChangedText() => _search.searchValue(_textController.text);

  @override
  dispose() {
    _search.dispose();
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
              pinned: true,
              leading: BackButton(),
              title: TextField(
                controller: _textController,
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
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
            ),
            /*SliverPersistentHeader(
              delegate: _SliverPersistentHeader(),
              pinned: true,
            ),*/
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
                              title: Text('${snapshot.data[index]}')
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Card(
        elevation: 0.0,
        margin: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 0.0),
        shape: ContinuousRectangleBorder(),
        child: SizedBox(
          height: maxExtent,
          child: const Icon(Icons.add),
        ),
      ),
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

class TextOptions extends StatefulWidget {
  final TextEditingController controller;
  TextOptions({this.controller});
  
  @override
  State<StatefulWidget> createState() => TextOptionsState();
}

class TextOptionsState extends State<TextOptions>{
  bool clear = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_canClear);
  }

  void _canClear() {
    setState(() {
      clear = widget.controller?.text?.isNotEmpty ?? false;
    });
  }

  @override
  dispose() {
    widget.controller.removeListener(_canClear);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: clear ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: (){
                widget.controller.clear();
              }
          ) : const SizedBox(),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: (){
            print('a');
          }
        ),
      ],
    );
  }
}