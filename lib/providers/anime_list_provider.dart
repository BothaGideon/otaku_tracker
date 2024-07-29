import 'package:otaku_tracker/constants/anime_seasons_helper.dart';
import 'package:otaku_tracker/services/seasonal_anime_list_service.dart';
import 'package:riverpod/riverpod.dart';

import '../models/response/anime.dart';
import '../services/anime_list_service.dart';

final combinedAnimeListProvider = FutureProvider<CombinedData>((ref) async {
  final year = DateTime.now().year;
  final month = AnimeSeasonsHelper().getMonthName(DateTime.now().month);
  final season = AnimeSeasonsHelper().getSeason(month);

  final animeListFuture = AnimeListService().getAnimeList();
  final seasonalAnimeFuture =
      SeasonalAnimeListService().getSeasonalAnimeList(year, season);

  final results = await Future.wait([animeListFuture, seasonalAnimeFuture]);

  final animeList = results[0].data;
  final seasonalAnimeList = results[1].data;
  return CombinedData(
      animeList: animeList, seasonalAnimeList: seasonalAnimeList);
});

class CombinedData {
  final List<AnimeData> animeList;
  final List<AnimeData> seasonalAnimeList;

  CombinedData({required this.animeList, required this.seasonalAnimeList});
}
