import 'package:flutter/material.dart';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:provider/provider.dart';
import 'package:amiibo_network/provider/amiibo_provider.dart';
import 'package:amiibo_network/provider/theme_provider.dart';

class DetailPage extends StatelessWidget{
  final int index;

  DetailPage({Key key,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Provider<int>.value(
            value: index,
            child: _CardDetailAmiibo(),
          )
        )
      )
    );
  }
}

class _CardDetailAmiibo extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    final AmiiboProvider amiiboProvider = Provider.of<AmiiboProvider>(context, listen: false);
    final int index = Provider.of<int>(context, listen: false);
    final AmiiboDB amiibo = amiiboProvider.amiibosDB.amiibo[index];
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
                      padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                      child: Hero(
                        transitionOnUserGestures: true,
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
                    child: StatefulBuilder(
                      builder: (ctx, setState){
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            IconButton(
                              icon: (amiibo.owned?.isEven ?? true) ?
                              const Icon(Icons.radio_button_unchecked) : const Icon(iconOwned),
                              color: colorOwned,
                              iconSize: 30.0,
                              tooltip: "Owned",
                              splashColor: colorOwned[100],
                              onPressed: () => setState(() {
                                amiiboProvider.countOwned = amiibo.owned = (amiibo?.owned ?? 0) ^ 1;
                                if(amiibo?.wishlist?.isOdd ?? false) amiiboProvider.countWished = amiibo.wishlist = 0;
                                amiiboProvider.updateAmiiboDB(amiibo: amiibo);
                              })
                            ),
                            IconButton(
                              icon: (amiibo.wishlist?.isEven ?? true) ?
                              const Icon(Icons.check_box_outline_blank) : const Icon(iconWished),
                              color: colorWished,
                              iconSize: 30.0,
                              tooltip: "Wished",
                              splashColor: Colors.amberAccent[100],
                              onPressed: () => setState(() {
                                amiiboProvider.countWished = amiibo.wishlist = (amiibo?.wishlist ?? 0) ^ 1;
                                if(amiibo?.owned?.isOdd ?? false) amiiboProvider.countOwned = amiibo.owned = 0;
                                amiiboProvider.updateAmiiboDB(amiibo: amiibo);
                              })
                            )
                          ],
                        );
                      }
                    ),
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

class RegionDetail extends StatelessWidget{
  final String date;
  final String asset;
  final String description;

  RegionDetail(this.date,this.asset,this.description);

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
          child: Text(date,
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