import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/anime_seasons_helper.dart';

class SeasonSelectionNotifier
    extends StateNotifier<Set<SeasonSelectionFilter>> {
  SeasonSelectionNotifier() : super({SeasonSelectionFilter.current});

  void updateSelection(Set<SeasonSelectionFilter> newSelection, WidgetRef ref) {
    state = newSelection;
  }
}

final seasonSelectionProvider =
    StateNotifierProvider<SeasonSelectionNotifier, Set<SeasonSelectionFilter>>(
        (ref) {
  return SeasonSelectionNotifier();
});
