import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const clientId = String.fromEnvironment('MALAPI');
const tokenUri = 'https://myanimelist.net/v1/oauth2/token';
const authorizeUri = 'https://myanimelist.net/v1/oauth2/authorize';
const apiBaseUrl = 'https://api.myanimelist.net/v2';
const oauthCallbackUrlScheme = 'otaku.tracker';
const oauthRedirectUri = '$oauthCallbackUrlScheme:/';

class OauthService {
  Future<String?> login() async {
    final verifier = _generateCodeVerifier();
    final loginUrl = _generateLoginUrl(verifier);

    try {
      dev.log('Starting OAuth flow with URL: $loginUrl');
      final uri = await FlutterWebAuth2.authenticate(
          url: loginUrl, callbackUrlScheme: oauthCallbackUrlScheme);
      dev.log('OAuth callback received: $uri');

      final queryParams = Uri.parse(uri).queryParameters;
      final code = queryParams['code'];

      if (code == null) {
        dev.log('No authorization code in callback URI');
        return null;
      }

      dev.log('Authorization code received: $code');

      final tokenJson = await _generateTokens(verifier, code);
      final userData = await getCurrentUserData(tokenJson['access_token']);
      final username = userData['username'] as String?;
      final picture = userData['picture'] as String?;

      if (username == null || username.isEmpty) {
        dev.log('Login failed: username missing from MAL response');
        return 'Login failed: MyAnimeList did not return a username';
      }

      dev.log('Login successful for user: $username');
      tokenJson['datetime'] = DateTime.now();
      dev.log('Token data: $tokenJson');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', tokenJson['access_token']);
      await prefs.setString('username', username);
      if (picture != null && picture.isNotEmpty) {
        await prefs.setString('picture', picture);
      } else {
        await prefs.remove('picture');
      }

      return username;
    } catch (e) {
      dev.log('OAuth error: $e');
      return 'An error occurred during OAuth: $e';
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(200, (i) => random.nextInt(256));
    return base64UrlEncode(values).substring(0, 128);
  }

  String _generateLoginUrl(String verifier) {
    return '$authorizeUri?response_type=code&client_id=$clientId&code_challenge=$verifier';
  }

  Future<Map<String, dynamic>> _generateTokens(
      String verifier, String code) async {
    final params = {
      'client_id': clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'code_verifier': verifier,
    };
    final response = await http.post(Uri.parse(tokenUri), body: params);
    return jsonDecode(response.body);
  }

  Future<Map<String, Object?>> getCurrentUserData(String accessToken) async {
    const url = '$apiBaseUrl/users/@me?fields=picture,anime_statistics';
    final response = await http
        .get(Uri.parse(url), headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode != 200) {
      throw Exception('Failed to load user data: ${response.reasonPhrase}');
    }

    final userJson = jsonDecode(response.body) as Map<String, dynamic>;
    final animeStatisticsJson =
        userJson['anime_statistics'] as Map<String, dynamic>?;

    return {
      'username': userJson['name'] as String?,
      'picture': userJson['picture'] as String?,
      'animeStatistics': animeStatisticsJson == null
          ? null
          : {
              'numItemsWatching':
                  (animeStatisticsJson['num_items_watching'] as num?)?.toInt(),
              'numItemsCompleted':
                  (animeStatisticsJson['num_items_completed'] as num?)?.toInt(),
              'numItemsOnHold':
                  (animeStatisticsJson['num_items_on_hold'] as num?)?.toInt(),
              'numItemsDropped':
                  (animeStatisticsJson['num_items_dropped'] as num?)?.toInt(),
              'numItemsPlanToWatch':
                  (animeStatisticsJson['num_items_plan_to_watch'] as num?)
                      ?.toInt(),
              'numItems': (animeStatisticsJson['num_items'] as num?)?.toInt(),
              'numEpisodes':
                  (animeStatisticsJson['num_episodes'] as num?)?.toInt(),
              'numDaysWatched':
                  (animeStatisticsJson['num_days_watched'] as num?)?.toDouble(),
              'numTimesRewatched':
                  (animeStatisticsJson['num_times_rewatched'] as num?)?.toInt(),
              'meanScore':
                  (animeStatisticsJson['mean_score'] as num?)?.toDouble(),
            },
    };
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<String?> getUserPicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('picture');
  }

  Future<void> saveUserPicture(String? picture) async {
    final prefs = await SharedPreferences.getInstance();

    if (picture == null || picture.isEmpty) {
      await prefs.remove('picture');
      return;
    }

    await prefs.setString('picture', picture);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('username');
    await prefs.remove('picture');
  }
}
