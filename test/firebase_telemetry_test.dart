import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/providers/preferences/content_preferences_provider.dart';
import 'package:otaku_tracker/services/anime/anime_list_service.dart';
import 'package:otaku_tracker/services/anime/seasonal_anime_list_service.dart';
import 'package:otaku_tracker/services/auth/oauth_service.dart';
import 'package:otaku_tracker/services/telemetry/app_telemetry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingTelemetryService extends AppTelemetryService {
  final List<Map<String, Object?>> malApiFailures = [];
  final List<Map<String, Object?>> loginJourneySteps = [];
  final List<Map<String, Object?>> nsfwPreferenceChanges = [];

  @override
  Future<void> trackMalApiFailure({
    required String operation,
    required String endpoint,
    required String method,
    int? statusCode,
    String? reason,
    bool? authenticated,
    bool? includeNsfw,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    malApiFailures.add({
      'operation': operation,
      'endpoint': endpoint,
      'method': method,
      'statusCode': statusCode,
      'reason': reason,
      'authenticated': authenticated,
      'includeNsfw': includeNsfw,
      'error': error,
    });
  }

  @override
  Future<void> trackMalLoginJourney({
    required String step,
    required String result,
    String? detail,
  }) async {
    loginJourneySteps.add({
      'step': step,
      'result': result,
      'detail': detail,
    });
  }

  @override
  Future<void> trackNsfwPreferenceChanged({
    required bool enabled,
    required bool previousEnabled,
  }) async {
    nsfwPreferenceChanges.add({
      'enabled': enabled,
      'previousEnabled': previousEnabled,
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase telemetry instrumentation', () {
    test('OauthService tracks a successful MAL login journey', () async {
      SharedPreferences.setMockInitialValues({});
      final telemetry = RecordingTelemetryService();
      final client = MockClient((request) async {
        if (request.url.toString() == tokenUri) {
          return http.Response(
            jsonEncode({'access_token': 'token-123'}),
            200,
          );
        }

        if (request.url.toString() ==
            '$apiBaseUrl/users/@me?fields=picture,anime_statistics') {
          return http.Response(
            jsonEncode({
              'name': 'lumen',
              'picture':
                  'https://cdn.myanimelist.net/images/userimages/2.jpg',
              'anime_statistics': {'num_items_completed': 120},
            }),
            200,
          );
        }

        return http.Response('Not found', 404);
      });

      final service = OauthService(
        telemetry: telemetry,
        httpClient: client,
        authenticate: ({
          required String url,
          required String callbackUrlScheme,
        }) async {
          final state = Uri.parse(url).queryParameters['state'];
          return '$oauthRedirectUri?code=auth-code&state=$state';
        },
      );

      final result = await service.login();
      final prefs = await SharedPreferences.getInstance();

      expect(result, 'lumen');
      expect(prefs.getString('access_token'), 'token-123');
      expect(prefs.getString('username'), 'lumen');
      expect(
        telemetry.loginJourneySteps,
        containsAll([
          {'step': 'started', 'result': 'pending', 'detail': null},
          {'step': 'callback_received', 'result': 'success', 'detail': null},
          {'step': 'token_exchange', 'result': 'success', 'detail': null},
          {'step': 'profile_fetch', 'result': 'success', 'detail': null},
          {'step': 'login_completed', 'result': 'success', 'detail': null},
        ]),
      );
      expect(telemetry.malApiFailures, isEmpty);
    });

    test('OauthService tracks MAL token exchange failures', () async {
      SharedPreferences.setMockInitialValues({});
      final telemetry = RecordingTelemetryService();
      final client = MockClient((request) async {
        if (request.url.toString() == tokenUri) {
          return http.Response(
            jsonEncode({'message': 'token exchange unavailable'}),
            500,
          );
        }

        return http.Response('Not found', 404);
      });

      final service = OauthService(
        telemetry: telemetry,
        httpClient: client,
        authenticate: ({
          required String url,
          required String callbackUrlScheme,
        }) async {
          final state = Uri.parse(url).queryParameters['state'];
          return '$oauthRedirectUri?code=auth-code&state=$state';
        },
      );

      final result = await service.login();

      expect(result, startsWith('An error occurred during OAuth:'));
      expect(telemetry.malApiFailures, hasLength(1));
      expect(telemetry.malApiFailures.single['operation'], 'oauth_token_exchange');
      expect(telemetry.malApiFailures.single['statusCode'], 500);
      expect(
        telemetry.loginJourneySteps,
        contains(
          predicate<Map<String, Object?>>(
            (event) =>
                event['step'] == 'login_completed' &&
                event['result'] == 'failed',
          ),
        ),
      );
    });

    test('AnimeListService tracks MAL API failures for ranked requests',
        () async {
      final telemetry = RecordingTelemetryService();
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'service unavailable'}),
          503,
        );
      });

      final service = AnimeListService(
        telemetry: telemetry,
        httpClient: client,
      );

      await expectLater(
        service.getTopAnime(forceRefresh: true),
        throwsException,
      );

      expect(telemetry.malApiFailures, hasLength(1));
      expect(telemetry.malApiFailures.single['operation'], 'get_top_anime');
      expect(telemetry.malApiFailures.single['endpoint'], 'anime_ranking');
      expect(telemetry.malApiFailures.single['statusCode'], 503);
    });

    test('SeasonalAnimeListService tracks MAL API failures for seasonal feeds',
        () async {
      final telemetry = RecordingTelemetryService();
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'seasonal feed unavailable'}),
          502,
        );
      });

      final service = SeasonalAnimeListService(
        telemetry: telemetry,
        httpClient: client,
      );

      await expectLater(
        service.getSeasonalAnimeList(
          2026,
          SeasonType.spring,
          forceRefresh: true,
        ),
        throwsException,
      );

      expect(telemetry.malApiFailures, hasLength(1));
      expect(
        telemetry.malApiFailures.single['operation'],
        'get_seasonal_anime_list',
      );
      expect(telemetry.malApiFailures.single['endpoint'], 'anime_season');
      expect(telemetry.malApiFailures.single['statusCode'], 502);
    });

    test('NsfwPreferenceNotifier tracks explicit toggle changes', () async {
      SharedPreferences.setMockInitialValues({});
      final telemetry = RecordingTelemetryService();
      final notifier = NsfwPreferenceNotifier(telemetry: telemetry);

      await Future<void>.delayed(Duration.zero);
      await notifier.setEnabled(true);

      final prefs = await SharedPreferences.getInstance();

      expect(notifier.state, isTrue);
      expect(prefs.getBool('show_nsfw_content'), isTrue);
      expect(
        telemetry.nsfwPreferenceChanges,
        [
          {'enabled': true, 'previousEnabled': false},
        ],
      );
    });
  });
}
