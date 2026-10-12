import 'dart:math';

import 'package:amiibo_network/app/state/collection/amiibo_user_collection_notifier.dart';
import 'package:amiibo_network/app/state/lock_provider.dart';
import 'package:amiibo_network/app/state/preferences_provider.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';
import 'package:amiibo_network/page/home/widget/empty_home_widget.dart';
import 'package:amiibo_network/page/home/widget/home_tile_widget.dart';
import 'package:amiibo_network/shared/utils/amiibo_asset_util.dart';
import 'package:amiibo_network/shared/utils/gap_helper.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class const HomeListBody({final ScrollController? scrollController, super.key})
    extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amiiboList = ref.watch(amiiboUserCollectionProvider);
    //final AsyncValue<List<AmiiboInfo>> amiiboList = const .loading();

    final Widget child;
    bool isLoading = false;

    switch (amiiboList) {
      case AsyncLoading(:final value?) when value.isNotEmpty:
      case AsyncData(:final value, :final isLoading)
          when value.isNotEmpty || !isLoading:
        if (value.isEmpty) {
          child = const EmptyHome();
          break;
        }
        final ignore = ref.watch(lockProvider);
        final useGrid = ref.watch(personalProvider.select((p) => p.useGrid));
        if (!useGrid) {
          child = SliverList(
            key: const ValueKey('List'),
            delegate: SliverChildBuilderDelegate(
              (_, index) => _AnimatedListTile(
                scrollController: scrollController,
                value[index],
                ignore,
              ),
              childCount: value.length,
            ),
          );
          break;
        }

        const grid = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          childAspectRatio: .7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        );
        child = SliverPadding(
          padding: horizontalPadding8,
          sliver: SliverGrid(
            key: const ValueKey('Grid'),
            gridDelegate: grid,
            delegate: SliverChildBuilderDelegate(
              (_, index) => _AnimatedGridTile(
                scrollController: scrollController,
                value[index],
                ignore,
              ),
              childCount: value.length,
            ),
          ),
        );

      case AsyncData():
      case AsyncLoading():
        isLoading = true;
        final useGrid = ref.watch(personalProvider.select((p) => p.useGrid));
        if (!useGrid) {
          child = SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => Padding(
                padding: const .all(4),
                child: Bone.square(size: 100, uniRadius: 12),
              ),
              childCount: 60,
            ),
          );
          break;
        }

        const grid = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          childAspectRatio: .7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        );
        child = SliverPadding(
          padding: horizontalPadding8,
          sliver: SliverGrid(
            gridDelegate: grid,
            delegate: SliverChildBuilderDelegate(
              (_, index) => const _LoadingTile(),
              childCount: 60,
            ),
          ),
        );
      case AsyncError():
        child = const SliverToBoxAdapter();
    }

    return SliverSkeletonizer(enabled: isLoading, child: child);
  }
}

class const _AnimatedListTile(
  final AmiiboInfo amiibo,
  final bool ignore, {
  final ScrollController? scrollController,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const .new(milliseconds: 600),
      child: AnimatedSelectedListTile(
        key: ValueKey(amiibo.id),
        amiibo: amiibo,
        ignore: ignore,
      ),
    );
  }
}

class const _AnimatedGridTile(
  final AmiiboInfo amiibo,
  final bool ignore, {
  final ScrollController? scrollController,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const .new(milliseconds: 600),
      child: AnimatedSelection(
        key: ValueKey(amiibo.id),
        amiibo: amiibo,
        ignore: ignore,
      ),
    );
  }
}

class const _LoadingTile() extends HookWidget {
  static final random = Random();

  @override
  Widget build(BuildContext context) {
    final int id = useMemoized(() => random.nextInt(70) + 1);
    return Card(
      margin: .zero,
      clipBehavior: .antiAlias,
      child: Column(
        mainAxisAlignment: .end,
        textBaseline: .alphabetic,
        children: [
          Flexible(
            child: Padding(
              padding: const .all(4.0),
              child: Skeleton.shade(
                child: Image.asset(
                  amiiboAssetFromIndex(id),
                  color: Colors.black,
                  colorBlendMode: .modulate,
                  fit: .contain,
                  alignment: .bottomCenter,
                ),
              ),
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
