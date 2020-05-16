import 'package:amiibo_network/provider/query_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:provider/provider.dart';

class CustomQueryWidget extends StatelessWidget{
  final String title;
  final Future<List<String>> figureSeriesList;
  final Future<List<String>> cardSeriesList;
  final List<String> figures;
  final List<String> cards;

  CustomQueryWidget(
      this.title,
      {this.cardSeriesList,
        this.figureSeriesList,
        @required this.figures,
        @required this.cards
      });

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      semanticLabel: title,
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(translate.figures),
            ),
            FutureProvider<List<String>>.value(
              value: figureSeriesList,
              child: Consumer<List<String>>(
                child: const SizedBox(),
                builder: (context, snapshot, child){
                  if(snapshot != null)
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 416),
                      child: SelectedWrap(
                        series: snapshot,
                        mySeries: figures,
                      ),
                    );
                  return child;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(translate.cards),
            ),
            FutureProvider<List<String>>.value(
              value: cardSeriesList,
              child: Consumer<List<String>>(
                child: const SizedBox(),
                builder: (context, snapshot, child){
                  if(snapshot != null)
                    return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 416),
                        child: SelectedWrap(
                          series: snapshot,
                          mySeries: cards,
                        )
                    );

                  return child;
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
            textColor: Theme.of(context).accentColor,
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () async => Navigator.of(context).maybePop(false)
        ),
        FlatButton(
            textColor: Theme.of(context).accentColor,
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () async => Navigator.of(context).maybePop(true)
        ),
      ],
    );
  }
}

class SelectedWrap extends StatefulWidget {
  final List<String> series;
  final List<String> mySeries;

  SelectedWrap({this.series, this.mySeries});

  @override
  _SelectedWrapState createState() => _SelectedWrapState();
}

class _SelectedWrapState extends State<SelectedWrap> {
  //final Function deepEq = const DeepCollectionEquality.unordered().equals;
  S translate;

  @override
  void didChangeDependencies() {
    translate = S.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: <Widget>[
        ChoiceChip(
          label: Text(translate.all),
          tooltip: translate.all,
          onSelected: (isSelected) => setState((){
            widget.mySeries.clear();
            if(isSelected) widget.mySeries.addAll(widget.series);
          }),
          selected: QueryProvider.checkEquality(widget.mySeries, widget.series)
        ),
        for(String series in widget.series)
          ChoiceChip(
            label: Text(series),
            tooltip: series,
            onSelected: (isSelected) => setState((){
              final bool removed = widget.mySeries.remove(series);
              if(!removed && isSelected) widget.mySeries.add(series);
            }),
            selected: widget.mySeries.contains(series)
          ),
      ],
    );
  }
}