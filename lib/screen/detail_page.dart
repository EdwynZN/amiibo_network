import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/widget/amiibo_button_toggle.dart';
import 'package:amiibo_network/widget/card_details.dart';
import 'package:amiibo_network/widget/game_list.dart';
import 'package:flutter/material.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _nameAmiiboProvider = Provider.autoDispose
    .family<AsyncValue<String?>, int>((ref, key) =>
        ref.watch(detailAmiiboProvider(key)).whenData((cb) => cb?.details.name));

class DetailPage extends ConsumerWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 0.0,
        titleTextStyle: AppBarTheme.of(context).titleTextStyle?.copyWith(
          fontSize: 22.0,
          fontWeight: FontWeight.normal,
          letterSpacing: -0.25,
          wordSpacing: -0.15,
        ),
        title: Consumer(
          builder: (context, ref, _) => ref
              .watch(_nameAmiiboProvider(key))
              .maybeWhen(
                data: (name) => name != null ? Text(name) : const SizedBox(),
                orElse: () => const SizedBox(),
              ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _AmiiboCard()),
          const SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            sliver: GameListWidget(),
          ),
        ],
      ),
    );
  }
}

class _AmiiboCard extends ConsumerWidget {
  // ignore: unused_element
  const _AmiiboCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.background;

    final Widget letf = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          margin: EdgeInsets.zero,
          color: cardColor,
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: SizedBox(
              width: double.infinity,
              child: Hero(
                transitionOnUserGestures: true,
                tag: key,
                child: Image.asset(
                  'assets/collection/icon_$key.webp',
                  filterQuality: FilterQuality.medium,
                  fit: BoxFit.scaleDown,
                  height: 200.0,
                  cacheHeight: 200,
                ),
              ),
            ),
          ),
        ),
        const Gap(4.0),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 12.0,
            ),
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: theme.colorScheme.primaryContainer,
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final S translate = S.of(context);
                final id = ref.watch(keyAmiiboProvider);
                final text = ref.watch(detailAmiiboProvider(id)).maybeWhen(
                      data: (amiibo) {
                        if (amiibo == null) return '';
                        return translate.types(amiibo.details.type!);
                      },
                      orElse: () => '...',
                    );
                return Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                );
              },
            ),
          ),
        ),
        const Gap(8.0),
        const Buttons(),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      borderOnForeground: true,
      color: cardColor,
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.0)),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 340.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 4, child: letf),
            const VerticalDivider(indent: 0.0, endIndent: 0.0, width: 24.0),
            const Expanded(flex: 7, child: _AmiiboInfo()),
          ],
        ),
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
          data: (generalAmiibo) {
            if (generalAmiibo == null) return const SizedBox();
            final amiibo = generalAmiibo.details;
            final theme = Theme.of(context);
            final primaryTextTheme = theme.primaryTextTheme.apply(
              bodyColor: theme.colorScheme.onPrimaryContainer,
              displayColor: theme.colorScheme.onPrimaryContainer,
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  amiibo.gameSeries,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: primaryTextTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    height: 1.25,
                    letterSpacing: -0.15,
                  ),
                ),
                if (amiibo.amiiboSeries != amiibo.gameSeries) ...[
                  const Gap(4.0),
                  Text(
                    amiibo.amiiboSeries,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: primaryTextTheme.titleMedium?.copyWith(
                      fontSize: 18.0,
                      height: 1.15,
                      letterSpacing: -0.25,
                    ),
                  ),
                ],
                const Gap(16.0),
                if (amiibo.au != null) ...[
                  RegionDetail(
                    amiibo.au!,
                    NetworkIcons.au,
                    translate.au,
                    style: primaryTextTheme.bodyMedium,
                  ),
                  const Gap(8.0),
                ],
                if (amiibo.eu != null) ...[
                  RegionDetail(
                    amiibo.eu!,
                    NetworkIcons.eu,
                    translate.eu,
                    style: primaryTextTheme.bodyMedium,
                  ),
                  const Gap(8.0),
                ],
                if (amiibo.na != null) ...[
                  RegionDetail(
                    amiibo.na!,
                    NetworkIcons.na,
                    translate.na,
                    style: primaryTextTheme.bodyMedium,
                  ),
                  const Gap(8.0),
                ],
                if (amiibo.jp != null) ...[
                  RegionDetail(
                    amiibo.jp!,
                    NetworkIcons.jp,
                    translate.au,
                    style: primaryTextTheme.bodyMedium,
                  ),
                  const Gap(8.0),
                ],
              ],
            );
          },
          orElse: () => const SizedBox(),
        );
  }
}
