import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _singleAmiibo = Provider.autoDispose
  .family<AsyncValue<Amiibo>, int>((ref, index) =>
  ref.watch(amiiboHomeListProvider).whenData((value) => value[index]),
  name: 'Amiibo index '
);

class AmiiboGrid extends ConsumerWidget {
  const AmiiboGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final index = watch(indexAmiiboProvider);
    return watch(_singleAmiibo(index)).when(
      loading: () => const Card(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const Card(),
      data: (amiibo) {
        final theme = Theme.of(context);
        Widget icon = const SizedBox.shrink();
        if (amiibo.wishlist)
          icon = const Icon(
            iconWished,
            size: 28,
            key: ValueKey(2),
            color: colorWished,
          );
        else if (amiibo.owned)
          icon = theme.brightness == Brightness.light
              ? const Icon(iconOwned,
                  size: 28, key: ValueKey(1), color: colorOwned)
              : const Icon(iconOwnedDark,
                  size: 28, key: ValueKey(1), color: colorOwned);
        return Stack(
          children: <Widget>[
            Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Flexible(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Hero(
                          placeholderBuilder: (context, size, child) {
                            final Color color =
                              theme.scaffoldBackgroundColor == Colors.black
                                ? Colors.white24
                                : Colors.black54;
                            return ColorFiltered(
                              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                              child: child,
                            );
                          },
                          transitionOnUserGestures: true,
                          tag: amiibo.key,
                          child: Image.asset(
                            'assets/collection/icon_${amiibo.key}.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: ShapeDecoration(
                      color: Theme.of(context).primaryColorLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      '${amiibo.name}',
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).primaryTextTheme.headline2,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInToLinear,
                switchOutCurve: Curves.easeOutCirc,
                transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(
                    scale: animation,
                    child: child,
                ),
                child: icon,
              ),
            ),
          ],
        );
      },
    );
  }
}
