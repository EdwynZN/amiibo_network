import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link.dart';

abstract interface class AffiliationRepository {
  Future<List<AffiliationLink>> links();
}
