import 'dart:async';
import 'package:amiibo_network/model/search_result.dart';
import 'package:amiibo_network/riverpod/query_provider.dart';
import 'package:amiibo_network/riverpod/search_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amiibo_network/widget/floating_bar.dart';
import 'package:amiibo_network/enum/amiibo_category_enum.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchScreen extends HookConsumerWidget {
  static final RegExp _regAllowList = RegExp(r'^[A-Za-zÀ-ÿ0-9 .\-\&]*$');

  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headline4;
    final translate = S.of(context);
    final _textController = useTextEditingController();
    final amiiboCategory = ref.watch(
      querySearchProvider.select<String>(
        (value) => value.search ?? describeEnum(value.category),
      ),
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverFloatingBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            pinned: true,
            leading: IconButton(
              icon: Hero(
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return AnimatedIcon(
                    icon: AnimatedIcons.menu_arrow,
                    progress: animation,
                  );
                },
                tag: 'MenuButton',
                child: const BackButtonIcon(),
              ),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: Navigator.of(context).pop,
            ),
            title: TextField(
              controller: _textController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(25),
                FilteringTextInputFormatter.allow(_regAllowList),
              ],
              textInputAction: TextInputAction.search,
              autofocus: true,
              onSubmitted: (text) => Navigator.of(context).pop(
                Search(
                  search: text,
                  category: ref.read(categorySearchProvider.notifier).state,
                ),
              ),
              style: style,
              autocorrect: false,
              decoration: InputDecoration(
                isDense: true,
                hintText: translate.category(amiiboCategory),
                hintStyle: style?.copyWith(
                  color: style.color?.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
            ),
            trailing: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _textController,
              child: const SizedBox(),
              builder: (context, text, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: text.text.isEmpty
                      ? child
                      : IconButton(
                          highlightColor: Colors.transparent,
                          icon: const Icon(Icons.close),
                          onPressed: _textController.clear,
                          tooltip: 'Clear',
                        ),
                );
              },
            ),
          ),
          const SliverPersistentHeader(
            delegate: _SliverPersistentHeader(),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6.0,
            ),
            sliver: _Suggestions(textEditingController: _textController),
          ),
        ],
      ),
    );
  }
}

String _useDebouncedSearch(TextEditingController textEditingController) {
  final search = useState(textEditingController.text);
  useEffect(() {
    Timer? timer;
    void listener() {
      timer?.cancel();
      timer = Timer(
        const Duration(milliseconds: 200),
        () => search.value = textEditingController.text,
      );
    }

    textEditingController.addListener(listener);
    return () {
      timer?.cancel();
      textEditingController.removeListener(listener);
    };
  }, [textEditingController]);

  return search.value;
}

class _Suggestions extends HookConsumerWidget {
  final TextEditingController textEditingController;

  const _Suggestions({
    Key? key,
    required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = _useDebouncedSearch(textEditingController);
    final suggestions = ref.watch(searchProvider(search));
    final List<String>? data = suggestions.maybeWhen(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (data) => data,
      orElse: () => null,
    );
    final count = data?.length ?? 10;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (data == null) {
            return const SizedBox.shrink();
          }
          final RoundedRectangleBorder shape;
          if (index == 0) {
            shape = const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.0),
              ),
            );
          } else if (index == count - 1) {
            shape = const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12.0),
              ),
            );
          } else {
            shape = const RoundedRectangleBorder();
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Card(
              key: Key(data[index]),
              margin: const EdgeInsets.only(bottom: 1.5),
              shape: shape,
              child: ListTile(
                onTap: () => Navigator.of(context).pop(
                  Search(
                    search: data[index],
                    category: ref.read(categorySearchProvider.notifier).state,
                  ),
                ),
                title: Text('${data[index]}'),
              ),
            ),
          );
        },
        childCount: count,
      ),
    );
  }
}

class _SliverPersistentHeader extends SliverPersistentHeaderDelegate {
  const _SliverPersistentHeader();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final appbarTheme = AppBarTheme.of(context);
    final _elevation = appbarTheme.elevation ?? 0.0;
    final firstColor = appbarTheme.backgroundColor ?? Colors.white;
    final bool isScrolledUnder =
        overlapsContent || shrinkOffset > maxExtent - minExtent;
    final Color _color = ElevationOverlay.applySurfaceTint(
      firstColor,
      appbarTheme.surfaceTintColor,
      isScrolledUnder ?
        _elevation * 2.0 > 4.0 ? _elevation * 2.0 : 4.0
        : _elevation,
    );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.3, 0.6, 0.9],
          colors: [
            _color,
            _color.withOpacity(0.85),
            _color.withOpacity(0.2),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: maxExtent,
      child: const CategoryControl(),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) =>
      maxExtent != oldDelegate.maxExtent || minExtent != oldDelegate.minExtent;
}

class CategoryControl extends StatefulHookConsumerWidget {
  const CategoryControl({Key? key}) : super(key: key);

  @override
  _CategoryControlState createState() => _CategoryControlState();
}

class _CategoryControlState extends ConsumerState<CategoryControl> {
  static const double _iconSize = 20.0;
  Color? _accentColor, _accentTextThemeColor;
  late S translate;

  @override
  void didChangeDependencies() {
    translate = S.of(context);
    final ThemeData theme = Theme.of(context);
    _accentColor = theme.colorScheme.secondaryContainer;
    _accentTextThemeColor = theme.colorScheme.onSecondaryContainer;
    super.didChangeDependencies();
  }

  void _selectCategory(WidgetRef ref, AmiiboCategory category) {
    final _search = ref.read(categorySearchProvider.notifier);
    if (_search.state == category) return;
    _search.state = category;
  }

  @override
  Widget build(BuildContext context) {
    final _search = ref.watch(categorySearchProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor:
                  _search == AmiiboCategory.Name ? _accentTextThemeColor : null,
              shape: RoundedRectangleBorder(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16.0)),
              ),
              backgroundColor:
                  _search == AmiiboCategory.Name ? _accentColor : null,
            ),
            onPressed: () => _selectCategory(ref, AmiiboCategory.Name),
            icon: const Icon(
              Icons.group,
              size: _iconSize,
            ),
            label: FittedBox(
              child: Text(translate.category(AmiiboCategory.Name)),
            ),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            style: _search == AmiiboCategory.Game
                ? OutlinedButton.styleFrom(
                    foregroundColor: _accentTextThemeColor,
                    backgroundColor: _accentColor,
                  )
                : null,
            onPressed: () => _selectCategory(ref, AmiiboCategory.Game),
            icon: const Icon(
              Icons.games,
              size: _iconSize,
            ),
            label: FittedBox(
              child: Text(translate.category(AmiiboCategory.Game)),
            ),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _search == AmiiboCategory.AmiiboSeries
                  ? _accentTextThemeColor
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(16.0)),
              ),
              backgroundColor:
                  _search == AmiiboCategory.AmiiboSeries ? _accentColor : null,
            ),
            onPressed: () => _selectCategory(ref, AmiiboCategory.AmiiboSeries),
            icon: const Icon(
              Icons.nfc,
              size: _iconSize,
            ),
            label: FittedBox(
              child: Text(translate.category(AmiiboCategory.AmiiboSeries)),
            ),
          ),
        ),
      ],
    );
  }
}
