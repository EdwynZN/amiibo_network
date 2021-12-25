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

class SearchScreen extends StatefulHookConsumerWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static final RegExp _regAllowList = RegExp(r'^[A-Za-zÀ-ÿ0-9 .\-\&]*$');
  late S translate;

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    translate = S.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final _textController = useTextEditingController();
    final amiiboCategory = ref.watch(querySearchProvider
        .select<String>((value) => value.search ?? describeEnum(value.category)));
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverFloatingBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    category: ref.read(categorySearchProvider.state).state,
                  ),
                ),
                style: Theme.of(context).textTheme.headline4,
                autocorrect: false,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: translate.category(amiiboCategory),
                  hintStyle: Theme.of(context).textTheme.headline4!.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .headline4!
                            .color!
                            .withOpacity(0.5),
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
                            onPressed: () => _textController.clear(),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6.0),
              sliver: _Suggestions(
                textEditingController: _textController,
              ),
            ),
          ],
        ),
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
  final TextEditingController? textEditingController;
  const _Suggestions({
    Key? key,
    this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = _useDebouncedSearch(textEditingController!);
    final suggestions = ref.watch(searchProvider(search));
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return suggestions.maybeWhen(
            data: (data) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Card(
                  key: Key(data[index]),
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(),
                  child: ListTile(
                    onTap: () => Navigator.of(context).pop(
                      Search(
                        search: data[index],
                        category: ref.read(categorySearchProvider.state).state,
                      ),
                    ),
                    title: Text('${data[index]}'),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        },
        childCount: suggestions.asData?.value.length ?? 10,
      ),
    );
  }
}

class _SliverPersistentHeader extends SliverPersistentHeaderDelegate {
  const _SliverPersistentHeader();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Color _color = Theme.of(context).scaffoldBackgroundColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0.3,
              0.6,
              0.9
            ],
            colors: [
              _color,
              _color.withOpacity(0.85),
              _color.withOpacity(0.2),
            ]),
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
    _accentColor = theme.colorScheme.secondary;
    _accentTextThemeColor = theme.colorScheme.onSecondary;
    super.didChangeDependencies();
  }

  void _selectCategory(WidgetRef ref, AmiiboCategory category) {
    final _search = ref.read(categorySearchProvider.state);
    if (_search.state == category) return;
    _search.state = category;
  }

  @override
  Widget build(BuildContext context) {
    final _search = ref.watch(categorySearchProvider.state).state;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                primary: _search == AmiiboCategory.Name
                    ? _accentTextThemeColor
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(8)),
                ),
                backgroundColor:
                    _search == AmiiboCategory.Name ? _accentColor : null),
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
                    primary: _accentTextThemeColor,
                    backgroundColor: _accentColor)
                : null,
            onPressed: () => _selectCategory(ref, AmiiboCategory.Game),
            icon: const Icon(
              Icons.games,
              size: _iconSize,
            ),
            label:FittedBox(
              child: Text(translate.category(AmiiboCategory.Game)),
            ),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
                primary: _search == AmiiboCategory.AmiiboSeries
                    ? _accentTextThemeColor
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(8)),
                ),
                backgroundColor: _search == AmiiboCategory.AmiiboSeries
                    ? _accentColor
                    : null),
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
