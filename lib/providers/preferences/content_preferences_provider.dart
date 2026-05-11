import 'package:flutter_riverpod/legacy.dart';
import 'package:otaku_tracker/services/telemetry/app_telemetry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _nsfwPreferenceKey = 'show_nsfw_content';

final nsfwPreferenceProvider =
    StateNotifierProvider<NsfwPreferenceNotifier, bool>(
  (ref) => NsfwPreferenceNotifier(),
);

class NsfwPreferenceNotifier extends StateNotifier<bool> {
  NsfwPreferenceNotifier({
    AppTelemetryService? telemetry,
  })  : _telemetry = telemetry ?? AppTelemetryService(),
        super(false) {
    _loadSavedPreference();
  }

  final AppTelemetryService _telemetry;

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_nsfwPreferenceKey) ?? false;
  }

  Future<void> setEnabled(bool isEnabled) async {
    if (state == isEnabled) {
      return;
    }

    final previousEnabled = state;
    state = isEnabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nsfwPreferenceKey, isEnabled);
    await _telemetry.trackNsfwPreferenceChanged(
      enabled: isEnabled,
      previousEnabled: previousEnabled,
    );
  }
}
