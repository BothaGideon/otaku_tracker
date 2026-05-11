import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/services/anime/mal_api_cache_service.dart';
import 'package:otaku_tracker/services/telemetry/app_telemetry_service.dart';

class SeasonalAnimeListService {
  static const _feedFields = 'mean,num_list_users,status';

  final MalApiCacheService cache;
  final AppTelemetryService telemetry;
  final http.Client httpClient;
  final headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};

  SeasonalAnimeListService({
    MalApiCacheService? cache,
    AppTelemetryService? telemetry,
    http.Client? httpClient,
  })  : cache = cache ?? MalApiCacheService(ttl: const Duration(minutes: 15)),
        telemetry = telemetry ?? AppTelemetryService(),
        httpClient = httpClient ?? http.Client();

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
      operation: 'get_seasonal_anime_list',
      includeNsfw: includeNsfw,
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
      operation: 'get_seasonal_anime_list_next_page',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> _fetchSeasonalAnime({
    required String url,
    required String cacheKey,
    required String operation,
    bool? includeNsfw,
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

    http.StreamedResponse streamedResponse;

    try {
      streamedResponse = await httpClient.send(request);
    } catch (error, stackTrace) {
      await telemetry.trackMalApiFailure(
        operation: operation,
        endpoint: 'anime_season',
        method: 'GET',
        authenticated: false,
        includeNsfw: includeNsfw,
        reason: error.runtimeType.toString(),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse =
          convert.json.decode(response.body) as Map<String, dynamic>;
      final fromJson = AnimeDTO.fromJson(jsonResponse);
      cache.put(cacheKey, fromJson);

      return fromJson;
    } else {
      final response = await http.Response.fromStream(streamedResponse);
      final reason = _extractFailureReason(response.reasonPhrase, response.body);
      final exception = Exception('Failed to load anime list: $reason');

      await telemetry.trackMalApiFailure(
        operation: operation,
        endpoint: 'anime_season',
        method: 'GET',
        statusCode: response.statusCode,
        authenticated: false,
        includeNsfw: includeNsfw,
        reason: reason,
        error: exception,
        stackTrace: StackTrace.current,
      );

      throw exception;
    }
  }

  String _extractFailureReason(String? reasonPhrase, String body) {
    if (body.isNotEmpty) {
      try {
        final jsonBody = convert.json.decode(body);

        if (jsonBody is Map<String, dynamic>) {
          for (final key in ['message', 'error', 'hint']) {
            final value = jsonBody[key];

            if (value is String && value.isNotEmpty) {
              return value;
            }
          }
        }
      } catch (_) {}
    }

    return reasonPhrase ?? 'Unknown error';
  }
}
