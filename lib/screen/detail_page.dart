import 'package:flutter/material.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:amiibo_network/data/cacheDB.dart';

class DetailPage extends StatelessWidget{
  final AmiiboDB amiibo;
  final bool _brandNew;

  DetailPage({
    Key key,
    @required this.amiibo
  }) : _brandNew = amiibo.brandNew?.isEven ?? true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 250,
              alignment: Alignment.topCenter,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _CardDetailAmiibo(amiibo: amiibo),
                  if(_brandNew)
                    const Align(
                      alignment: Alignment.topRight,
                      child: const Icon(
                        Icons.new_releases,
                        size: 45.0,
                        color: Colors.yellow,
                      ),
                    ),
                ],
              ),
            ),
            /*Container(
              height: 100,
              child: Card(
                child: Center(child: Text("Coming soon..."),)
              ),
            )*/
          ],
        )
      ),
    );
  }
}

class _CardDetailAmiibo extends StatelessWidget{
  final AmiiboDB amiibo;

  _CardDetailAmiibo({
    Key key,
    @required this.amiibo
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Hero(
                    tag: amiibo.id,
                    child: CachedNetworkImage(
                      cacheManager: CacheManager(),
                      alignment: Alignment.center,
                      imageUrl: 'https://raw.githubusercontent.com/N3evin/AmiiboAPI/master/images/icon_'
                        '${amiibo.id?.substring(0,8)}-'
                        '${amiibo.id?.substring(8)}.png',
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  flex: 7,
                ),
                Expanded(
                  child: _Buttons(amiibo: amiibo),
                  flex: 2,
                )
              ],
            ),
            flex: 4,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: const VerticalDivider(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextCardDetail(text: "Type", data: amiibo.type,),
                TextCardDetail(text: "Character", data: amiibo.character,),
                if(amiibo.character != amiibo.name) TextCardDetail(text: "Name", data: amiibo.name,),
                TextCardDetail(text: "Serie", data: amiibo.amiiboSeries,),
                if(amiibo.amiiboSeries != amiibo.gameSeries) TextCardDetail(text: "Game", data: amiibo.gameSeries,),
                if(amiibo.au != null) RegionDetail(amiibo.au, 'au', 'Australia'),
                if(amiibo.eu != null) RegionDetail(amiibo.eu, 'eu', 'Europe'),
                if(amiibo.na != null) RegionDetail(amiibo.na, 'na', 'America'),
                if(amiibo.jp != null) RegionDetail(amiibo.jp, 'jp', 'Japan'),
              ],
            ),
            flex: 7,
          )
        ],
      )
    );
  }
}

class _Buttons extends StatefulWidget {
  final AmiiboDB amiibo;

  _Buttons({
    Key key,
    @required this.amiibo
  }) : super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _ButtonsState();
  }
}

class _ButtonsState extends State<_Buttons> {

  @override
  void initState() {
    widget.amiibo.brandNew = 1;
    super.initState();
  }

  @override
  _Buttons get widget => super.widget;

  @override
  dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: (widget.amiibo.owned?.isEven ?? true) ?
            Icon(Icons.star_border) : const Icon(Icons.star),
          color: Colors.pinkAccent,
          iconSize: 30.0,
          tooltip: "Owned",
          splashColor: Colors.pinkAccent[100],
          onPressed: () => setState(() {
            widget.amiibo.owned = (widget.amiibo?.owned ?? 0) ^ 1;
            if(widget.amiibo.owned.isOdd) widget.amiibo.wishlist = 0;
          }),
        ),
        IconButton(
          icon: (widget.amiibo.wishlist?.isEven ?? true) ?
            Icon(Icons.check_box_outline_blank) : const Icon(Icons.card_giftcard),
          color: Colors.yellow,
          iconSize: 30.0,
          tooltip: "Wishilist",
          splashColor: Colors.yellowAccent[100],
          onPressed: () => setState(() {
            widget.amiibo.wishlist = (widget.amiibo?.wishlist ?? 0) ^ 1;
            if(widget.amiibo.wishlist.isOdd) widget.amiibo.owned = 0;
          })
        ),
      ],
    );
  }
}

class RegionDetail extends StatelessWidget{
  final String text;
  final String asset;
  final String description;

  RegionDetail(this.text,this.asset,this.description);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 16, width: 25,
          child: Image.asset(
            'assets/images/$asset.png',
            fit: BoxFit.fill,
            semanticLabel: description,)
        ),
        Container(
          padding: EdgeInsets.only(left: 8),
          child: Text(text,
            textAlign: TextAlign.start,
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          )
        )
      ],
    );
  }
}

class TextCardDetail extends StatelessWidget{
  final String text;
  final String data;

  TextCardDetail({
    Key key,
    this.text,
    this.data
  });

  @override
  Widget build(BuildContext context){
    return Container(
      child: Text('$text: $data',
        textAlign: TextAlign.start,
        overflow: TextOverflow.fade,
        maxLines: 1,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      )
    );
  }
}