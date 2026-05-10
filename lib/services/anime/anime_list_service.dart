import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/services/anime/mal_api_cache_service.dart';

class AnimeListStatusUpdate {
  final String? status;
  final bool? isRewatching;
  final int? score;
  final int? numWatchedEpisodes;
  final int? priority;
  final int? numTimesRewatched;
  final int? rewatchValue;
  final String? tags;
  final String? comments;

  const AnimeListStatusUpdate({
    this.status,
    this.isRewatching,
    this.score,
    this.numWatchedEpisodes,
    this.priority,
    this.numTimesRewatched,
    this.rewatchValue,
    this.tags,
    this.comments,
  });

  Map<String, String> toFormFields() {
    final fields = <String, String>{};

    if (status != null) {
      fields['status'] = status!;
    }
    if (isRewatching != null) {
      fields['is_rewatching'] = isRewatching.toString();
    }
    if (score != null) {
      fields['score'] = score.toString();
    }
    if (numWatchedEpisodes != null) {
      fields['num_watched_episodes'] = numWatchedEpisodes.toString();
    }
    if (priority != null) {
      fields['priority'] = priority.toString();
    }
    if (numTimesRewatched != null) {
      fields['num_times_rewatched'] = numTimesRewatched.toString();
    }
    if (rewatchValue != null) {
      fields['rewatch_value'] = rewatchValue.toString();
    }
    if (tags != null) {
      fields['tags'] = tags!;
    }
    if (comments != null) {
      fields['comments'] = comments!;
    }

    return fields;
  }
}

class AnimeListService {
  static const _userAnimeListCachePrefix = 'userAnimeList';
  static const _feedFields = 'mean,num_scoring_users,num_list_users,status';

  final MalApiCacheService cache;
  final headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};

  AnimeListService({
    MalApiCacheService? cache,
  }) : cache = cache ?? MalApiCacheService(ttl: const Duration(minutes: 15));

  Future<AnimeDTO> searchAnime(
    String query, {
    int limit = 30,
    bool includeNsfw = false,
    bool forceRefresh = false,
  }) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime?q=${Uri.encodeQueryComponent(query)}&limit=$limit&fields=mean,num_scoring_users&nsfw=$includeNsfw',
      cacheKey: 'searchAnime:$query:$limit:$includeNsfw',
      errorPrefix: 'Failed to search anime',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> getAnimeList({
    bool forceRefresh = false,
  }) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime?q=one&limit=500&order_by=id&sort=asc',
      cacheKey: 'getAnimeList',
      errorPrefix: 'Failed to load anime list',
      forceRefresh: forceRefresh,
    );
  }

  Future<UserAnimeListDTO> getUserAnimeList(
    String accessToken, {
    bool forceRefresh = false,
  }) async {
    return _getCachedGet(
      url:
          'https://api.myanimelist.net/v2/users/@me/animelist?limit=1000&fields=list_status{priority,num_times_rewatched,rewatch_value,tags,comments},mean,num_episodes',
      cacheKey: _userAnimeListCacheKey(accessToken),
      errorPrefix: 'Failed to load user anime list',
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: UserAnimeListDTO.fromJson,
      forceRefresh: forceRefresh,
    );
  }

  void invalidateUserAnimeList(String accessToken) {
    cache.invalidate(_userAnimeListCacheKey(accessToken));
  }

  Future<ListStatus> updateMyAnimeListStatus(
    String accessToken,
    int animeId,
    AnimeListStatusUpdate update,
  ) async {
    final fields = update.toFormFields();

    if (fields.isEmpty) {
      throw ArgumentError('At least one anime list status field must be provided.');
    }

    final request = http.Request(
      'PATCH',
      Uri.parse('https://api.myanimelist.net/v2/anime/$animeId/my_list_status'),
    );
    request.headers.addAll({
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/x-www-form-urlencoded',
    });
    request.bodyFields = fields;

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      invalidateUserAnimeList(accessToken);
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = convert.json.decode(response.body) as Map<String, dynamic>;

      return ListStatus.fromJson(jsonResponse);
    }

    throw Exception(
      'Failed to update anime list status: ${streamedResponse.reasonPhrase}',
    );
  }

  Future<void> deleteMyAnimeListStatus(String accessToken, int animeId) async {
    final request = http.Request(
      'DELETE',
      Uri.parse('https://api.myanimelist.net/v2/anime/$animeId/my_list_status'),
    );
    request.headers.addAll({'Authorization': 'Bearer $accessToken'});

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 404) {
      invalidateUserAnimeList(accessToken);
      return;
    }

    throw Exception(
      'Failed to delete anime list status: ${streamedResponse.reasonPhrase}',
    );
  }

  Future<AnimeDTO> getTopAnime({
    int limit = 30,
    bool includeNsfw = false,
    bool forceRefresh = false,
  }) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime/ranking?ranking_type=bypopularity&limit=$limit&fields=mean,num_scoring_users&nsfw=$includeNsfw',
      cacheKey: 'topAnime:$limit:$includeNsfw',
      errorPrefix: 'Failed to load top anime',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> getTopRatedAnime({
    int limit = 30,
    bool includeNsfw = false,
    bool forceRefresh = false,
  }) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime/ranking?ranking_type=all&limit=$limit&fields=mean,num_scoring_users&nsfw=$includeNsfw',
      cacheKey: 'topRatedAnime:$limit:$includeNsfw',
      errorPrefix: 'Failed to load top rated anime',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> getRecentlyAddedAnime({
    int limit = 30,
    bool includeNsfw = false,
    bool forceRefresh = false,
  }) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime?q=a&limit=$limit&order_by=id&sort=desc&fields=mean,num_scoring_users&nsfw=$includeNsfw',
      cacheKey: 'recentlyAddedAnime:$limit:$includeNsfw',
      errorPrefix: 'Failed to load recently added anime',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> getRankedAnime({
    required String rankingType,
    int limit = 30,
    bool includeNsfw = false,
    bool forceRefresh = false,
  }) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime/ranking?ranking_type=$rankingType&limit=$limit&fields=$_feedFields&nsfw=$includeNsfw',
      cacheKey: 'rankedAnime:$rankingType:$limit:$includeNsfw',
      errorPrefix: 'Failed to load ranked anime',
      forceRefresh: forceRefresh,
    );
  }

  Future<AnimeDTO> _fetchAnimeCollection(
    String url, {
    required String cacheKey,
    required String errorPrefix,
    bool forceRefresh = false,
  }) async {
    return _getCachedGet(
      url: url,
      cacheKey: cacheKey,
      errorPrefix: errorPrefix,
      headers: headers,
      fromJson: AnimeDTO.fromJson,
      forceRefresh: forceRefresh,
    );
  }

  Future<T> _getCachedGet<T>({
    required String url,
    required String cacheKey,
    required String errorPrefix,
    required Map<String, String> headers,
    required T Function(Map<String, dynamic> json) fromJson,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cachedValue = cache.get<T>(cacheKey);

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
      final jsonResponse = convert.json.decode(response.body) as Map<String, dynamic>;
      final parsedValue = fromJson(jsonResponse);

      cache.put(cacheKey, parsedValue);

      return parsedValue;
    } else {
      throw Exception('$errorPrefix: ${streamedResponse.reasonPhrase}');
    }
  }

  String _userAnimeListCacheKey(String accessToken) {
    return '$_userAnimeListCachePrefix:${accessToken.hashCode}';
  }
}
