import 'package:amiibo_network/shared/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart' as d;
import 'package:amiibo_network/shared/data/local_file_source/model/amiibo_bundle_local_json_model.dart';
import 'package:drift/drift.dart';

AmiiboTable dataFromDomain(d.Amiibo amiibo) {
  final details = amiibo.details;
  return AmiiboTable(
    key: amiibo.key,
    id: details.id,
    name: details.name,
    character: details.character,
    gameSeries: details.gameSeries,
    amiiboSeries: details.amiiboSeries,
    type: details.type,
    na: details.na,
    au: details.au,
    eu: details.eu,
    jp: details.jp,
    cardNumber: details.cardNumber,
  );
}

AmiiboUserPreferencesCompanion preferencesFromDomain(d.Amiibo amiibo) {
  return AmiiboUserPreferencesCompanion(amiiboKey: Value(amiibo.key));
}

AmiiboBundleTable dataFromBundleLocal(AmiiboBundleLocalFile file) {
  return AmiiboBundleTable(id: file.id, name: file.name);
}

List<AmiiboBundleRelationCompanion> relationFromBundleLocal(
  AmiiboBundleLocalFile file,
) {
  return file.amiibos.map((e) {
    return AmiiboBundleRelationCompanion.insert(
      amiiboKey: e.amiiboId,
      amiiboBundleId: file.id,
      quantity: Value(e.quantity),
    );
  }).toList();
}
