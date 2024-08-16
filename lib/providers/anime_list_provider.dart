import 'package:otaku_tracker/constants/anime_seasons_helper.dart';
import 'package:otaku_tracker/services/seasonal_anime_list_service.dart';
import 'package:riverpod/riverpod.dart';

import '../models/response/anime.dart';
import '../services/anime_list_service.dart';

final combinedAnimeListProvider = FutureProvider<CombinedData>((ref) async {
  final season = AnimeSeasonsHelper().getCurrentSeason();
  final previousSeason = AnimeSeasonsHelper().getPreviousSeason();

  final animeListFuture = AnimeListService().getAnimeList();
  final seasonalAnimeFuture =
      SeasonalAnimeListService().getSeasonalAnimeList(season.$2, season.$1);
  final previousSeasonAnimeFuture = SeasonalAnimeListService()
      .getSeasonalAnimeList(previousSeason.$2, previousSeason.$1);

  final results = await Future.wait(
      [animeListFuture, seasonalAnimeFuture, previousSeasonAnimeFuture]);

  final animeList = results[0].data;
  final seasonalAnimeList = results[1].data;
  final previousSeasonAnimeList = results[2].data;
  return CombinedData(
      animeList: animeList,
      currentSeasonAnimeList: seasonalAnimeList,
      previousSeasonAnimeList: previousSeasonAnimeList);
});

class CombinedData {
  final List<AnimeData> animeList;
  final List<AnimeData> currentSeasonAnimeList;
  final List<AnimeData> previousSeasonAnimeList;

  CombinedData(
      {required this.previousSeasonAnimeList,
      required this.animeList,
      required this.currentSeasonAnimeList});
}
