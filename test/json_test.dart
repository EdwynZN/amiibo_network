import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:amiibo_network/model/amiibo.dart';
import 'dart:io';

main() {
  test('convert json Test', () async {
    final file = File('assets/databases/amiibos.json');
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    List<Amiibo> amiibos = entityFromMap(jResult);

    //print(amiibos.amiibo[2]);
    final writeFile = File('assets/databases/test.json');
    writeFile.writeAsStringSync(jsonEncode(amiibos));
    //LastUpdateDB lUpdate = LastUpdateDB.fromMap(jResult);
    //print(lUpdate.lastUpdated);
    //print(amiibos);
  });
}