import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/service/info_package.dart';
import 'package:drift/drift.dart';
import 'package:amiibo_network/affiliation_product/domain/model/affiliation_link_read_model.dart'
    as model;

part 'affiliation_link_dao.g.dart';

@DriftAccessor(include: const {'affiliation_tables.drift'})
class AffiliationLinkDao extends DatabaseAccessor<AppDatabase>
    with _$AffiliationLinkDaoMixin {
  AffiliationLinkDao(super.db);

  Future<void> saveCountries({required List<CountryTable> countries}) async {
    await batch((batch) {
      if (InfoPackage.instance.isUpsertFeatureAvailable) {
        batch.insertAllOnConflictUpdate(country, countries);
      } else {
        batch.insertAll(
          country,
          countries,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<model.AffiliationLinkReadModel>> getLinks() async {
    final query = select(affiliationLink).join(
      [
        leftOuterJoin(
          country,
          country.code.equalsExp(affiliationLink.countryCode),
        ),
      ],
    );
    return query
        .map((p0) => model.AffiliationLinkReadModel.fromDB(p0.rawData.data))
        .get();
  }

  Future<void> saveLinks({
    required List<AffiliationLinkCompanion> links,
  }) async {
    await batch((batch) {
      if (InfoPackage.instance.isUpsertFeatureAvailable) {
        for (final row in links) {
          batch.insert(
            affiliationLink,
            row,
            onConflict: DoUpdate(
              (_) => AffiliationLinkCompanion(amazon: row.amazon),
              target: [affiliationLink.countryCode],
            ),
          );
        }
        //batch.insertAllOnConflictUpdate(affiliationLink, links);
      } else {
        batch.insertAll(
          affiliationLink,
          links,
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}
