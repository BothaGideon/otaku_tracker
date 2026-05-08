import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:otaku_tracker/models/response/anime.dart';

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
  final headers = {'X-MAL-CLIENT-ID': const String.fromEnvironment('MALAPI')};

  Future<AnimeDTO> searchAnime(String query, {int limit = 30}) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime?q=${Uri.encodeQueryComponent(query)}&limit=$limit&fields=mean,num_scoring_users',
      errorPrefix: 'Failed to search anime',
    );
  }

  Future<AnimeDTO> getAnimeList() async {
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

      final fromJson = AnimeDTO.fromJson(jsonResponse);

      return fromJson;
    } else {
      throw Exception(
          'Failed to load anime list: ${streamedResponse.reasonPhrase}');
    }
  }

  Future<UserAnimeListDTO> getUserAnimeList(String accessToken) async {
    final request = http.Request(
      'GET',
      Uri.parse(
        'https://api.myanimelist.net/v2/users/@me/animelist?limit=1000&fields=list_status{priority,num_times_rewatched,rewatch_value,tags,comments},mean,num_episodes',
      ),
    );
    request.headers.addAll({'Authorization': 'Bearer $accessToken'});

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = convert.json.decode(response.body);

      final fromJson = UserAnimeListDTO.fromJson(jsonResponse);

      return fromJson;
    } else {
      throw Exception('Failed to load user anime list: ${streamedResponse.reasonPhrase}');
    }
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
      return;
    }

    throw Exception(
      'Failed to delete anime list status: ${streamedResponse.reasonPhrase}',
    );
  }

  Future<AnimeDTO> getTopAnime({int limit = 30}) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime/ranking?ranking_type=bypopularity&limit=$limit&fields=mean,num_scoring_users',
      errorPrefix: 'Failed to load top anime',
    );
  }

  Future<AnimeDTO> getTopRatedAnime({int limit = 30}) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime/ranking?ranking_type=all&limit=$limit&fields=mean,num_scoring_users',
      errorPrefix: 'Failed to load top rated anime',
    );
  }

  Future<AnimeDTO> getRecentlyAddedAnime({int limit = 30}) async {
    return _fetchAnimeCollection(
      'https://api.myanimelist.net/v2/anime?q=a&limit=$limit&order_by=id&sort=desc&fields=mean,num_scoring_users',
      errorPrefix: 'Failed to load recently added anime',
    );
  }

  Future<AnimeDTO> _fetchAnimeCollection(
    String url, {
    required String errorPrefix,
  }) async {
    final request = http.Request(
      'GET',
      Uri.parse(url),
    );
    request.headers.addAll(headers);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode == 200) {
      final response = await http.Response.fromStream(streamedResponse);
      final jsonResponse = convert.json.decode(response.body);

      return AnimeDTO.fromJson(jsonResponse);
    } else {
      throw Exception('$errorPrefix: ${streamedResponse.reasonPhrase}');
    }
  }
}
