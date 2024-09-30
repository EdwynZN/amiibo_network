import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link_read_model.dart';
import 'package:amiibo_network/affiliation_product/presentation/controller/amazon_afilliation_provider.dart';
import 'package:amiibo_network/generated/l10n.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:amiibo_network/utils/result_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

Future<ResultWrapper<AffiliationLinkReadModel?>?> amazonLinkBottomSheet(
  BuildContext context, {
  required bool showSelected,
  List<AffiliationLinkReadModel>? affiliations,
}) async {
  return showModalBottomSheet<ResultWrapper<AffiliationLinkReadModel?>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    clipBehavior: Clip.hardEdge,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.75,
      minChildSize: 0.25,
      initialChildSize: 0.5,
      snap: true,
      snapSizes: [0.5, 0.75],
      builder: (context, scrollController) => _AmazonSiteDraggableSheet(
        controller: scrollController,
        showSelected: showSelected,
        affiliations: affiliations,
      ),
    ),
  );
}

class _AmazonSiteDraggableSheet extends ConsumerWidget {
  final bool showSelected;
  final ScrollController controller;
  final List<AffiliationLinkReadModel>? affiliations;

  const _AmazonSiteDraggableSheet({
    // ignore: unused_element
    super.key,
    required this.controller,
    required this.showSelected,
    this.affiliations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = S.of(context);
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.secondary;
    final shape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      side: BorderSide(color: borderColor),
    );
    final selected = showSelected
        ? ref.watch(
            personalProvider.select((p) => p.amazonCountryCode),
          )
        : null;

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          title: Text(translate.amazon_link_setting),
          centerTitle: true,
          pinned: true,
          titleTextStyle: theme.textTheme.titleLarge,
        ),
        if (showSelected) ...[
          const SliverGap(4.0),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverToBoxAdapter(
              child: ListTile(
                selected: selected == null,
                shape: shape,
                onTap: () => Navigator.pop(
                  context,
                  ResultWrapper<AffiliationLinkReadModel?>(result: null),
                ),
                title: Text(
                  translate.no_link_selected,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(translate.no_link_selected_subtitle),
              ),
            ),
          ),
        ],
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          sliver: Consumer(
            builder: (context, ref, _) {
              final code = Localizations.localeOf(context).languageCode;
              final list = affiliations != null
                  ? AsyncData(affiliations!)
                  : ref.watch(amazonAffiliationProvider);
              return SliverAnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: list.when(
                  data: (data) {
                    return SliverList.separated(
                      separatorBuilder: (context, index) => const Gap(8.0),
                      itemBuilder: (context, index) {
                        final affiliation = data[index];
                        return ListTile(
                          selected: showSelected
                              ? selected == affiliation.countryCode
                              : false,
                          shape: shape,
                          onTap: () => Navigator.pop(
                            context,
                            ResultWrapper<AffiliationLinkReadModel?>(
                              result: affiliation,
                            ),
                          ),
                          title: Text(
                            affiliation.countryName.localization(code),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            Uri(
                              host: affiliation.link.host,
                              scheme: affiliation.link.scheme,
                            ).toString(),
                          ),
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
  }
}
