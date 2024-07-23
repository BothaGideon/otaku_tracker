import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

import '../../models/response/anime_list.dart';

class LandingPageService {
  final headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};

  Future<AnimeList> getAnimeList() async {
    final request = http.Request(
      'GET',
      Uri.parse(
          'https://api.myanimelist.net/v2/anime?q=one&limit=500&order_by=id&sort=asc'),
    );
    request.headers.addAll(headers);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse =
          convert.json.decode(response.body) as Map<String, dynamic>;

      return AnimeList.fromJson(jsonResponse);
    } else {
      throw Exception(
          'Failed to load anime list: ${streamedResponse.reasonPhrase}');
    }
  }
}
