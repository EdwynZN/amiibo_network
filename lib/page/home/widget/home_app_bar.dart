import 'package:amiibo_network/app/configuration/query_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/app/state/theme/service/theme_mode_scheme_repository.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_user_collection_attributes.dart';
import 'package:amiibo_network/page/detail/widget/owned_bottom_sheet.dart';
import 'package:amiibo_network/page/home/controller/select_provider.dart';
import 'package:amiibo_network/page/home/model/title_search.dart';
import 'package:amiibo_network/page/home/widget/amiibo_view_type_widget.dart';
import 'package:amiibo_network/page/home/widget/sort_bottomsheet.dart';
import 'package:amiibo_network/shared/generated/l10n.dart';
import 'package:amiibo_network/shared/widget/animated_widgets.dart';
import 'package:amiibo_network/shared/widget/dash_menu.dart';
import 'package:amiibo_network/shared/widget/floating_bar.dart';
import 'package:amiibo_network/template/lock_icon.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class const SliverHomeAppBar({
  required final bool isTablet,
  required final VoidCallback onSearch,
  required final VoidCallback onClose,
  super.key,
}) extends ConsumerWidget {
  static Widget _defaultLayoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    List<Widget> children = previousChildren;
    if (currentChild != null) children = [...children, currentChild];
    return Stack(children: children, alignment: Alignment.centerRight);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _multipleSelection = ref.watch(
      selectProvider.select((s) => s.isNotEmpty),
    );
    final trailing = _multipleSelection
        ? const _SelectedOptions()
        : _DefaultOptions(hasDrawer: !isTablet);
    return SliverFloatingBar(
      pinned: true,
      floating: true,
      forward: _multipleSelection,
      snap: true,
      leading: _Leading(isClose: _multipleSelection, onClose: onClose),
      title: const _TitleAppBar(),
      onTap: _multipleSelection ? null : onSearch,
      trailing: AnimatedSwitcher(
        duration: const .new(milliseconds: 250),
        layoutBuilder: _defaultLayoutBuilder,
        child: trailing,
      ),
      bottom: PreferredSize(preferredSize: .zero, child: const SizedBox()),
    );
  }
}

class _Leading({
  required final bool isClose,
  required final VoidCallback onClose,
}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = MaterialLocalizations.of(context);
    final searchSelect = ref.watch(
      queryProvider.select<bool>((q) => q.searchAttributes != null),
    );
    final isForward = searchSelect || isClose;
    final effectiveSearch = searchSelect && !isClose;
    final HeroFlightShuttleBuilder flightShuttleBuilder =
        useCallback<HeroFlightShuttleBuilder>((
          BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext,
        ) {
          if (isForward) {
            return AnimatedBuilder(
              animation: animation,
              child: flightDirection == HeroFlightDirection.push
                  ? const Icon(Icons.arrow_back)
                  : const Icon(Icons.close),
              builder: (context, child) {
                return Opacity(
                  opacity: flightDirection == HeroFlightDirection.push
                      ? animation.value
                      : 1 - animation.value,
                  child: child,
                );
              },
            );
          }

          return AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: animation,
          );
        }, [isForward]);
    final VoidCallback onPressed = useCallback(() {
      if (effectiveSearch) {
        ref.read(queryProvider.notifier).restart();
      } else if (isClose) {
        onClose();
      } else {
        final dashMenu = DashMenu.maybeOf(context);
        if (dashMenu != null) {
          dashMenu.openDrawer();
        } else {
          Scaffold.of(context).openDrawer();
        }
      }
    }, [effectiveSearch, isClose, onClose]);
    final icon = ImplicitIcon(key: const Key('Menu'), forward: isForward);
    return IconButton(
      icon: Hero(
        key: const Key('HeroMenu'),
        flightShuttleBuilder: flightShuttleBuilder,
        tag: 'MenuButton',
        child: icon,
      ),
      tooltip: effectiveSearch
          ? localizations.closeButtonTooltip
          : isClose
          ? localizations.cancelButtonLabel
          : localizations.openAppDrawerTooltip,
      onPressed: onPressed,
    );
  }
}

class const _DefaultOptions({required final bool hasDrawer})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .end,
      children: <Widget>[
        const LockButton(),
        const AmiiboViewTypeWidget(),
        const SortCollection(),
        if (hasDrawer)
          IconButton(
            onPressed: () => DashMenu.of(context).openRightDrawer(),
            tooltip: S.of(context).stats,
            icon: const Icon(Icons.auto_graph_outlined),
          ),
      ],
    );
  }
}

class const _TitleAppBar() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final S translate = S.of(context);
    final searchTitle = ref.watch(titleProvider);
    final Widget child;
    final InlineSpan title = TextSpan(
      text: translate.category(searchTitle.title),
    );
    InlineSpan? categorySpan;
    if (searchTitle is TitleSearchCategory) {
      final theme = Theme.of(context);
      final size = theme.appBarTheme.toolbarTextStyle?.fontSize;
      final foreground = theme.colorScheme.onSecondaryContainer;
      categorySpan = WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        baseline: TextBaseline.ideographic,
        child: Card(
          elevation: 12.0,
          margin: const EdgeInsets.only(right: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            side: BorderSide(color: theme.primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: size, color: foreground),
                const SizedBox(width: 2.0),
                Text(
                  translate.searchCategory(searchTitle.searchCategory),
                  style: TextStyle(fontSize: size, color: foreground),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final message = switch (searchTitle) {
      TitleCount(title: final title) => localizations.selectedRowCountTitle(
        num.parse(title) as int,
      ),
      TitleSearchCategory() => localizations.searchFieldLabel,
      TitleCategory(category: final category) => translate.category(category),
    };
    child = Text.rich(
      categorySpan != null ? TextSpan(children: [categorySpan, title]) : title,
    );
    return Tooltip(message: message, child: child);
  }
}

class const _SelectedOptions() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final S translate = S.of(context);
    return Row(
      mainAxisSize: .min,
      mainAxisAlignment: .end,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () =>
              ref.read(selectProvider.notifier).updateAmiibos(const .none()),
          tooltip: translate.removeTooltip,
        ),
        IconButton(
          icon: const Icon(iconOwned),
          onPressed: () async {
            final theme = Theme.of(context);
            final showOwnerCategories = ref.read(ownTypesCategoryProvider);
            final UserAttributes? newAttributes;
            if (showOwnerCategories) {
              newAttributes = await showModalBottomSheet<UserAttributes>(
                context: context,
                backgroundColor: theme.colorScheme.surface,
                useSafeArea: false,
                elevation: 4.0,
                enableDrag: false,
                constraints: const BoxConstraints(maxWidth: 400.0),
                isScrollControlled: true,
                builder: (context) => const OwnedButtomSheet(),
              );
            } else {
              newAttributes = UserAttributes.owned();
            }

            if (newAttributes == null) {
              return;
            }
            ref.read(selectProvider.notifier).updateAmiibos(newAttributes);
          },
          tooltip: translate.ownTooltip,
        ),
        IconButton(
          icon: const Icon(iconWished),
          onPressed: () => ref
              .read(selectProvider.notifier)
              .updateAmiibos(const UserAttributes.wished()),
          tooltip: translate.wishTooltip,
        ),
      ],
    );
  }
}
