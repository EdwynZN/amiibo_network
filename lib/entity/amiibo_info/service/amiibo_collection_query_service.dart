import 'package:amiibo_network/app/configuration/model/search_result.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo_info.dart';

abstract interface class AmiiboCollectionQueryService {
  Future<List<AmiiboInfo>> fetchCollection({Filter? filter});
  Stream<List<AmiiboInfo>> fetchStreamCollection({Filter? filter});

  Future<AmiiboInfo?> fetchDetail({required int amiiboId});
  Stream<AmiiboInfo?> fetchStreamDetail({required int amiiboId});
}
