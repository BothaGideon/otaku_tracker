import 'package:jikan_api/jikan_api.dart';

class NsfwContentHiddenException implements Exception {
  final String message;

  const NsfwContentHiddenException([
    this.message =
        'This title is hidden because NSFW content is disabled in your profile settings.',
  ]);

  @override
  String toString() => message;
}

bool isNsfwAnime(Anime anime) {
  final rating = anime.rating?.trim().toLowerCase() ?? '';

  if (rating.startsWith('rx') || rating.startsWith('r+')) {
    return true;
  }

  if (anime.explicitGenres.isNotEmpty) {
    return true;
  }

  return false;
}

List<Anime> filterAnimeByNsfwPreference(
  List<Anime> animeList, {
  required bool includeNsfw,
}) {
  if (includeNsfw) {
    return animeList;
  }

  return animeList.where((anime) => !isNsfwAnime(anime)).toList();
}

void ensureAnimeAllowedByNsfwPreference(
  Anime anime, {
  required bool includeNsfw,
}) {
  if (!includeNsfw && isNsfwAnime(anime)) {
    throw const NsfwContentHiddenException();
  }
}
