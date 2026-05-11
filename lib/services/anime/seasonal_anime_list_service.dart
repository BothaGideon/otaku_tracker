import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/services/anime/mal_api_cache_service.dart';

class SeasonalAnimeListService {
  static const _feedFields = 'mean,num_list_users,status';

  final MalApiCacheService cache;
  final headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};

  SeasonalAnimeListService({
    MalApiCacheService? cache,
  }) : cache = cache ?? MalApiCacheService(ttl: const Duration(minutes: 15));

  static String seasonPathSegment(SeasonType season) {
    return season.name;
  }

  static String buildSeasonalAnimeListUrl(
    int year,
    SeasonType season, {
    int limit = 100,
    int offset = 0,
    bool includeNsfw = false,
  }) {
    return 'https://api.myanimelist.net/v2/anime/season/$year/${seasonPathSegment(season)}?limit=$limit&offset=$offset&sort=anime_num_list_users&fields=$_feedFields&nsfw=$includeNsfw';
  }

  Future<AnimeDTO> getSeasonalAnimeList(
    int year,
    SeasonType season, {
    int limit = 100,
    int offset = 0,
    bool includeNsfw = false,
    bool forceRefresh = false,
  }) async {
    final url = buildSeasonalAnimeListUrl(
      year,
      season,
      limit: limit,
      offset: offset,
      includeNsfw: includeNsfw,
    );

    return _fetchSeasonalAnime(
      url: url,
      cacheKey:
          'seasonalAnime:$year:${season.name}:$limit:$offset:$includeNsfw',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> getSeasonalAnimeListByUrl(
    String url, {
    bool forceRefresh = false,
  }) async {
    return _fetchSeasonalAnime(
      url: url,
      cacheKey: 'seasonalAnimeNext:$url',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> _fetchSeasonalAnime({
    required String url,
    required String cacheKey,
    required bool forceRefresh,
  }) async {
    if (!forceRefresh) {
      final cachedValue = cache.get<AnimeDTO>(cacheKey);

      if (cachedValue != null) {
        return cachedValue;
      }
    }

    final request = http.Request(
      'GET',
      Uri.parse(url),
    );
    request.headers.addAll(headers);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse =
          convert.json.decode(response.body) as Map<String, dynamic>;
      final fromJson = AnimeDTO.fromJson(jsonResponse);
      cache.put(cacheKey, fromJson);

      return fromJson;
    } else {
      throw Exception(
          'Failed to load anime list: ${streamedResponse.reasonPhrase}');
    }
  }
}
