import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/constants/anime_seasons_helper.dart';
import 'package:riverpod/riverpod.dart';

final combinedAnimeListProvider = FutureProvider<CombinedData>((ref) async {
  final jikan = Jikan();
  final season = AnimeSeasonsHelper().getCurrentSeason();
  final previousSeason = AnimeSeasonsHelper().getPreviousSeason();
  final upcomingSeasonDate = AnimeSeasonsHelper().getUpcomingSeason();

  // current season
  final currentSeason =
      await jikan.getSeason(year: season.year, season: season.seasonType);
  // previous season
  final previousSeasonJ = await jikan.getSeason(
      year: previousSeason.year, season: previousSeason.seasonType);
  //upcoming season
  final upcomingSeason = await jikan.getSeason(
      year: upcomingSeasonDate.year, season: upcomingSeasonDate.seasonType);
  // TODO: suggested for you
  //top upcoming
  final topUpcoming = await jikan.getTopAnime(filter: TopFilter.upcoming);
  //top airing
  final topAiring = await jikan.getTopAnime(filter: TopFilter.airing);
  //most popular
  final mostPopular = await jikan.getTopAnime(filter: TopFilter.bypopularity);

  final currentSeasonList = currentSeason.toList();
  final previousSeasonList = previousSeasonJ.toList();
  final upcomingSeasonList = upcomingSeason.toList();
  final mostPopularList = mostPopular.toList();
  final topUpcomingList = topUpcoming.toList();
  final topAiringList = topAiring.toList();

  return CombinedData(
      currentSeasonAnimeList: currentSeasonList,
      previousSeasonAnimeList: previousSeasonList,
      upcomingSeasonAnimeList: upcomingSeasonList,
      topUpcoming: topUpcomingList,
      topAiring: topAiringList,
      mostPopular: mostPopularList);
});

class CombinedData {
  final List<Anime> currentSeasonAnimeList;
  final List<Anime> previousSeasonAnimeList;
  final List<Anime> upcomingSeasonAnimeList;
  final List<Anime> topUpcoming;
  final List<Anime> topAiring;
  final List<Anime> mostPopular;

  CombinedData(
      {required this.previousSeasonAnimeList,
      required this.upcomingSeasonAnimeList,
      required this.topUpcoming,
      required this.topAiring,
      required this.mostPopular,
      required this.currentSeasonAnimeList});
}
