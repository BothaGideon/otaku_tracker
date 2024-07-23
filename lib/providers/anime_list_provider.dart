import 'package:riverpod/riverpod.dart';

import '../models/response/anime_list.dart';
import '../pages/landing/LandingPageService.dart';

final animeListProvider = FutureProvider<AnimeList>((ref) async {
  final service = LandingPageService();
  return service.getAnimeList();
});
