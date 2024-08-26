import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/constants/anime_seasons_helper.dart';
import 'package:riverpod/riverpod.dart';

final combinedAnimeListProvider = StateNotifierProvider<CombinedAnimeListNotifier, AsyncValue<CombinedData>>((ref) {
  return CombinedAnimeListNotifier();
});

class CombinedAnimeListNotifier extends StateNotifier<AsyncValue<CombinedData>> {
  CombinedAnimeListNotifier() : super(const AsyncValue.loading()) {
    loadInitialData();
  }

  final Jikan jikan = Jikan();

  Future<void> loadInitialData() async {
    try {
      final season = AnimeSeasonsHelper().getCurrentSeason();
      final previousSeason = AnimeSeasonsHelper().getPreviousSeason();
      final upcomingSeasonDate = AnimeSeasonsHelper().getUpcomingSeason();

      // Initial load
      final currentSeason = await jikan.getSeason(year: season.year, season: season.seasonType);
      final previousSeasonJ = await jikan.getSeason(year: previousSeason.year, season: previousSeason.seasonType);
      final upcomingSeason = await jikan.getSeason(year: upcomingSeasonDate.year, season: upcomingSeasonDate.seasonType);

      final currentSeasonList = currentSeason.toList();
      final previousSeasonList = previousSeasonJ.toList();
      final upcomingSeasonList = upcomingSeason.toList();

      state = AsyncValue.data(
        CombinedData(
          currentSeasonAnimeList: currentSeasonList,
          previousSeasonAnimeList: previousSeasonList,
          upcomingSeasonAnimeList: upcomingSeasonList,
          topUpcoming: [],
          topAiring: [],
          mostPopular: [],
          hasMoreData: true,
          currentPage: 1,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }

  Future<void> loadMoreData(SeasonSelectionFilter filter) async {
    if (state is AsyncLoading || !state.value!.hasMoreData) return;

    state = AsyncValue.loading(state.value);

    try {
      final currentPage = state.value!.currentPage;
      final nextPage = currentPage + 1;

      List<Anime> newAnimeList = [];
      switch (filter) {
        case SeasonSelectionFilter.past:
          final season = AnimeSeasonsHelper().getPreviousSeason(nextPage);
          final seasonData = await jikan.getSeason(year: season.year, season: season.seasonType);
          newAnimeList = seasonData.toList();
          break;
        case SeasonSelectionFilter.upcoming:
          final season = AnimeSeasonsHelper().getUpcomingSeason(nextPage);
          final seasonData = await jikan.getSeason(year: season.year, season: season.seasonType);
          newAnimeList = seasonData.toList();
          break;
        default:
          final season = AnimeSeasonsHelper().getCurrentSeason(nextPage);
          final seasonData = await jikan.getSeason(year: season.year, season: season.seasonType);
          newAnimeList = seasonData.toList();
          break;
      }

      final updatedData = CombinedData(
        currentSeasonAnimeList: filter == SeasonSelectionFilter.current ? [...state.value!.currentSeasonAnimeList, ...newAnimeList] : state.value!.currentSeasonAnimeList,
        previousSeasonAnimeList: filter == SeasonSelectionFilter.past ? [...state.value!.previousSeasonAnimeList, ...newAnimeList] : state.value!.previousSeasonAnimeList,
        upcomingSeasonAnimeList: filter == SeasonSelectionFilter.upcoming ? [...state.value!.upcomingSeasonAnimeList, ...newAnimeList] : state.value!.upcomingSeasonAnimeList,
        topUpcoming: state.value!.topUpcoming,
        topAiring: state.value!.topAiring,
        mostPopular: state.value!.mostPopular,
        hasMoreData: newAnimeList.isNotEmpty,
        currentPage: nextPage,
      );

      state = AsyncValue.data(updatedData);
    } catch (e) {
      state = AsyncValue.error(e);
    }
  }
}

class CombinedData {
  final List<Anime> currentSeasonAnimeList;
  final List<Anime> previousSeasonAnimeList;
  final List<Anime> upcomingSeasonAnimeList;
  final List<Anime> topUpcoming;
  final List<Anime> topAiring;
  final List<Anime> mostPopular;
  final bool hasMoreData;
  final int currentPage;

  CombinedData({
    required this.previousSeasonAnimeList,
    required this.upcomingSeasonAnimeList,
    required this.topUpcoming,
    required this.topAiring,
    required this.mostPopular,
    required this.currentSeasonAnimeList,
    this.hasMoreData = true,
    this.currentPage = 1,
  });
}
