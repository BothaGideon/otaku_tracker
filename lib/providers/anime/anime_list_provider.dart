import 'package:jikan_api/jikan_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/constants/anime/anime_seasons_helper.dart';
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/providers/auth/oauth_provider.dart';
import 'package:otaku_tracker/providers/preferences/content_preferences_provider.dart';
import 'package:otaku_tracker/services/anime/anime_list_service.dart';
import 'package:otaku_tracker/services/anime/seasonal_anime_list_service.dart';
import 'package:otaku_tracker/services/anime/mal_api_cache_service.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';
import 'package:otaku_tracker/services/content/nsfw_content_service.dart';

final malApiCacheServiceProvider = Provider<MalApiCacheService>((ref) {
  return MalApiCacheService(
    ttl: const Duration(minutes: 15),
  );
});

final animeListServiceProvider = Provider<AnimeListService>((ref) {
  return AnimeListService(
    cache: ref.read(malApiCacheServiceProvider),
  );
});

final seasonalAnimeListServiceProvider = Provider<SeasonalAnimeListService>((ref) {
  return SeasonalAnimeListService(
    cache: ref.read(malApiCacheServiceProvider),
  );
});

final combinedAnimeListProvider = FutureProvider<CombinedData>((ref) async {
  final includeNsfw = ref.watch(nsfwPreferenceProvider);
  final animeListService = ref.read(animeListServiceProvider);
  final seasonalAnimeListService = ref.read(seasonalAnimeListServiceProvider);
  final season = AnimeSeasonsHelper().getCurrentSeason();
  final previousSeason = AnimeSeasonsHelper().getPreviousSeason();
  final upcomingSeasonDate = AnimeSeasonsHelper().getUpcomingSeason();

  final responses = await Future.wait([
    seasonalAnimeListService.getSeasonalAnimeList(
      season.year,
      season.seasonType,
      includeNsfw: includeNsfw,
    ),
    seasonalAnimeListService.getSeasonalAnimeList(
      previousSeason.year,
      previousSeason.seasonType,
      includeNsfw: includeNsfw,
    ),
    seasonalAnimeListService.getSeasonalAnimeList(
      upcomingSeasonDate.year,
      upcomingSeasonDate.seasonType,
      includeNsfw: includeNsfw,
    ),
    animeListService.getRankedAnime(
      rankingType: 'upcoming',
      includeNsfw: includeNsfw,
    ),
    animeListService.getRankedAnime(
      rankingType: 'airing',
      includeNsfw: includeNsfw,
    ),
    animeListService.getRankedAnime(
      rankingType: 'bypopularity',
      includeNsfw: includeNsfw,
    ),
  ]);

  return CombinedData(
      currentSeasonAnimeList: responses[0].data,
      previousSeasonAnimeList: responses[1].data,
      upcomingSeasonAnimeList: responses[2].data,
      topUpcoming: responses[3].data,
      topAiring: responses[4].data,
      mostPopular: responses[5].data);
});

class CombinedData {
  final List<AnimeData> currentSeasonAnimeList;
  final List<AnimeData> previousSeasonAnimeList;
  final List<AnimeData> upcomingSeasonAnimeList;
  final List<AnimeData> topUpcoming;
  final List<AnimeData> topAiring;
  final List<AnimeData> mostPopular;

  CombinedData(
      {required this.previousSeasonAnimeList,
      required this.upcomingSeasonAnimeList,
      required this.topUpcoming,
      required this.topAiring,
      required this.mostPopular,
      required this.currentSeasonAnimeList});
}

final userDataProvider = FutureProvider<Map<String, String?>>((ref) async {
  final oauthService = ref.read(oauthProvider);
  final storedUsername = await oauthService.getUsername();
  final accessToken = await oauthService.getAccessToken();
  var picture = await oauthService.getUserPicture();
  final username = storedUsername == null || storedUsername.isEmpty
      ? null
      : storedUsername;

  if (accessToken != null && username != null && (picture == null || picture.isEmpty)) {
    final currentUserData = await oauthService.getCurrentUserData(accessToken);
    picture = currentUserData['picture'] as String?;
    await oauthService.saveUserPicture(picture);
  }

  return {
    'username': username,
    'accessToken': accessToken,
    'picture': picture,
  };
});

final currentUserProfileProvider = FutureProvider<Map<String, Object?>>((ref) async {
  final oauthService = ref.read(oauthProvider);
  final userData = await ref.watch(userDataProvider.future);
  final username = userData['username'];
  final accessToken = userData['accessToken'];
  final cachedPicture = userData['picture'];

  if (accessToken == null || username == null) {
    return {
      'username': username,
      'accessToken': accessToken,
      'picture': cachedPicture,
      'animeStatistics': null,
    };
  }

  final currentUserData = await oauthService.getCurrentUserData(accessToken);
  final picture = currentUserData['picture'] as String? ?? cachedPicture;
  await oauthService.saveUserPicture(picture);

  return {
    'username': currentUserData['username'] as String? ?? username,
    'accessToken': accessToken,
    'picture': picture,
    'animeStatistics': currentUserData['animeStatistics'],
  };
});

final userAnimeListProvider = FutureProvider<UserAnimeListDTO>((ref) async {
  final userData = await ref.watch(userDataProvider.future);
  final accessToken = userData['accessToken'];
  if (accessToken == null) throw Exception('Not logged in');
  final service = ref.read(animeListServiceProvider);
  return service.getUserAnimeList(accessToken);
});

final userAnimeListEntryProvider =
    Provider.family<AsyncValue<UserAnimeData?>, int>((ref, animeId) {
  final userAnimeListAsync = ref.watch(userAnimeListProvider);

  return userAnimeListAsync.whenData((userAnimeList) {
    for (final item in userAnimeList.data) {
      if (item.node.id == animeId) {
        return item;
      }
    }

    return null;
  });
});

final animeListMutationControllerProvider =
    Provider<AnimeListMutationController>((ref) {
  return AnimeListMutationController(ref);
});

class AnimeListMutationController {
  final Ref ref;

  AnimeListMutationController(this.ref);

  Future<ListStatus> updateAnimeListEntry(
    int animeId,
    AnimeListStatusUpdate update,
  ) async {
    final oauthService = ref.read(oauthProvider);
    final accessToken = await oauthService.getAccessToken();

    if (accessToken == null) {
      throw Exception('Not logged in');
    }

    final service = ref.read(animeListServiceProvider);
    final updatedStatus = await service.updateMyAnimeListStatus(
      accessToken,
      animeId,
      update,
    );

    ref.invalidate(userAnimeListProvider);
    ref.invalidate(currentUserProfileProvider);

    return updatedStatus;
  }

  Future<void> removeAnimeListEntry(int animeId) async {
    final oauthService = ref.read(oauthProvider);
    final accessToken = await oauthService.getAccessToken();

    if (accessToken == null) {
      throw Exception('Not logged in');
    }

    final service = ref.read(animeListServiceProvider);
    await service.deleteMyAnimeListStatus(accessToken, animeId);

    ref.invalidate(userAnimeListProvider);
    ref.invalidate(currentUserProfileProvider);
  }
}

final animeSearchProvider =
    FutureProvider.autoDispose.family<List<AnimeData>, String>((ref, query) async {
  final includeNsfw = ref.watch(nsfwPreferenceProvider);
  final trimmedQuery = query.trim();

  if (trimmedQuery.isEmpty) {
    return const [];
  }

  final service = ref.read(animeListServiceProvider);
  final results = await service.searchAnime(
    trimmedQuery,
    includeNsfw: includeNsfw,
  );
  return results.data;
});

enum AnimeSearchQuickFilter {
  topAnime,
  topRated,
  recentlyAdded,
}

final animeSearchQuickFilterProvider =
    FutureProvider.autoDispose.family<List<AnimeData>, AnimeSearchQuickFilter>((
      ref,
      filter,
    ) async {
      final includeNsfw = ref.watch(nsfwPreferenceProvider);
      final service = ref.read(animeListServiceProvider);

      switch (filter) {
        case AnimeSearchQuickFilter.topAnime:
          return (await service.getTopAnime(includeNsfw: includeNsfw)).data;
        case AnimeSearchQuickFilter.topRated:
          return (await service.getTopRatedAnime(includeNsfw: includeNsfw)).data;
        case AnimeSearchQuickFilter.recentlyAdded:
          return (await service.getRecentlyAddedAnime(includeNsfw: includeNsfw))
              .data;
      }
    });

class AnimeDetailsData {
  final Anime anime;
  final List<Recommendation> recommendations;

  AnimeDetailsData({
    required this.anime,
    required this.recommendations,
  });
}

final animeDetailsProvider =
    FutureProvider.autoDispose.family<AnimeDetailsData, int>((ref, animeId) async {
  final jikan = Jikan();
  final includeNsfw = ref.watch(nsfwPreferenceProvider);
  final anime = await jikan.getAnime(animeId);
  ensureAnimeAllowedByNsfwPreference(
    anime,
    includeNsfw: includeNsfw,
  );
  final recommendations = await jikan.getAnimeRecommendations(animeId);

  return AnimeDetailsData(
    anime: anime,
    recommendations: recommendations.toList(),
  );
});

final animeDetailsViewServiceProvider = Provider(
  (ref) => AnimeDetailsViewService(),
);

final animeDetailsViewProvider =
    FutureProvider.autoDispose.family<AnimeDetailsViewData, int>((
      ref,
      animeId,
    ) async {
      final details = await ref.watch(animeDetailsProvider(animeId).future);
      final viewService = ref.read(animeDetailsViewServiceProvider);

      return viewService.buildViewData(
        anime: details.anime,
        recommendations: details.recommendations,
      );
    });
