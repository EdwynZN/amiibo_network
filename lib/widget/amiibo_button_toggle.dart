
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Buttons extends ConsumerWidget {
  const Buttons({Key? key}) : super(key: key);

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
