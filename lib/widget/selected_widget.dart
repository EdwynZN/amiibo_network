import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/model/selection.dart';

final _singleAmiibo = Provider.autoDispose
  .family<AsyncValue<Amiibo>, int>((ref, index) =>
  ref.watch(amiiboHomeListProvider).whenData((value) => value[index]),
  name: 'Amiibo index '
);

class AnimatedSelection extends StatefulHookConsumerWidget {
  final bool ignore;

  const AnimatedSelection({Key? key, this.ignore = false}) : super(key: key);

  @override
  _AnimatedSelectionState createState() => _AnimatedSelectionState();
}

class _AnimatedSelectionState extends ConsumerState<AnimatedSelection> {
  void _onDoubleTap(int key) => context.push('/amiibo/$key');

  void _onTap(int key) {
    ref.read(serviceProvider.notifier).shift(key);
  }

  void _onLongPress(int key) => ref.read(selectProvider).onLongPress(key);

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(indexAmiiboProvider);
    final key = ref.watch(keyAmiiboProvider);
    final select = ref.watch(
      selectProvider.select<Selection>(
        (cb) => Selection(
          activated: cb.multipleSelected,
          selected: cb.isSelected(key),
        ),
      ),
    );
    return ref.watch(_singleAmiibo(index)).when(
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linearToEaseOut,
          decoration: ShapeDecoration(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))
            ),
            color: select.selected
            ? theme.colorScheme.tertiaryContainer
            : null,
          ),
          margin: const EdgeInsets.only(right: 2.0, bottom: 2.0),
          padding: select.selected
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
            : EdgeInsets.zero,
          child: Stack(
            children: <Widget>[
              Card(
                elevation: select.selected ? 16.0 : 4.0,
                color: select.selected ? theme.colorScheme.tertiaryContainer : null,
                shadowColor: Colors.black26,
                borderOnForeground: true,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  splashColor: theme.colorScheme.tertiaryContainer,
                  splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
                  onDoubleTap: select.activated || widget.ignore ? null : () => _onDoubleTap(key),
                  onTap: () {
                    if (widget.ignore) {
                      _onDoubleTap(key);
                    } else if (select.activated) {
                      _onLongPress(key);
                    } else {
                      _onTap(key);
                    }
                  },
                  onLongPress: widget.ignore ? null : () => _onLongPress(key),
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
                                  theme.brightness == Brightness.dark
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
                                'assets/collection/icon_${amiibo.key}.webp',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Card(
                        borderOnForeground: true,
                        margin: const EdgeInsets.only(top: 4.0),
                        surfaceTintColor: theme.backgroundColor,
                        color: select.selected ? theme.colorScheme.inverseSurface : theme.colorScheme.surfaceVariant,
                        elevation: select.selected ? 16.0 : 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            amiibo.name,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: theme.primaryTextTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: select.selected ? theme.colorScheme.onInverseSurface : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
          ),
        );
      },
    );
  }
}