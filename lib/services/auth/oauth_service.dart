import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:otaku_tracker/services/telemetry/app_telemetry_service.dart';

const clientId = String.fromEnvironment('MALAPI');
const tokenUri = 'https://myanimelist.net/v1/oauth2/token';
const authorizeUri = 'https://myanimelist.net/v1/oauth2/authorize';
const apiBaseUrl = 'https://api.myanimelist.net/v2';
const oauthCallbackUrlScheme = 'otaku.tracker';
const oauthRedirectUri = '$oauthCallbackUrlScheme://auth';

class OauthService {
  OauthService({
    AppTelemetryService? telemetry,
    http.Client? httpClient,
    Future<String> Function({
      required String url,
      required String callbackUrlScheme,
    })? authenticate,
  })  : _telemetry = telemetry ?? AppTelemetryService(),
        _httpClient = httpClient ?? http.Client(),
        _authenticate = authenticate ?? FlutterWebAuth2.authenticate;

  final AppTelemetryService _telemetry;
  final http.Client _httpClient;
  final Future<String> Function({
    required String url,
    required String callbackUrlScheme,
  }) _authenticate;

  Future<String?> login() async {
    final verifier = _generateCodeVerifier();
    final state = _generateState();
    final loginUrl = _generateLoginUrl(verifier, state);

    try {
      await _telemetry.trackMalLoginJourney(
        step: 'started',
        result: 'pending',
      );
      dev.log('Starting OAuth flow with URL: $loginUrl');
      final uri = await _authenticate(
        url: loginUrl,
        callbackUrlScheme: oauthCallbackUrlScheme,
      );
      dev.log('OAuth callback received: $uri');
      await _telemetry.trackMalLoginJourney(
        step: 'callback_received',
        result: 'success',
      );

      final queryParams = Uri.parse(uri).queryParameters;
      final code = queryParams['code'];
      final returnedState = queryParams['state'];

      if (code == null) {
        dev.log('No authorization code in callback URI');
        await _telemetry.trackMalLoginJourney(
          step: 'callback_received',
          result: 'failed',
          detail: 'missing_code',
        );
        return null;
      }

      if (returnedState != state) {
        dev.log('OAuth state mismatch. Expected $state, got $returnedState');
        await _telemetry.trackMalLoginJourney(
          step: 'state_validation',
          result: 'failed',
          detail: 'state_mismatch',
        );
        return 'Login failed: invalid OAuth state';
      }

      dev.log('Authorization code received: $code');

      final tokenJson = await _generateTokens(verifier, code);
      await _telemetry.trackMalLoginJourney(
        step: 'token_exchange',
        result: 'success',
      );
      final userData = await getCurrentUserData(tokenJson['access_token']);
      final username = userData['username'] as String?;
      final picture = userData['picture'] as String?;

      if (username == null || username.isEmpty) {
        dev.log('Login failed: username missing from MAL response');
        await _telemetry.trackMalLoginJourney(
          step: 'profile_fetch',
          result: 'failed',
          detail: 'missing_username',
        );
        return 'Login failed: MyAnimeList did not return a username';
      }

      await _telemetry.trackMalLoginJourney(
        step: 'profile_fetch',
        result: 'success',
      );

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

      await _telemetry.trackMalLoginJourney(
        step: 'login_completed',
        result: 'success',
      );
      return username;
    } catch (e) {
      await _telemetry.trackMalLoginJourney(
        step: 'login_completed',
        result: _isCancellationError(e) ? 'cancelled' : 'failed',
        detail: _shortErrorDetail(e),
      );
      dev.log('OAuth error: $e');
      return 'An error occurred during OAuth: $e';
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(200, (i) => random.nextInt(256));
    return base64UrlEncode(values).substring(0, 128);
  }

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _generateLoginUrl(String verifier, String state) {
    return Uri.parse(authorizeUri).replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': clientId,
        'state': state,
        'redirect_uri': oauthRedirectUri,
        'code_challenge': verifier,
        'code_challenge_method': 'plain',
      },
    ).toString();
  }

  Future<Map<String, dynamic>> _generateTokens(
      String verifier, String code) async {
    final params = {
      'client_id': clientId,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': oauthRedirectUri,
      'code_verifier': verifier,
    };

    http.Response response;

    try {
      response = await _httpClient.post(Uri.parse(tokenUri), body: params);
    } catch (error, stackTrace) {
      await _telemetry.trackMalApiFailure(
        operation: 'oauth_token_exchange',
        endpoint: 'oauth2_token',
        method: 'POST',
        authenticated: false,
        reason: error.runtimeType.toString(),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    if (response.statusCode != 200) {
      final reason = _extractFailureReason(response.reasonPhrase, response.body);
      final exception = Exception('Failed to exchange OAuth token: $reason');

      await _telemetry.trackMalApiFailure(
        operation: 'oauth_token_exchange',
        endpoint: 'oauth2_token',
        method: 'POST',
        statusCode: response.statusCode,
        authenticated: false,
        reason: reason,
        error: exception,
        stackTrace: StackTrace.current,
      );

      throw exception;
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, Object?>> getCurrentUserData(String accessToken) async {
    const url = '$apiBaseUrl/users/@me?fields=picture,anime_statistics';
    http.Response response;

    try {
      response = await _httpClient.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error, stackTrace) {
      await _telemetry.trackMalApiFailure(
        operation: 'get_current_user_data',
        endpoint: 'users_me',
        method: 'GET',
        authenticated: true,
        reason: error.runtimeType.toString(),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    if (response.statusCode != 200) {
      final reason = _extractFailureReason(response.reasonPhrase, response.body);
      final exception = Exception('Failed to load user data: $reason');

      await _telemetry.trackMalApiFailure(
        operation: 'get_current_user_data',
        endpoint: 'users_me',
        method: 'GET',
        statusCode: response.statusCode,
        authenticated: true,
        reason: reason,
        error: exception,
        stackTrace: StackTrace.current,
      );

      throw exception;
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

  bool _isCancellationError(Object error) {
    final normalizedError = error.toString().toLowerCase();

    return normalizedError.contains('cancel');
  }

  String _shortErrorDetail(Object error) {
    final message = error.toString();

    if (message.length <= 100) {
      return message;
    }

    return message.substring(0, 100);
  }

  String _extractFailureReason(String? reasonPhrase, String body) {
    if (body.isNotEmpty) {
      try {
        final jsonBody = jsonDecode(body);

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
