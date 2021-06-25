import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/widget/card_details.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AmiiboDetailInfo extends ConsumerWidget {
  const AmiiboDetailInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final key = watch(keyAmiiboProvider);
    final S translate = S.of(context);
    return watch(detailAmiiboProvider(key)).when(
      data: (amiibo) {
        if (amiibo == null) return const SizedBox();
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (amiibo.character != amiibo.name)
              TextCardDetail(text: translate.name(amiibo.name)),
            TextCardDetail(text: translate.serie(amiibo.amiiboSeries)),
            if (amiibo.amiiboSeries != amiibo.gameSeries)
              TextCardDetail(text: translate.game(amiibo.gameSeries)),
            TextCardDetail(
              text: translate.types(amiibo.type!),
            ),
            if (amiibo.au != null) RegionDetail(amiibo.au, 'au', translate.au),
            if (amiibo.eu != null) RegionDetail(amiibo.eu, 'eu', translate.eu),
            if (amiibo.na != null) RegionDetail(amiibo.na, 'na', translate.na),
            if (amiibo.jp != null) RegionDetail(amiibo.jp, 'jp', translate.jp),
          ],
        );
      },
      error: (_, __) => Center(
        child: TextButton(
          onPressed: () => context.refresh(detailAmiiboProvider(key)),
          child: Text(translate.splashError),
        ),
      ),
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      )),
    );
  }
}
