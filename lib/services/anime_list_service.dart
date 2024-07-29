import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:otaku_tracker/models/response/anime.dart';

class AnimeListService {
  final headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};

  Future<Anime> getAnimeList() async {
    final request = http.Request(
      'GET',
      Uri.parse(
          'https://api.myanimelist.net/v2/anime?q=one&limit=500&order_by=id&sort=asc'),
    );
    request.headers.addAll(headers);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = convert.json.decode(response.body);

      final fromJson = Anime.fromJson(jsonResponse);

      return fromJson;
    } else {
      throw Exception(
          'Failed to load anime list: ${streamedResponse.reasonPhrase}');
    }
  }
}
