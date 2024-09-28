import 'package:amiibo_network/affiliation_product/data/affiliation_repository_local.dart';
import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link.dart';
import 'package:amiibo_network/riverpod/amiibo_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'amazon_afilliation_provider.g.dart';

const _kAmazonTag = String.fromEnvironment('amazon_tag', defaultValue: 'dartbot-420');

@Riverpod(keepAlive: true)
Future<List<AffiliationLink>> amazonAffiliation(AmazonAffiliationRef ref) {
  final repo = ref.watch(affiliationRepositoryProvider);
  return repo.links();
}

@riverpod
Future<List<AffiliationLink>?> selectedAmazonAffiliation(
  SelectedAmazonAffiliationRef ref, {
  required int key,
}) async {
  if (_kAmazonTag.isEmpty) {
    throw 'No Amazon Afiliation tag';
  }
  final (String name, String type, String serie)? data = await ref.watch(
    detailAmiiboProvider(key).selectAsync((value) => 
      value == null 
        ? null 
        : (value.details.name, value.details.type, value.details.gameSeries),
    ),
  );
  if (data == null) {
    throw 'No Amiibo related';
  }

  final list = await ref.watch(amazonAffiliationProvider.future);
  return list.map((a) {
    final uri = a.link.replace(
      path: '/s',
      queryParameters: {
        'k': '${data.$1} Amiibo ${data.$2} ${data.$3}',
        'tag': _kAmazonTag,
      },
    );
    return a.copyWith(link: uri);
  }).toList();
}
