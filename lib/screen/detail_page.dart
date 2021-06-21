import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/game_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/widget/game_list.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/utils/format_date.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final key = watch(keyAmiiboProvider);
    return Scaffold(
      appBar: AppBar(
        title: watch(characterProvider(key)).maybeWhen(
          data: (name) => name != null ? Text(name) : null,
          orElse: () => null,
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
                              padding:
                                  const EdgeInsets.only(top: 4.0, left: 4.0),
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
                            child: const _Buttons(),
                            flex: 2,
                          ),
                        ],
                      ),
                      flex: 4,
                    ),
                    const VerticalDivider(indent: 10, endIndent: 10),
                    Expanded(
                      child: const _AmiiboInfo(),
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

    final Size size = MediaQuery.of(context).size;
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    int flex = 4;
    if (size.longestSide >= 800)
      padding = EdgeInsets.symmetric(
          horizontal: (size.width / 2 - 250).clamp(0.0, double.infinity));
    if (size.width >= 400) flex = 6;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: padding,
          child: Material(
            type: MaterialType.card,
            shape: const RoundedRectangleBorder(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
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
                              padding:
                                  const EdgeInsets.only(top: 4.0, left: 4.0),
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
                            child: const _Buttons(),
                            flex: 2,
                          ),
                        ],
                      ),
                      flex: flex,
                    ),
                    const VerticalDivider(indent: 10, endIndent: 10),
                    Expanded(
                      child: const _AmiiboDetailInfo(),
                      flex: 7,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Buttons extends ConsumerWidget {
  const _Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final key = watch(keyAmiiboProvider);
    final asyncAmiibo = watch(detailAmiiboProvider(key));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: FittedBox(
            child: OwnedButton(amiibo: asyncAmiibo.data?.value),
          ),
        ),
        Expanded(
          child: FittedBox(
            child: WishedButton(amiibo: asyncAmiibo.data?.value),
          ),
        ),
      ],
    );
  }
}

class WishedButton extends StatelessWidget {
  WishedButton({
    Key? key,
    required this.amiibo,
  })  : isActive = amiibo != null && amiibo.wishlist,
        super(key: key);

  final Amiibo? amiibo;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return IconButton(
      icon: isActive
          ? const Icon(iconWished)
          : const Icon(Icons.check_box_outline_blank),
      color: colorWished,
      iconSize: 30.0,
      tooltip: translate.wishTooltip,
      splashColor: Colors.amberAccent[100],
      onPressed: () {
        if (amiibo == null) return;
        final bool newValue = !isActive;
        context.read(serviceProvider.notifier).update(
          [
            amiibo!.copyWith(
              owned: newValue ? false : amiibo!.owned,
              wishlist: newValue,
            )
          ],
        );
      },
    );
  }
}

class OwnedButton extends StatelessWidget {
  OwnedButton({
    Key? key,
    required this.amiibo,
  })  : isActive = amiibo != null && amiibo.owned,
        super(key: key);

  final Amiibo? amiibo;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final S translate = S.of(context);
    return IconButton(
      icon: isActive
          ? const Icon(iconOwned)
          : const Icon(Icons.radio_button_unchecked),
      color: colorOwned,
      iconSize: 30.0,
      tooltip: translate.ownTooltip,
      splashColor: colorOwned[100],
      onPressed: () {
        if (amiibo == null) return;
        final bool newValue = !isActive;
        context.read(serviceProvider.notifier).update(
          [
            amiibo!.copyWith(
              owned: newValue,
              wishlist: newValue ? false : amiibo!.wishlist,
            ),
          ],
        );
      },
    );
  }
}

class _AmiiboDetailInfo extends ConsumerWidget {
  const _AmiiboDetailInfo({Key? key}) : super(key: key);

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

class _AmiiboInfo extends ConsumerWidget {
  const _AmiiboInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final id = watch(keyAmiiboProvider);
    final S translate = S.of(context);
    return watch(detailAmiiboProvider(id)).maybeWhen(
      data: (amiibo) {
        if (amiibo == null) return const SizedBox();
        List<InlineSpan> span = <InlineSpan>[
          if (amiibo.character != amiibo.name)
            TextSpan(text: translate.name(amiibo.name)),
          TextSpan(text: translate.serie(amiibo.amiiboSeries)),
          if (amiibo.amiiboSeries != amiibo.gameSeries)
            TextSpan(text: translate.name(amiibo.gameSeries)),
          TextSpan(text: translate.types(amiibo.type!)),
          if (amiibo.au != null)
            WidgetSpan(
              child: RegionDetail(amiibo.au, 'au', translate.au),
            ),
          if (amiibo.eu != null)
            WidgetSpan(
              child: RegionDetail(amiibo.eu, 'eu', translate.eu),
            ),
          if (amiibo.na != null)
            WidgetSpan(
              child: RegionDetail(amiibo.na, 'na', translate.na),
            ),
          if (amiibo.jp != null)
            WidgetSpan(
              child: RegionDetail(amiibo.jp, 'jp', translate.jp),
            ),
        ];
        for (int i = 0; i < span.length; i = i + 2) {
          span.insert(i, const TextSpan(text: '\n\n'));
        }
        return Text.rich(
          TextSpan(
            text: translate.character(amiibo.character),
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

class RegionDetail extends StatelessWidget {
  final String asset;
  final String description;
  final FormatDate formatDate;

  RegionDetail(dateString, this.asset, this.description)
      : formatDate = FormatDate(dateString);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/$asset.png',
          height: 16,
          width: 25,
          fit: BoxFit.fill,
          semanticLabel: description,
        ),
        Flexible(
          child: FittedBox(
            child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(
                  formatDate.localizedDate(context),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  maxLines: 1,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontWeight: FontWeight.bold),
                )),
          ),
        )
      ],
    );
  }
}

class TextCardDetail extends StatelessWidget {
  final String? text;

  TextCardDetail({
    Key? key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Text(
      text!,
      textAlign: TextAlign.start,
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
      style: Theme.of(context)
          .textTheme
          .bodyText2!
          .copyWith(fontWeight: FontWeight.bold),
    ));
  }
}
