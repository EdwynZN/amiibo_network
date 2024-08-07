import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/widget/card_details.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AmiiboCard extends ConsumerWidget {
  const AmiiboCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surface;

    final Widget asset = SizedBox(
      width: double.infinity,
      child: Hero(
        transitionOnUserGestures: true,
        tag: key,
        child: Image.asset(
          'assets/collection/icon_$key.webp',
          filterQuality: FilterQuality.high,
          fit: BoxFit.contain,
        ),
      ),
    );

    final Widget letf = ConstrainedBox(
      constraints: const BoxConstraints.tightForFinite(
        width: 120.0,
        height: 200.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Gap(2.0),
          Flexible(child: asset),
          const Gap(8.0),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 16.0,
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
                          final details = amiibo.details;
                          final title = StringBuffer(
                            translate.types(details.type),
                          );
                          if (details.cardNumber != null) {
                            title.write(' #${details.cardNumber}');
                          }
                          return title.toString();
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
        ],
      ),
    );

    return Card(
      margin: EdgeInsets.zero,
      borderOnForeground: true,
      color: cardColor,
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              letf,
              const Expanded(child: _AmiiboInfo()),
            ],
          ),
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
    final cardColor = Theme.of(context).colorScheme.surface;

    final Widget info = ref.watch(detailAmiiboProvider(id)).maybeWhen(
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
                const Gap(12.0),
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
    return Card(
      margin: const EdgeInsets.only(left: 12.0),
      color: cardColor,
      elevation: 6.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 12.0,
        ),
        child: info,
      ),
    );
  }
}
