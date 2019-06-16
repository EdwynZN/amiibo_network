import 'dart:async';
import 'package:http/http.dart' as http;
import '../model/amiibo.dart';

mixin _SingleHTTPCall{
  Future<String> getBodyResponse(String url, [int time = 10]) async{
    final response = await http.get(url).timeout(Duration(seconds: time));
    if(response.statusCode == 200) return response.body;
    else throw Exception('Failed to connect to amiiboAPI');
  }
}

class AmiiboApiProvider with _SingleHTTPCall{
  static String url = 'https://www.amiiboapi.com/api/';

  Future<AmiiboClient> fetchAllAmiibo() async {
    final amiibos = await getBodyResponse("${url}amiibo");
    return clientFromJson(amiibos);
  }

  Future<AmiiboClient> fetchAmiiboById(String id) async {
    final amiibos = await getBodyResponse("${url}amiibo/?id=$id");
    return clientFromJson(amiibos);
  }

  Future<AmiiboClient> fetchAmiiboByName(String name) async {
    final amiibos = await getBodyResponse("${url}amiibo/?name=$name");
    return clientFromJson(amiibos);
  }

  Future<AmiiboClient> fetchAmiiboByType(String type) async {
    final amiibos = await getBodyResponse("${url}amiibo/?type:$type");
    return clientFromJson(amiibos);
  }

  Future<AmiiboClient> fetchAmiiboByGameSeries(String game) async {
    final amiibos = await getBodyResponse("${url}amiibo/?gameseries=$game");
    return clientFromJson(amiibos);
  }

  Future<AmiiboClient> fetchAmiiboByAmiiboSeries(String amiibo) async {
    final amiibos = await getBodyResponse("${url}amiibo/?amiiboSeries=$amiibo");
    return clientFromJson(amiibos);
  }

  Future<AmiiboClient> fetchAmiiboByCharacter(String character) async {
    final amiibos = await getBodyResponse("${url}amiibo/?character=$character");
    return clientFromJson(amiibos);
  }

  Future<LastUpdate> fetchLastUpdate() async {
    final lastUpdate = await getBodyResponse("${url}lastupdated", 3);
    return lastUpdateFromJson(lastUpdate);
  }
}