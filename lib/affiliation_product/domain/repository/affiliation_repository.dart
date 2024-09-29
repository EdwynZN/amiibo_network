import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link_read_model.dart';

abstract interface class AffiliationRepository {
  Future<List<AffiliationLinkReadModel>> links();
}
