import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:amiibo_network/bloc/search_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';

class SearchScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SearchScreenState();
  }
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
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFloatingBar(
            backgroundColor: Theme.of(context).backgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop()),
            pinned: true,
            title: TextField(
              maxLength: 15,
              style: TextStyle(color: Colors.black),
              textInputAction: TextInputAction.search,
              autofocus: true,
              onSubmitted: (value) => Navigator.of(context).pop(value),
              onChanged: (text) => _bloc.searchValue(text),
              autocorrect: false,
              decoration: null,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 4)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12),
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
                  else ListTile();
                },
                  childCount: snapshot.hasData ? snapshot.data.length : 0,
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}