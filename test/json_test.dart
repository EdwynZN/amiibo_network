import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'dart:io';

main() {
  test('convert json Test', () async {
    final file = File('assets/databases/amiibos.json');
    String data = file.readAsStringSync();
    final jResult = jsonDecode(data);
    AmiiboLocalDB amiibos = AmiiboLocalDB.fromJson(jResult);
    jsonEncode(amiibos);
    //LastUpdateDB lUpdate = LastUpdateDB.fromMap(jResult);
    //print(lUpdate.lastUpdated);
    print(amiibos.amiibo[0].toMap());
  });

}