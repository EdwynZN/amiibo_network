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

class SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin{
  SearchProvider _search = SearchProvider();
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this)..value = 0.0..forward();
  }

  @override
  dispose() {
    _search.dispose();
    _animationController.dispose();
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
                inputFormatters: [LengthLimitingTextInputFormatter(15)],
                textInputAction: TextInputAction.search,
                autofocus: true,
                onSubmitted: Navigator.of(context).pop,
                onChanged: _search.searchValue,
                style: Theme.of(context).textTheme.display1,
                autocorrect: false,
                decoration: InputDecoration.collapsed(
                  hintText: Provider.of<AmiiboProvider>(context).strFilter,
                  hintStyle: Theme.of(context).textTheme.display1.copyWith(
                      color: Theme.of(context).textTheme.display1.color.withOpacity(0.5)
                  ),
                ),
              ),
            ),
            SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6.0),
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