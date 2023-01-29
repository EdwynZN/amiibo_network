import 'package:amiibo_network/enum/hidden_types.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomQueryWidget extends ConsumerWidget {
  final String title;
  final List<String> figures;
  final List<String> cards;

  CustomQueryWidget(this.title, {required this.figures, required this.cards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hidden = ref.watch(hiddenCategoryProvider);
    final isFiguresShown = hidden == null || hidden != HiddenType.Figures;
    final isCardsShown = hidden == null || hidden != HiddenType.Cards;
    final S translate = S.of(context);
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      semanticLabel: title,
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (isFiguresShown) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(translate.figures),
              ),
              ref.watch(figuresProvider).maybeWhen(
                  data: (data) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 416),
                      child: SelectedWrap(
                        series: data,
                        mySeries: figures,
                      ),
                    );
                  },
                  orElse: () => const SizedBox()),
            ],
            if (isCardsShown) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(translate.cards),
              ),
              ref.watch(cardsProvider).maybeWhen(
                  data: (data) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 416),
                      child: SelectedWrap(
                        series: data,
                        mySeries: cards,
                      ),
                    );
                  },
                  orElse: () => const SizedBox()),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            onPressed: () async => Navigator.of(context).maybePop(false)),
        TextButton(
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
            onPressed: () async => Navigator.of(context).maybePop(true)),
      ],
    );
  }
}

class SelectedWrap extends StatefulWidget {
  final List<String> series;
  final List<String> mySeries;

  SelectedWrap({required this.series, required this.mySeries});

  @override
  _SelectedWrapState createState() => _SelectedWrapState();
}

class _SelectedWrapState extends State<SelectedWrap> {
  late S translate;

  @override
  void didChangeDependencies() {
    translate = S.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: <Widget>[
        FilterChip(
            showCheckmark: false,
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            label: Text(translate.all),
            tooltip: translate.all,
            onSelected: (isSelected) => setState(() {
                  widget.mySeries.clear();
                  if (isSelected) widget.mySeries.addAll(widget.series);
                }),
            selected: QueryBuilderProvider.checkEquality(
                widget.mySeries, widget.series)!),
        for (String series in widget.series)
          FilterChip(
              showCheckmark: false,
              label: Text(series),
              tooltip: series,
              onSelected: (isSelected) => setState(() {
                    final bool removed = widget.mySeries.remove(series);
                    if (!removed && isSelected) widget.mySeries.add(series);
                  }),
              selected: widget.mySeries.contains(series)),
      ],
    );
  }
}
