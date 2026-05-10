import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:flutter_riverpod/legacy.dart'
    show StateNotifier, StateNotifierProvider;

import 'package:otaku_tracker/constants/anime/anime_seasons_helper.dart';
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/providers/anime/anime_list_provider.dart';
import 'package:otaku_tracker/providers/anime/season_state_provider.dart';
import 'package:otaku_tracker/providers/preferences/content_preferences_provider.dart';

class SeasonalAnimePaginationState {
  final List<AnimeData> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final Object? initialError;
  final StackTrace? initialStackTrace;
  final Object? loadMoreError;
  final String? nextPageUrl;

  const SeasonalAnimePaginationState({
    required this.items,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.initialError,
    required this.initialStackTrace,
    required this.loadMoreError,
    required this.nextPageUrl,
  });

  const SeasonalAnimePaginationState.initial()
      : items = const [],
        isInitialLoading = true,
        isLoadingMore = false,
        initialError = null,
        initialStackTrace = null,
        loadMoreError = null,
        nextPageUrl = null;

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  SeasonalAnimePaginationState copyWith({
    List<AnimeData>? items,
    bool? isInitialLoading,
    bool? isLoadingMore,
    Object? initialError = _sentinel,
    Object? initialStackTrace = _sentinel,
    Object? loadMoreError = _sentinel,
    Object? nextPageUrl = _sentinel,
  }) {
    final resolvedInitialError =
        identical(initialError, _sentinel) ? this.initialError : initialError;
    final resolvedInitialStackTrace = identical(initialStackTrace, _sentinel)
        ? this.initialStackTrace
        : initialStackTrace as StackTrace?;
    final resolvedLoadMoreError =
        identical(loadMoreError, _sentinel) ? this.loadMoreError : loadMoreError;
    final resolvedNextPageUrl = identical(nextPageUrl, _sentinel)
        ? this.nextPageUrl
        : nextPageUrl as String?;

    return SeasonalAnimePaginationState(
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      initialError: resolvedInitialError,
      initialStackTrace: resolvedInitialStackTrace,
      loadMoreError: resolvedLoadMoreError,
      nextPageUrl: resolvedNextPageUrl,
    );
  }
}

class SeasonalAnimePaginationController
    extends StateNotifier<SeasonalAnimePaginationState> {
  final Ref ref;
  final SeasonSelectionFilter selection;
  final bool includeNsfw;

  SeasonalAnimePaginationController(
    this.ref, {
    required this.selection,
    required this.includeNsfw,
  }) : super(const SeasonalAnimePaginationState.initial()) {
    loadInitial();
  }

  Future<void> loadInitial({bool forceRefresh = false}) async {
    state = state.copyWith(
      items: const [],
      isInitialLoading: true,
      isLoadingMore: false,
      initialError: null,
      initialStackTrace: null,
      loadMoreError: null,
      nextPageUrl: null,
    );

    try {
      final season = _selectedSeason();
      final response = await ref.read(seasonalAnimeListServiceProvider).getSeasonalAnimeList(
            season.year,
            season.seasonType,
            includeNsfw: includeNsfw,
            forceRefresh: forceRefresh,
          );

      state = state.copyWith(
        items: response.data,
        isInitialLoading: false,
        nextPageUrl: response.paging?.next,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isInitialLoading: false,
        initialError: error,
        initialStackTrace: stackTrace,
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial(forceRefresh: true);
  }

  Future<void> loadNextPage() async {
    final nextPageUrl = state.nextPageUrl;

    if (state.isInitialLoading || state.isLoadingMore || nextPageUrl == null) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      loadMoreError: null,
    );

    try {
      final response = await ref
          .read(seasonalAnimeListServiceProvider)
          .getSeasonalAnimeListByUrl(nextPageUrl);

      state = state.copyWith(
        items: [...state.items, ...response.data],
        isLoadingMore: false,
        nextPageUrl: response.paging?.next,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        loadMoreError: error,
      );
    }
  }

  SeasonYearType _selectedSeason() {
    final helper = AnimeSeasonsHelper();

    switch (selection) {
      case SeasonSelectionFilter.past:
        return helper.getPreviousSeason();
      case SeasonSelectionFilter.upcoming:
        return helper.getUpcomingSeason();
      case SeasonSelectionFilter.current:
        return helper.getCurrentSeason();
    }
  }
}

final seasonalAnimePaginationProvider = StateNotifierProvider.autoDispose<
    SeasonalAnimePaginationController, SeasonalAnimePaginationState>((ref) {
  final selection = ref.watch(seasonSelectionProvider).first;
  final includeNsfw = ref.watch(nsfwPreferenceProvider);

  return SeasonalAnimePaginationController(
    ref,
    selection: selection,
    includeNsfw: includeNsfw,
  );
});

const _sentinel = Object();
