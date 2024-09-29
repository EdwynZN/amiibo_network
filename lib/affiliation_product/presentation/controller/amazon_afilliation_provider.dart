import 'package:amiibo_network/affiliation_product/data/affiliation_repository_local.dart';
import 'package:amiibo_network/affiliation_product/domain/failure/affiliation_failure.dart';
import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link_read_model.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amazon_afilliation_provider.g.dart';

const _kAmazonTag =
    String.fromEnvironment('amazon_tag', defaultValue: 'dartbot-420');

@Riverpod(keepAlive: true)
Future<List<AffiliationLinkReadModel>> amazonAffiliation(
  AmazonAffiliationRef ref,
) {
  final repo = ref.watch(affiliationRepositoryProvider);
  return repo.links();
}

@riverpod
Future<List<AffiliationLinkReadModel>> selectedAmazonAffiliation(
  SelectedAmazonAffiliationRef ref, {
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

  final list = await ref.watch(amazonAffiliationProvider.future);
  return list.map((a) {
    final uri = a.link.replace(
      path: '/s',
      queryParameters: {'k': search, 'tag': _kAmazonTag},
    );
    return a.copyWith(link: uri);
  }).toList();
}
