import 'package:amiibo_network/affiliation_product/presentation/controller/amazon_afilliation_provider.dart';
import 'package:amiibo_network/affiliation_product/presentation/widget/amazon_affiliation_link_selection_bottomsheet.dart';
import 'package:amiibo_network/resources/resources.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:url_launcher/url_launcher.dart';

/// Amazon branding color
const amazonColor = Color(0xFFFF9900);

class AmazonAffiliationButton extends HookConsumerWidget {
  const AmazonAffiliationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const amazonColor = Color(0xFFFF9900);
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((state) {
          final color = ElevatedButtonTheme.of(context)
              .style
              ?.backgroundColor
              ?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.75,
            );
            return Color(value);
          }
          return color;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((state) {
          final color = ElevatedButtonTheme.of(context)
              .style
              ?.foregroundColor
              ?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.5,
            );
            return Color(value);
          }
          return color;
        }),
      ),
      onPressed: () {},
      icon: ImageIcon(AssetImage(NetworkIcons.amazon)),
      label: Text('Buy in Amazon'),
    );
  }
}

class AmazonAffiliationIconButton extends HookConsumerWidget {
  const AmazonAffiliationIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(keyAmiiboProvider);
    final asyncSelected = ref.watch(
      selectedAmazonAffiliationDetailProvider(key: id),
    );
    final list = asyncSelected.valueOrNull;
    final hide = list == null || list.isEmpty;
    if (hide) {
      return const SizedBox();
    }
    final style = ElevatedButtonTheme.of(context).style;
    return IconButton.filledTonal(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((state) {
          final color = style?.backgroundColor?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.15,
            );
            return Color(value);
          }
          return color;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((state) {
          final color = style?.foregroundColor?.resolve(state);
          if (color != null) {
            final int value = Blend.hctHue(
              color.value,
              amazonColor.value,
              0.25,
            );
            return Color(value);
          }
          return color;
        }),
      ),
      onPressed: () async {
        final preferences = ref.read(personalProvider);
        final country = preferences.amazonCountryCode;
        Uri? uri;
        if (list.length == 1) {
          uri = list.first.link;
        } else if (country != null) {
          uri = list.firstWhere((a) => a.countryCode == country).link;
        }
        if (uri == null) {
          final result = await amazonLinkBottomSheet(
            context,
            showSelected: false,
            affiliations: list,
          );
          if (result == null || result.result == null) {
            return;
          } else {
            uri = result.result!.link;
          }
        }
        final inAppBrowser = preferences.inAppBrowser;
        await launchUrl(
          uri,
          mode: inAppBrowser
              ? LaunchMode.inAppBrowserView
              : LaunchMode.externalApplication,
        );
      },
      icon: ImageIcon(AssetImage(NetworkIcons.amazon)),
    );
  }
}
