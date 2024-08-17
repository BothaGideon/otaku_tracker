import 'dart:developer';

import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/constants/anime_seasons_helper.dart';
import 'package:riverpod/riverpod.dart';

final combinedAnimeListProvider = FutureProvider<CombinedData>((ref) async {
  final jikan = Jikan();
  final season = AnimeSeasonsHelper().getCurrentSeason();
  final previousSeason = AnimeSeasonsHelper().getPreviousSeason();

  // current season
  final currentSeason =
      await jikan.getSeason(year: season.$2, season: season.$1);
  // previous season
  final previousSeasonJ =
      await jikan.getSeason(year: previousSeason.$2, season: previousSeason.$1);
  // TODO: suggested for you
  //top upcoming
  final topUpcoming = await jikan.getTopAnime(filter: TopFilter.upcoming);
  //top airing
  final topAiring = await jikan.getTopAnime(filter: TopFilter.airing);
  //most popular
  final mostPopular = await jikan.getTopAnime(filter: TopFilter.bypopularity);

  // final results = await Future.wait([
  //   seasonalAnimeFuture,
  //   previousSeasonAnimeFuture,
  // ]);

  log(topUpcoming.toString());
  log(topAiring.toString());
  log(mostPopular.toString());

  // final seasonalAnimeList = results[0].data;
  // final previousSeasonAnimeList = results[1].data;
  final currentSeasonList = currentSeason.toList();
  final previousSeasonList = previousSeasonJ.toList();
  final mostPopularList = mostPopular.toList();
  final topUpcomingList = topUpcoming.toList();
  final topAiringList = topAiring.toList();

  return CombinedData(
      currentSeasonAnimeList: currentSeasonList,
      previousSeasonAnimeList: previousSeasonList,
      topUpcoming: topUpcomingList,
      topAiring: topAiringList,
      mostPopular: mostPopularList);
});

class CombinedData {
  final List<Anime> currentSeasonAnimeList;
  final List<Anime> previousSeasonAnimeList;
  final List<Anime> topUpcoming;
  final List<Anime> topAiring;
  final List<Anime> mostPopular;

  CombinedData(
      {required this.previousSeasonAnimeList,
      required this.topUpcoming,
      required this.topAiring,
      required this.mostPopular,
      required this.currentSeasonAnimeList});
}
