import 'dart:convert' as convert;
import 'dart:developer';

import 'package:http/http.dart' as http;

class LandingPageService {
  var headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};
  var request = http.Request(
      'GET',
      Uri.parse(
          'https://api.myanimelist.net/v2/anime?q=one&limit=500&order_by=id&sort=asc'));

  Future<Map<String, dynamic>> getAnimeList() async {
    request.headers.addAll(headers);

    http.StreamedResponse streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      var response = await http.Response.fromStream(streamedResponse);
      Map<String, dynamic> jsonResponse = convert.json.decode(response.body);

      log('jsonResponse: $jsonResponse');

      return jsonResponse;
    } else {
      return {'Error': streamedResponse.reasonPhrase};
    }
  }
}
