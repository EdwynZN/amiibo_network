import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/widget/amiibo_button_toggle.dart';
import 'package:amiibo_network/widget/amiibo_info.dart';
import 'package:amiibo_network/widget/card_details.dart';
import 'package:amiibo_network/widget/game_list.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _nameAmiiboProvider = Provider.autoDispose
  .family<AsyncValue<String?>, int>((ref, key) => 
  ref.watch(detailAmiiboProvider(key)).whenData((cb) => cb?.name)
);

class DetailPage extends ConsumerWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    return Scaffold(
      appBar: AppBar(
        title: Consumer(
          builder: (context, ref, _) => ref.watch(_nameAmiiboProvider(key))
          .maybeWhen(
            data: (name) => name != null ? Text(name) : const SizedBox(),
            orElse: () => const SizedBox(),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: LimitedBox(
              maxHeight: 250,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                            child: Hero(
                              transitionOnUserGestures: true,
                              tag: key,
                              child: Image.asset(
                                'assets/collection/icon_$key.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          flex: 7,
                        ),
                        Expanded(
                          child: const Buttons(),
                          flex: 2,
                        ),
                      ],
                    ),
                    flex: 4,
                  ),
                  const VerticalDivider(indent: 10, endIndent: 10),
                  Expanded(
                    child: const AmiiboDetailInfo(),
                    flex: 7,
                  )
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            sliver: GameListWidget(),
          ),
        ],
      ),
    );
  }
}

class _AmiiboInfo extends ConsumerWidget {
  const _AmiiboInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(keyAmiiboProvider);
    final S translate = S.of(context);
    return ref.watch(detailAmiiboProvider(id)).maybeWhen(
      data: (amiibo) {
        if (amiibo == null) return const SizedBox();
        List<InlineSpan> span = <InlineSpan>[
          TextSpan(text: translate.serie(amiibo.amiiboSeries)),
          if (amiibo.amiiboSeries != amiibo.gameSeries)
            TextSpan(text: translate.name(amiibo.gameSeries)),
          TextSpan(text: translate.types(amiibo.type!)),
          if (amiibo.au != null)
            WidgetSpan(
              child: RegionDetail(amiibo.au!, 'au', translate.au),
            ),
          if (amiibo.eu != null)
            WidgetSpan(
              child: RegionDetail(amiibo.eu!, 'eu', translate.eu),
            ),
          if (amiibo.na != null)
            WidgetSpan(
              child: RegionDetail(amiibo.na!, 'na', translate.na),
            ),
          if (amiibo.jp != null)
            WidgetSpan(
              child: RegionDetail(amiibo.jp!, 'jp', translate.jp),
            ),
        ];
        for (int i = 1; i < span.length; i = i + 2) {
          span.insert(i, const TextSpan(text: '\n\n'));
        }
        return Text.rich(
          TextSpan(
            text: amiibo.character != amiibo.name ? translate.name(amiibo.name) : null,
            children: span,
          ),
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontWeight: FontWeight.bold),
        );
      },
      orElse: () => const SizedBox(),
    );
  }
}