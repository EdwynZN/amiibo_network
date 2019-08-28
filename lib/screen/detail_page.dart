import 'package:flutter/material.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';

class DetailPage extends StatelessWidget{
  final AmiiboDB amiibo;

  DetailPage({Key key, @required this.amiibo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: _CardDetailAmiibo(amiibo: amiibo)
        )
      )
    );
  }
}

class _CardDetailAmiibo extends StatelessWidget{
  final AmiiboDB amiibo;

  _CardDetailAmiibo({Key key, @required this.amiibo});

  @override
  Widget build(BuildContext context){
    return Card(
      child: LimitedBox(
        maxHeight: 250,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Hero(
                        tag: amiibo.key,
                        child: Image.asset(
                          'assets/collection/icon_${amiibo.key}.png',
                          fit: BoxFit.scaleDown,
                        )
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
            const VerticalDivider(indent: 10, endIndent: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextCardDetail(text: "Character", data: amiibo.character,),
                  if(amiibo.character != amiibo.name) TextCardDetail(text: "Name", data: amiibo.name,),
                  TextCardDetail(text: "Serie", data: amiibo.amiiboSeries,),
                  if(amiibo.amiiboSeries != amiibo.gameSeries) TextCardDetail(text: "Game", data: amiibo.gameSeries,),
                  TextCardDetail(text: "Type", data: amiibo.type,),
                  if(amiibo.au != null) RegionDetail(amiibo.au, 'au', 'Australia'),
                  if(amiibo.eu != null) RegionDetail(amiibo.eu, 'eu', 'Europe'),
                  if(amiibo.na != null) RegionDetail(amiibo.na, 'na', 'America'),
                  if(amiibo.jp != null) RegionDetail(amiibo.jp, 'jp', 'Japan'),
                ],
              ),
              flex: 7,
            )
          ],
        ),
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
    AmiiboProvider value = Provider.of<AmiiboProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: (widget.amiibo.owned?.isEven ?? true) ?
            const Icon(Icons.star_border) : const Icon(Icons.star),
          color: Colors.pinkAccent,
          iconSize: 30.0,
          tooltip: "Owned",
          splashColor: Colors.pinkAccent[100],
          onPressed: () => setState(() {
            value.countOwned = widget.amiibo.owned = (widget.amiibo?.owned ?? 0) ^ 1;
            if(widget.amiibo?.wishlist?.isOdd ?? false) value.countWished = widget.amiibo.wishlist = 0;
            value.updateAmiiboDB(amiibo: widget.amiibo);
          })
        ),
        IconButton(
          icon: (widget.amiibo.wishlist?.isEven ?? true) ?
            const Icon(Icons.check_box_outline_blank) : const Icon(Icons.card_giftcard),
          color: Colors.yellow,
          iconSize: 30.0,
          tooltip: "Wished",
          splashColor: Colors.yellowAccent[100],
          onPressed: () => setState(() {
            value.countWished = widget.amiibo.wishlist = (widget.amiibo?.wishlist ?? 0) ^ 1;
            if(widget.amiibo?.owned?.isOdd ?? false) value.countOwned = widget.amiibo.owned = 0;
            value.updateAmiiboDB(amiibo: widget.amiibo);
          })
        )
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
        Image.asset(
          'assets/images/$asset.png',
          height: 16, width: 25,
          fit: BoxFit.fill,
          semanticLabel: description,
         ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
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
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      )
    );
  }
}