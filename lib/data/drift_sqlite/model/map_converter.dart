import 'package:amiibo_network/data/drift_sqlite/source/drift_database.dart';
import 'package:amiibo_network/model/amiibo.dart' as d;
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
  return AmiiboUserPreferencesCompanion(
    amiiboKey: Value(amiibo.key),
  );
}
