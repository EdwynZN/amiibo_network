import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/lock_provider.dart';
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
    final isLock = ref.watch(lockProvider.select((value) => value.lock));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        OwnedOutlinedButton(amiibo: asyncAmiibo.asData?.value, isLock: isLock),
        const Gap(24.0),
        WishedOutlinedButton(amiibo: asyncAmiibo.asData?.value, isLock: isLock),
      ],
    );
  }
}

class WishedOutlinedButton extends ConsumerWidget {
  final bool isLock;
  final Amiibo? amiibo;
  final bool isActive;

  WishedOutlinedButton({
    Key? key,
    required this.amiibo,
    required this.isLock,
  })  : isActive = amiibo != null && amiibo.userAttributes is WishedUserAttributes,
        super(key: key);

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
      onPressed: isLock
          ? null
          : () {
              if (amiibo == null) return;
              final bool newValue = !isActive;
              ref.read(serviceProvider.notifier).updateFromAmiibos(
                [
                  amiibo!.copyWith(
                    userAttributes: newValue
                      ? const WishedUserAttributes()
                      : const EmptyUserAttributes(),
                  )
                ],
              );
            },
    );
  }
}

class OwnedOutlinedButton extends ConsumerWidget {
  final bool isLock;

  OwnedOutlinedButton({
    Key? key,
    required this.amiibo,
    required this.isLock,
  })  : isActive = amiibo != null && amiibo.userAttributes is OwnedUserAttributes,
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
      onPressed: isLock
          ? null
          : () {
              if (amiibo == null) return;
              final bool newValue = !isActive;
              ref.read(serviceProvider.notifier).updateFromAmiibos(
                [
                  amiibo!.copyWith(
                    userAttributes: newValue
                      ? UserAttributes.owned()
                      : const EmptyUserAttributes(),
                  ),
                ],
              );
            },
    );
  }
}

class WishedButton extends ConsumerWidget {
  WishedButton({
    Key? key,
    required this.amiibo,
    required this.isLock,
    this.size = const Size.square(40.0),
  })  : isActive = amiibo != null && amiibo.userAttributes is WishedUserAttributes,
        super(key: key);

  final bool isLock;
  final Amiibo? amiibo;
  final Size size;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final preferencesPalette =
        Theme.of(context).extension<PreferencesExtension>()!;
    final color = preferencesPalette.wishContainer.withOpacity(0.24);
    return IconButton(
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      isSelected: isActive,
      icon: const Icon(Icons.favorite_border_outlined),
      selectedIcon: const Icon(iconWished),
      color: preferencesPalette.wishPalette.shade70,
      constraints: BoxConstraints.tight(size),
      iconSize: 20.0,
      splashRadius: 20.0,
      tooltip: translate.wishTooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: isLock
          ? null
          : () {
              if (amiibo == null) return;
              final bool newValue = !isActive;
              ref.read(serviceProvider.notifier).updateFromAmiibos(
                [
                  amiibo!.copyWith(
                    userAttributes: newValue
                      ? const WishedUserAttributes()
                      : const EmptyUserAttributes(),
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
    required this.isLock,
    this.size = const Size.square(40.0),
  })  : isActive = amiibo != null && amiibo.userAttributes is OwnedUserAttributes,
        super(key: key);

  final bool isLock;
  final Amiibo? amiibo;
  final bool isActive;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    final preferencesPalette =
        Theme.of(context).extension<PreferencesExtension>()!;
    final color = preferencesPalette.ownContainer.withOpacity(0.24);
    return IconButton(
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      isSelected: isActive,
      icon: const Icon(Icons.bookmark_outline_outlined),
      selectedIcon: const Icon(iconOwned),
      color: preferencesPalette.ownPalette.shade70,
      constraints: BoxConstraints.tight(size),
      iconSize: 20.0,
      splashRadius: 20.0,
      tooltip: translate.ownTooltip,
      splashColor: color,
      highlightColor: color,
      onPressed: isLock
          ? null
          : () {
              if (amiibo == null) return;
              final bool newValue = !isActive;
              ref.read(serviceProvider.notifier).updateFromAmiibos(
                [
                  amiibo!.copyWith(
                    userAttributes: newValue
                      ? UserAttributes.owned()
                      : const EmptyUserAttributes(),
                  ),
                ],
              );
            },
    );
  }
}
