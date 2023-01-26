import 'package:amiibo_network/model/amiibo.dart';
import 'package:amiibo_network/repository/theme_repository.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/select_provider.dart';
import 'package:amiibo_network/riverpod/service_provider.dart';
import 'package:amiibo_network/utils/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:amiibo_network/model/selection.dart';

final _singleAmiibo = Provider.autoDispose.family<AsyncValue<Amiibo>, int>(
    (ref, index) =>
        ref.watch(amiiboHomeListProvider).whenData((value) => value[index]),
    name: 'Amiibo index ');

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
            ShapeBorder? cardShape = theme.cardTheme.shape;
            Border? border;
            Color? color;
            final preferencesPalette = theme.extension<PreferencesExtension>()!;
            if (amiibo.wishlist) {
              color = preferencesPalette.wishContainer;
            } else if (amiibo.owned) {
              color = preferencesPalette.ownContainer;
            }
            if (select.selected) {
              final side = BorderSide(
                color: ElevationOverlay.applySurfaceTint(
                  theme.colorScheme.secondary,
                  theme.cardTheme.surfaceTintColor,
                  12.0,
                ),
                width: 4.0,
              );
              border = Border(left: side, right: side, top: side);
              cardShape =
                  cardShape == null ? cardShape ?? border : border + cardShape;
            }

            final hasAttribute = amiibo.wishlist || amiibo.owned;

            return Card(
              elevation: hasAttribute ? 12.0 : 6.0,
              color: hasAttribute ? color : theme.scaffoldBackgroundColor,
              shadowColor: Colors.black12,
              borderOnForeground: true,
              clipBehavior: Clip.antiAlias,
              shape: cardShape,
              child: InkWell(
                splashColor: theme.colorScheme.tertiaryContainer,
                splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
                onDoubleTap: select.activated || widget.ignore
                    ? null
                    : () => _onDoubleTap(key),
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
                                colorFilter:
                                    ColorFilter.mode(color, BlendMode.srcIn),
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
                      margin: EdgeInsets.zero,
                      color: select.selected
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.surfaceVariant,
                      elevation: 12.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          bottom: 2.0,
                        ),
                        child: Text(
                          amiibo.name,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: theme.primaryTextTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: select.selected
                                ? theme.colorScheme.onSecondary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}
