import 'package:flutter/material.dart';
import 'package:amiibo_network/bloc/amiibo_bloc.dart';
import 'package:amiibo_network/bloc/bloc_provider.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final AmiiboBloc _bloc = $Provider.of<AmiiboBloc>();
  static List<String> list = <String>['All', 'Owned', 'Wishlist'];
  static String filter = 'All';
  static bool searchFilter = false;

  initBloc() async{
    await _bloc.fetchAllAmiibosDB();
    list.addAll(await _bloc.allSeries.first);
  }

  @override
  void initState() {
    initBloc();
    super.initState();
  }

  @override
  dispose(){
    $Provider.dispose<AmiiboBloc>();
    super.dispose();
  }

  Theme _popUpMenu(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: PopupMenuButton<String>(
        itemBuilder: (context) => [
          for(var series in list) PopupMenuItem(
            value: series,
            child:  Row(
              children: <Widget>[
                if(series == 'All') Icon(Icons.all_inclusive)
                else if(series == 'Owned') Icon(Icons.favorite, color: Colors.pinkAccent,)
                else if(series == 'Wishlist') Icon(Icons.cake, color: Colors.yellowAccent,)
                else CircleAvatar(child: Text(series[0]), radius: 14,),
                Container(child: Text(series), margin: EdgeInsets.only(left: 8),)
              ],
            ),
          ),
        ],
        icon: Icon(Icons.filter_list, color: Colors.black,),
        offset: Offset(0, 100),
        tooltip: 'Categories',
        onSelected: (value) {
          searchFilter = false;
          if(filter != value){
            filter = value;
            _bloc.fetchByCategory(value, searchFilter);
          }
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverFloatingBar(
              backgroundColor: Theme.of(context).backgroundColor,
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              leading: _popUpMenu(context),
              title: InkWell(
                child: Text('Search Amiibo', style: TextStyle(color: Colors.black),),
                onTap: () => Navigator.pushNamed(context, "/search").then((value) {
                  if(value != null) {
                    searchFilter = true;
                    filter = value;
                    _bloc.fetchByCategory(value, searchFilter);
                  }
                })
              ),
              trailing: CircleAvatar(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/settings"),
                  child: Icon(Icons.settings),
                )
              ),
            ),
            SliverPadding(padding: EdgeInsets.symmetric(horizontal: 5),
              sliver: StreamBuilder(
                stream: _bloc.allAmiibosDB,
                builder: (context, AsyncSnapshot<AmiiboLocalDB> snapshot) => SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 7),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          if(snapshot.hasData) GestureDetector(
                            onTap: () async {
                              Navigator.pushNamed(context, "/details", arguments: snapshot.data.amiibo[index])
                                .then((_) {
                                _bloc.updateAmiiboDB(amiibo: snapshot.data.amiibo[index]);
                                if(filter == 'Owned' && snapshot.data.amiibo[index].owned != 1) snapshot.data.amiibo.removeAt(index);
                                if(filter == 'Wishlist' && snapshot.data.amiibo[index].wishlist != 1) snapshot.data.amiibo.removeAt(index);
                              });
                            },
                            child: AmiiboGrid(amiibo: snapshot.data.amiibo[index]),
                          ),
                          if(snapshot.data.amiibo[index].brandNew == null) Align(
                            alignment: Alignment.topRight,
                            child: Icon(Icons.new_releases, color: Colors.yellowAccent,),
                          ),
                        ],
                      );
                    },
                    addRepaintBoundaries: false,
                    childCount: snapshot.hasData ? snapshot.data.amiibo.length : 0,
                  )
                ),
              )
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder(
        initialData: false,
        stream: _bloc.findNew,
        builder: (context, AsyncSnapshot<bool> snapshotNew){
          if(snapshotNew.data)
            return FloatingActionButton.extended(
              onPressed: () => _bloc.cleanBrandNew(filter, searchFilter),
              label: Text('Clean New'),
              icon: Icon(Icons.new_releases, color: Colors.yellowAccent,),
            );
          else
            return Container();
        }
      )
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
    return Card(
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
                  useOldImageOnUrlChange: false,
                  imageUrl: 'https://raw.githubusercontent.com/N3evin/AmiiboAPI/master/images/icon_'
                    '${amiibo.toMap()['id']?.toString()?.substring(0,8)}-'
                    '${amiibo.toMap()['id']?.toString()?.substring(8)}'
                    '.png',
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            flex: 8,
          ),
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).unselectedWidgetColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)))),
              alignment: Alignment.center,
              child: Text('${amiibo.name}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}