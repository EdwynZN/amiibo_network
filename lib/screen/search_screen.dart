import 'package:flutter/material.dart';
import 'package:amiibo_network/provider/search_provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  SearchProvider _search = SearchProvider();

  @override
  dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: Theme(
                data: Theme.of(context).copyWith(
                  appBarTheme: AppBarTheme(
                    color: Theme.of(context).backgroundColor,
                    iconTheme: Theme.of(context).iconTheme,
                    actionsIconTheme: Theme.of(context).iconTheme,
                    textTheme: Theme.of(context).textTheme
                  ),
                ),
                child: SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: Navigator.of(context).pop),
                  pinned: true,
                  title: TextField(
                    style: Theme.of(context).textTheme.body2,
                    maxLength: 15,
                    textInputAction: TextInputAction.search,
                    autofocus: true,
                    onSubmitted: Navigator.of(context).pop,
                    onChanged: _search.searchValue,
                    autocorrect: false,
                    decoration: null,
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
      )
    );
  }
}