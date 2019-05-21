import 'dart:async';
import 'package:http/http.dart' show Client;
import '../model/amiibo.dart';

class AmiiboApiProvider {

  Future<AmiiboClient> fetchAllAmiibo() async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo");
      switch(response.statusCode){
        case 200:
          return clientFromJson(response.body);
          break;
        case 404:
          throw Exception('Failed to load amiibos');
          break;
        default:
          throw Exception('Failed to coneect');
          break;
      }
    } finally{
      client.close();
    }
  }

  Future<AmiiboClient> fetchAmiiboById(String id) async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo/?id=$id");
      switch(response.statusCode){
        case 200:
          return clientFromJson(response.body);
          break;
        case 404:
          throw Exception('Failed to load amiibos');
          break;
        default:
          throw Exception('Failed to coneect');
          break;
      }
    } finally{
      client.close();
    }
  }

  Future<AmiiboClient> fetchAmiiboByName(String name) async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo/?name=$name");
      switch(response.statusCode){
        case 200:
          return clientFromJson(response.body);
          break;
        case 404:
          throw Exception('Failed to load amiibos');
          break;
        default:
          throw Exception('Failed to coneect');
          break;
      }
    } finally{
      client.close();
    }
  }

  Future<AmiiboClient> fetchAmiiboByType(String type) async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo/?type:$type");
      if (response.statusCode == 200) {
        return clientFromJson(response.body);
      } else {
        throw Exception('Failed to load amiibos');
      }
    } finally{
      client.close();
    }
  }

  Future<AmiiboClient> fetchAmiiboByGameSeries(String game) async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo/?gameseries=$game");
      if (response.statusCode == 200) {
        return clientFromJson(response.body);
      } else {
        throw Exception('Failed to load amiibos');
      }
    } finally{
      client.close();
    }
  }

  Future<AmiiboClient> fetchAmiiboByAmiiboSeries(String amiibo) async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo/?amiiboSeries=$amiibo");
      if (response.statusCode == 200) {
        return clientFromJson(response.body);
      } else {
        throw Exception('Failed to load amiibos');
      }
    } finally{
      client.close();
    }
  }

  Future<AmiiboClient> fetchAmiiboByCharacter(String character) async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/amiibo/?character=$character");
      if (response.statusCode == 200) {
        return clientFromJson(response.body);
      } else {
        throw Exception('Failed to load amiibos');
      }
    } finally{
      client.close();
    }
  }

  Future<LastUpdate> fetchLastUpdate() async {
    final Client client = Client();
    try{
      final response = await client.get("https://www.amiiboapi.com/api/lastupdated");
      if (response.statusCode == 200) {
        return lastUpdateFromJson(response.body);
      } else {
        throw Exception('Failed to load Last Update date');
      }
    } finally{
      client.close();
    }
  }
}