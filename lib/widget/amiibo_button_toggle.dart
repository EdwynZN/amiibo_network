import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Buttons extends ConsumerWidget {
  const Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ref.watch(keyAmiiboProvider);
    final asyncAmiibo = ref.watch(detailAmiiboProvider(key));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OwnedButton(amiibo: asyncAmiibo.asData?.value),
        const Gap(24.0),
        WishedButton(amiibo: asyncAmiibo.asData?.value),
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
    final preferencesPalette =
        Theme.of(context).extension<PreferencesExtension>()!;
    final color = preferencesPalette.wishContainer.withOpacity(0.24);
    return IconButton.outlined(
      style: const ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
      ),
      isSelected: isActive,
      icon: const Icon(Icons.favorite_border_outlined),
      selectedIcon: const Icon(iconWished),
      color: preferencesPalette.wishPalette.shade70,
      constraints: const BoxConstraints.tightFor(height: 56.0, width: 48.0),
      iconSize: 24.0,
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
    final preferencesPalette =
        Theme.of(context).extension<PreferencesExtension>()!;
    final color = preferencesPalette.ownContainer.withOpacity(0.24);
    return IconButton.outlined(
      style: const ButtonStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
        ),
      ),
      isSelected: isActive,
      icon: const Icon(Icons.bookmark_outline_outlined),
      selectedIcon: const Icon(iconOwned),
      color: preferencesPalette.ownPalette.shade70,
      constraints: const BoxConstraints.tightFor(height: 56.0, width: 48.0),
      iconSize: 24.0,
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
