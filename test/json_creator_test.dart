import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:amiibo_network/model/amiibo_local_db.dart';
import 'package:amiibo_network/model/game.dart';
import 'dart:io';

main() {
  test('convert json Test', () async {
    final file = File('assets/databases/amiibos.json');
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    AmiiboLocalDB amiibos = AmiiboLocalDB.fromJson(jResult);
    Games game = Games(
      game: [
        Game(
          id: 0,
          platform: Platform.SWITCH,
          feature: 'R',
          description: 'Unlock a character-based costume',
          name: 'Yoshi\'s Crafted World',
          amiibo: <String>[],
        )
      ]
    );

    amiibos.amiibo.forEach((x){
      if(x.name.contains('Yoshi') ||
         x.name.contains('Bowser') ||
         x.name.contains('Mario') ||
         x.name.contains('Luigi') ||
         x.name.contains('Peach') ||
         x.name.contains('Toad') ||
         x.name.contains('Koopa Troopa')
      )
        game.game[0].amiibo.add(x.id);
    });
    print(gamesToJson(game));
    /*final writeFile = File('assets/databases/test.json');
    writeFile.writeAsStringSync(jsonEncode(game));*/
  });

  test('Rename collection png', () async {
    final file = File('assets/databases/amiibos.json');
    String data = file.readAsStringSync();
    final Map<String, dynamic> jResult = jsonDecode(data);
    AmiiboLocalDB amiibos = AmiiboLocalDB.fromJson(jResult);
    Games game = Games(
        game: [
          Game(
            id: 0,
            platform: Platform.SWITCH,
            feature: 'R',
            description: 'Unlock a character-based costume',
            name: 'Yoshi\'s Crafted World',
            amiibo: <String>[],
          )
        ]
    );

    amiibos.amiibo.forEach((x){
      final file = File('assets/collection/icon_${x.id?.substring(0,8)}-'
        '${x.id?.substring(8)}.png');
      file.rename('assets/collection/icon_${x.key}.png');
    });
    print(gamesToJson(game));

  });
}