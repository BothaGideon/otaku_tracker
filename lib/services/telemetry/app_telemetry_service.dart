import 'dart:developer' as dev;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppTelemetryService {
  AppTelemetryService({
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  })  : _analytics = analytics,
        _crashlytics = crashlytics;

  final FirebaseAnalytics? _analytics;
  final FirebaseCrashlytics? _crashlytics;

  FirebaseAnalytics get analytics => _analytics ?? FirebaseAnalytics.instance;
  FirebaseCrashlytics get crashlytics =>
      _crashlytics ?? FirebaseCrashlytics.instance;

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
    final parameters = <String, Object>{
      'operation': _clip(operation, maxLength: 40),
      'endpoint': _clip(endpoint, maxLength: 40),
      'method': _clip(method, maxLength: 10),
      if (statusCode != null) 'status_code': statusCode,
      if (authenticated != null)
        'authenticated': authenticated ? 1 : 0,
      if (includeNsfw != null) 'nsfw_enabled': includeNsfw ? 1 : 0,
      if (reason != null && reason.isNotEmpty)
        'failure_reason': _clip(reason),
    };

    await _runSafely(
      () => analytics.logEvent(
        name: 'mal_api_failure',
        parameters: parameters,
      ),
      label: 'analytics.mal_api_failure',
    );

    final message = [
      'MAL API failure',
      'operation=$operation',
      'endpoint=$endpoint',
      'method=$method',
      if (statusCode != null) 'status=$statusCode',
      if (reason != null && reason.isNotEmpty) 'reason=$reason',
    ].join(' ');

    await _runSafely(
      () => crashlytics.log(message),
      label: 'crashlytics.log.mal_api_failure',
    );

    await _runSafely(
      () => crashlytics.recordError(
        error ?? Exception(message),
        stackTrace ?? StackTrace.current,
        fatal: false,
        reason: 'Handled MAL API failure',
        information: [
          'operation=$operation',
          'endpoint=$endpoint',
          'method=$method',
          if (statusCode != null) 'statusCode=$statusCode',
          if (authenticated != null) 'authenticated=$authenticated',
          if (includeNsfw != null) 'includeNsfw=$includeNsfw',
          if (reason != null && reason.isNotEmpty) 'reason=$reason',
        ],
      ),
      label: 'crashlytics.recordError.mal_api_failure',
    );
  }

  Future<void> trackMalLoginJourney({
    required String step,
    required String result,
    String? detail,
  }) async {
    final parameters = <String, Object>{
      'step': _clip(step, maxLength: 40),
      'result': _clip(result, maxLength: 20),
      if (detail != null && detail.isNotEmpty) 'detail': _clip(detail),
    };

    await _runSafely(
      () => analytics.logEvent(
        name: 'mal_login_journey',
        parameters: parameters,
      ),
      label: 'analytics.mal_login_journey',
    );

    await _runSafely(
      () => crashlytics.log(
        'MAL login journey step=$step result=$result'
        '${detail == null || detail.isEmpty ? '' : ' detail=$detail'}',
      ),
      label: 'crashlytics.log.mal_login_journey',
    );
  }

  Future<void> trackNsfwPreferenceChanged({
    required bool enabled,
    required bool previousEnabled,
  }) async {
    await _runSafely(
      () => analytics.logEvent(
        name: 'nsfw_preference_changed',
        parameters: {
          'enabled': enabled ? 1 : 0,
          'previous_enabled': previousEnabled ? 1 : 0,
        },
      ),
      label: 'analytics.nsfw_preference_changed',
    );

    await _runSafely(
      () => analytics.setUserProperty(
        name: 'nsfw_content_enabled',
        value: enabled.toString(),
      ),
      label: 'analytics.user_property.nsfw_content_enabled',
    );

    await _runSafely(
      () => crashlytics.log(
        'NSFW preference changed from $previousEnabled to $enabled',
      ),
      label: 'crashlytics.log.nsfw_preference_changed',
    );
  }

  Future<void> _runSafely(
    Future<void> Function() action, {
    required String label,
  }) async {
    try {
      await action();
    } catch (error, stackTrace) {
      dev.log(
        'Telemetry action failed: $label',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _clip(String value, {int maxLength = 100}) {
    if (value.length <= maxLength) {
      return value;
    }

    return value.substring(0, maxLength);
  }
}
