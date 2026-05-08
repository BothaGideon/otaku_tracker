import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _nsfwPreferenceKey = 'show_nsfw_content';

final nsfwPreferenceProvider =
    StateNotifierProvider<NsfwPreferenceNotifier, bool>(
  (ref) => NsfwPreferenceNotifier(),
);

class NsfwPreferenceNotifier extends StateNotifier<bool> {
  NsfwPreferenceNotifier() : super(false) {
    _loadSavedPreference();
  }

  Future<void> _loadSavedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_nsfwPreferenceKey) ?? false;
  }

  Future<void> setEnabled(bool isEnabled) async {
    state = isEnabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_nsfwPreferenceKey, isEnabled);
  }
}
