import 'package:amiibo_network/affiliation_product/presentation/controller/amazon_afilliation_provider.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

Future<void> amazonLinkBottomSheet(
  BuildContext context,
) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    clipBehavior: Clip.hardEdge,
    builder: (context) => const _AmazonSiteDraggableSheet(),
  );
}

class _AmazonSiteDraggableSheet extends StatelessWidget {
  // ignore: unused_element
  const _AmazonSiteDraggableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, scrollController) {
        final translate = S.of(context);
        final borderColor = Theme.of(context).colorScheme.secondary;
        final shape = RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: borderColor),
        );
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text(S.of(context).amazon_link_setting),
              centerTitle: true,
              pinned: true,
              titleTextStyle: Theme.of(context).textTheme.titleLarge,
            ),
            const SliverGap(4.0),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: ListTile(
                  selected: false,
                  shape: shape,
                  onTap: () => Navigator.pop(context, null),
                  title: Text(
                    translate.no_link_selected,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(translate.no_link_selected_subtitle),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              sliver: Consumer(
                builder: (context, ref, _) {
                  final code = Localizations.localeOf(context).languageCode;
                  final list = ref.watch(amazonAffiliationProvider);
                  return SliverAnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: list.when(
                      data: (data) {
                        return SliverList.separated(
                          separatorBuilder: (context, index) => const Gap(8.0),
                          itemBuilder: (context, index) {
                            final affiliation = data[index];
                            return ListTile(
                              selected: false,
                              shape: shape,
                              onTap: () => Navigator.pop(
                                context,
                                affiliation.countryCode,
                              ),
                              title: Text(
                                affiliation.countryName.localization(code),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(affiliation.link.toString()),
                            );
                          },
                          itemCount: data.length,
                        );
                      },
                      loading: () => const SliverToBoxAdapter(
                        child: CircularProgressIndicator(),
                      ),
                      error: (_, __) => const SliverToBoxAdapter(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      expand: false,
      maxChildSize: 0.75,
      minChildSize: 0.25,
      initialChildSize: 0.5,
      snap: true,
      snapSizes: [0.5, 0.75],
    );
  }
}
