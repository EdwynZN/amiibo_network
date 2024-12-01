import 'package:amiibo_network/affiliation_product/data/affiliation_repository_local.dart';
import 'package:amiibo_network/affiliation_product/domain/failure/affiliation_failure.dart';
import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link_read_model.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:amiibo_network/riverpod/preferences_provider.dart';
import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amazon_afilliation_provider.g.dart';

const _kAmazonTag = String.fromEnvironment('amazon_tag');

@Riverpod(keepAlive: true)
Future<List<AffiliationLinkReadModel>> amazonAffiliation(Ref ref) {
  final repo = ref.watch(affiliationRepositoryProvider);
  return repo.links();
}

@riverpod
AffiliationLinkReadModel? selectedAmazonAffiliation(Ref ref) {
  final countryCode = ref.watch(
    personalProvider.select((p) => p.amazonCountryCode),
  );
  return ref.watch(amazonAffiliationProvider).maybeWhen(
        skipError: true,
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        data: (data) {
          final selected =
              data.firstWhereOrNull((a) => a.countryCode == countryCode);
          if (selected != null) {
            return selected;
          }
          return null;
        },
        orElse: () => null,
      );
}

@riverpod
Future<List<AffiliationLinkReadModel>> selectedAmazonAffiliationDetail(
  Ref ref, {
  required int key,
}) async {
  if (_kAmazonTag.isEmpty) {
    throw const NoAffiliationTag();
  }
  final String? search = await ref.watch(
    detailAmiiboProvider(key).selectAsync(
      (value) {
        if (value == null) {
          return null;
        }
        final detail = value.details;
        return '${detail.name} Amiibo ${detail.type} ${detail.gameSeries}';
      },
    ),
  );
  if (search == null) {
    throw NoAmiiboFound(key);
  }

  AffiliationLinkReadModel replaceUri(AffiliationLinkReadModel affiliation) {
    final uri = affiliation.link.replace(
      path: '/s',
      queryParameters: {'k': search, 'tag': _kAmazonTag},
    );
    return affiliation.copyWith(link: uri);
  }

  final selected = ref.watch(selectedAmazonAffiliationProvider);
  if (selected != null) {
    return [replaceUri(selected)];
  }

  final list = await ref.watch(amazonAffiliationProvider.future);
  return list.map(replaceUri).toList();
}
