import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:amiibo_network/entity/amiibo_info/model/amiibo.dart';
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
  test('convert image json Test', () async {
    final file = File('assets/databases/amiibos.json');
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    final lenght = (jResult['amiibo'] as List).length;

    final now = DateTime.now().millisecondsSinceEpoch;
    final amiibos = <Map<String, dynamic>>[
      for (int i = 1; i <= lenght; i++)
        {
          "amiibo_key": i,
          "created_at": now,
          "file_path": "assets/collection/icon_$i.webp",
        },
    ];
    final images = {"bundles": [], "amiibos": amiibos};

    //print(amiibos.amiibo[2]);
    final writeFile = File('assets/databases/images_test.json');
    writeFile.writeAsStringSync(jsonEncode(images));
    //LastUpdateDB lUpdate = LastUpdateDB.fromMap(jResult);
    //print(lUpdate.lastUpdated);
    //print(amiibos);
  });
}
