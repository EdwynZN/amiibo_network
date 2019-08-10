import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:amiibo_network/bloc/search_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final SearchBloc _bloc = $Provider.of<SearchBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    $Provider.dispose<SearchBloc>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverFloatingBar(
              backgroundColor: Theme.of(context).backgroundColor,
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
                onChanged: _bloc.searchValue,
                autocorrect: false,
                decoration: null,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              sliver: StreamBuilder(
                stream: _bloc.search,
                builder: (context, AsyncSnapshot<List<String>> snapshot) => SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    if(snapshot.hasData)
                      return Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(),
                        child: ListTile(
                          onTap: () => Navigator.of(context).pop(snapshot.data[index]),
                          title: Text('${snapshot.data[index]}')
                        )
                      );
                    else return const SizedBox.shrink();
                  },
                    childCount: snapshot.hasData ? snapshot.data.length : 0,
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