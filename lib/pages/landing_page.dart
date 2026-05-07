import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/constants/anime_seasons_helper.dart';
import 'package:otaku_tracker/models/response/anime.dart';
import 'package:otaku_tracker/widgets/horizontal_carousel.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';

import '../providers/anime_list_provider.dart';

class LandingPage extends ConsumerWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MAL API calls
    final combinedListAsyncValue = ref.watch(combinedAnimeListProvider);
    final currentSeason =
        '${StringUtils.capitalize(AnimeSeasonsHelper().getCurrentSeason().seasonType.name)} ${AnimeSeasonsHelper().getCurrentSeason().year}';
    final previousSeason =
        '${StringUtils.capitalize(AnimeSeasonsHelper().getPreviousSeason().seasonType.name)} ${AnimeSeasonsHelper().getPreviousSeason().year}';

    return Scaffold(
      appBar: const OtakuTrackerAppBar(
        title: Text('Anime List'),
      ),
      body: combinedListAsyncValue.when(
        data: (combinedList) {
          return ReorderableListView(
              children: [
                HorizontalCarousel(
                  key: const ValueKey(1),
                  animeList: combinedList.currentSeasonAnimeList,
                  title: 'Current season',
                  subtitle: currentSeason,
                ),
                HorizontalCarousel(
                  key: const ValueKey(2),
                  animeList: combinedList.previousSeasonAnimeList,
                  title: 'Previous season',
                  subtitle: previousSeason,
                ),
                HorizontalCarousel(
                  key: const ValueKey(3),
                  animeList:
                      combinedList.previousSeasonAnimeList.where((anime) {
                    return anime.airing == true;
                  }).toList(),
                  title: 'Leftovers',
                  subtitle: previousSeason,
                ),
                HorizontalCarousel(
                  key: const ValueKey(4),
                  animeList: combinedList.topUpcoming,
                  title: 'Top upcoming',
                ),
                HorizontalCarousel(
                  key: const ValueKey(5),
                  animeList: combinedList.topAiring,
                  title: 'Top airing',
                ),
                HorizontalCarousel(
                  key: const ValueKey(6),
                  animeList: combinedList.mostPopular,
                  title: 'Most popular',
                )
              ],
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                // final int item = carouselListOrderValues.removeAt(oldIndex);
                // _items.insert(newIndex, item);
              });
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadingErrorState(
          onRetry: () => ref.invalidate(combinedAnimeListProvider),
        ),
      ),
    );
  }
}

class ScrollingList extends StatelessWidget {
  const ScrollingList({
    super.key,
    required this.mainPicture,
    required this.anime,
  });

  final MainPicture? mainPicture;
  final Node anime;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: mainPicture != null
          ? FadeInImage.assetNetwork(
              placeholder: 'assets/icons/logo_black.png',
              image: mainPicture!.medium,
              fit: BoxFit.cover,
              width: 50.0,
              height: 50.0,
            )
          : Container(
              width: 50.0,
              height: 50.0,
              color: Colors.grey,
              child: const Icon(Icons.image_not_supported),
            ),
      title: Text(anime.title),
      onTap: () {},
    );
  }
}
