import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:http/testing.dart';
import 'dart:convert';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.

mixin SingleHTTPCall implements MockClient{
  Future<int> getResponse(String request) async{
    final response = null;//await client.get(url + request);
    switch(response.statusCode){
      case 200:
        return response.statusCode;
        break;
      case 404:
        throw Exception('Failed to load amiibos');
        break;
      default:
        throw Exception('Failed to coneect');
        break;
    }
  }
}

main() {
  test('HTTP Test', () async {
    var client = MockClient((request) async {
      if (request.url.path != "/data.json") {
        return http.Response("", 404);
      }
      return http.Response(
          json.encode({'numbers': [1, 4, 15, 19, 214]}),
          200,
          headers: {'content-type': 'application/json'});

    });

    final response = await client.get('/dta.json');
    print(response.statusCode);
  });

}
