import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomQueryWidget extends StatelessWidget{
  final String title;
  final List<String> figures;
  final List<String> cards;

  CustomQueryWidget(
    this.title,{
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
            HookBuilder(
              builder: (context) {
                return useProvider(
                  figuresProvider,
                ).maybeWhen(
                  data: (data) {
                    return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 416),
                    child: SelectedWrap(
                      series: data,
                      mySeries: figures,
                    ),
                  );
                  },
                  orElse: () => const SizedBox()
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(translate.cards),
            ),
            HookBuilder(
              builder: (context) {
                return useProvider(
                  cardsProvider,
                ).maybeWhen(
                  data: (data) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 416),
                      child: SelectedWrap(
                        series: data,
                        mySeries: cards,
                      ),
                    );
                  },
                  orElse: () => const SizedBox()
                );
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          onPressed: () async => Navigator.of(context).maybePop(false)
        ),
        TextButton(
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