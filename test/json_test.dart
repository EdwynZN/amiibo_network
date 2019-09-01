import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'dart:io';

main() {
  test('convert json Test', () async {
    final file = File('assets/databases/amiibos.json');
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    AmiiboLocalDB amiibos = AmiiboLocalDB.fromJson(jResult);

    amiibos.amiibo.forEach((x){
      int id = int.parse(x.id.substring(8, 12), radix: 16);
      if(id > 67 && id < 168 && x.id.substring(12) == '0502')
        x.amiiboSeries = "Animal Crossing Series 1";
      else if(id > 167 && id < 268 && x.id.substring(12) == '0502')
        x.amiiboSeries = "Animal Crossing Series 2";
      else if(id > 267 && id < 368 && x.id.substring(12) == '0502')
        x.amiiboSeries = "Animal Crossing Series 3";
      else if(id > 367 && id < 468 && x.id.substring(12) == '0502')
        x.amiiboSeries = "Animal Crossing Series 4";
      else if(id > 742 && id < 793 && x.id.substring(12) == '0502')
        x.amiiboSeries = "Animal Crossing New Leaf Welcome";
    });
    //print(amiibos.amiibo[2]);
    final writeFile = File('assets/databases/test.json');
    writeFile.writeAsStringSync(jsonEncode(amiibos));
    //LastUpdateDB lUpdate = LastUpdateDB.fromMap(jResult);
    //print(lUpdate.lastUpdated);
    //print(amiibos);
  });
}