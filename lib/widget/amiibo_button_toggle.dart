import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Buttons extends ConsumerWidget {
  const Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    final asyncAmiibo = ref.watch(detailAmiiboProvider(key));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: FittedBox(
            child: OwnedButton(amiibo: asyncAmiibo.asData?.value),
          ),
        ),
        Expanded(
          child: FittedBox(
            child: WishedButton(amiibo: asyncAmiibo.asData?.value),
          ),
        ),
      ],
    );
  }
}

class WishedButton extends ConsumerWidget {
  WishedButton({
    Key? key,
    required this.amiibo,
  })  : isActive = amiibo != null && amiibo.wishlist,
        super(key: key);

  final Amiibo? amiibo;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final preferencesPalette = Theme.of(context).extension<PreferencesExtension>()!;
    final color = preferencesPalette.wishContainer.withOpacity(0.24);
    return IconButton(
      icon: isActive
          ? const Icon(iconWished)
          : const Icon(Icons.check_box_outline_blank),
      color: preferencesPalette.wishPalette.shade70,
      iconSize: 30.0,
      splashRadius: 24.0,
      tooltip: translate.wishTooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: () {
        if (amiibo == null) return;
        final bool newValue = !isActive;
        ref.read(serviceProvider.notifier).update(
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

class OwnedButton extends ConsumerWidget {
  OwnedButton({
    Key? key,
    required this.amiibo,
  })  : isActive = amiibo != null && amiibo.owned,
        super(key: key);

  final Amiibo? amiibo;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final preferencesPalette = Theme.of(context).extension<PreferencesExtension>()!;
    final color = preferencesPalette.ownContainer.withOpacity(0.24);
    return IconButton(
      icon: isActive
          ? const Icon(iconOwned)
          : const Icon(Icons.radio_button_unchecked),
      color: preferencesPalette.ownPalette.shade70,
      iconSize: 30.0,
      splashRadius: 24.0,
      tooltip: translate.ownTooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: () {
        if (amiibo == null) return;
        final bool newValue = !isActive;
        ref.read(serviceProvider.notifier).update(
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
