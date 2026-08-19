import 'package:amiibo_network/entity/affiliation_product/domain/repository/affiliation_repository.dart';
import 'package:amiibo_network/entity/affiliation_product/domain/model/affiliation_link_read_model.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/affiliation_link_dao.dart';
import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart'
    as db;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'affiliation_repository_local.g.dart';

@Riverpod(keepAlive: true)
AffiliationRepository affiliationRepository(Ref ref) {
  final appDB = ref.watch(db.databaseProvider);
  return AffiliationRepositoryLocal(appDB.affiliationLinkDao);
}

class AffiliationRepositoryLocal implements AffiliationRepository {
  AffiliationRepositoryLocal(this._affiliationLinkDao);

  final AffiliationLinkDao _affiliationLinkDao;

  @override
  Future<List<AffiliationLinkReadModel>> links() =>
      _affiliationLinkDao.getLinks();
}
