import 'package:flutter_riverpod/legacy.dart';

import 'package:otaku_tracker/constants/anime/anime_seasons_helper.dart';

class SeasonSelectionNotifier
    extends StateNotifier<Set<SeasonSelectionFilter>> {
  SeasonSelectionNotifier() : super({SeasonSelectionFilter.current});

  void updateSelection(Set<SeasonSelectionFilter> newSelection) {
    state = newSelection;
  }
}

final seasonSelectionProvider =
    StateNotifierProvider<SeasonSelectionNotifier, Set<SeasonSelectionFilter>>(
        (ref) {
  return SeasonSelectionNotifier();
});
