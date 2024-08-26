import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jikan_api/jikan_api.dart';

import '../constants/anime_seasons_helper.dart';
import '../providers/anime_list_provider.dart';
import '../providers/season_state_provider.dart';
import '../widgets/loading_error_state.dart';
import '../widgets/poster_image_title.dart';

class SeasonalPage extends ConsumerWidget {
  const SeasonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonalAnime = ref.watch(combinedAnimeListProvider);
    final selection = ref.watch(seasonSelectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Seasonal Page')),
      body: Column(
        children: [
          SegmentedButton<SeasonSelectionFilter>(
            segments: const <ButtonSegment<SeasonSelectionFilter>>[
              ButtonSegment<SeasonSelectionFilter>(
                  value: SeasonSelectionFilter.past, label: Text('Past')),
              ButtonSegment<SeasonSelectionFilter>(
                  value: SeasonSelectionFilter.current, label: Text('Current')),
              ButtonSegment<SeasonSelectionFilter>(
                  value: SeasonSelectionFilter.upcoming,
                  label: Text('Upcoming')),
            ],
            selected: selection,
            showSelectedIcon: false,
            onSelectionChanged: (Set<SeasonSelectionFilter> newSelection) {
              ref
                  .read(seasonSelectionProvider.notifier)
                  .updateSelection(newSelection, ref);
            },
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: seasonalAnime.when(
              data: (seasonalAnimeList) {
                List<Anime> selectedAnimeList;
                switch (selection.first) {
                  case SeasonSelectionFilter.past:
                    selectedAnimeList = seasonalAnimeList.previousSeasonAnimeList;
                    break;
                  case SeasonSelectionFilter.upcoming:
                    selectedAnimeList = seasonalAnimeList.upcomingSeasonAnimeList;
                    break;
                  default:
                    selectedAnimeList = seasonalAnimeList.currentSeasonAnimeList;
                    break;
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && seasonalAnimeList.hasMoreData) {
                      ref.read(combinedAnimeListProvider.notifier).loadMoreData(selection.first);
                    }
                    return true;
                  },
                  child: GridView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= selectedAnimeList.length) {
                        // Skeleton loading for additional data
                        return Container(
                          width: 200,
                          height: 300,
                          color: Colors.grey[300],
                        );
                      }

                      final anime = selectedAnimeList[index];
                      return GestureDetector(
                        onTap: () {
                          print('Tapped on ${anime}');
                        },
                        child: PosterImageTitle(
                          anime: selectedAnimeList[index],
                        ),
                      );
                    },
                    itemCount: selectedAnimeList.length + (seasonalAnimeList.hasMoreData ? 1 : 0), // Extra item for loading indicator
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                      childAspectRatio: 0.6,
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => LoadingErrorState(
                onRetry: () {
                  print('Retry pressed');
                  print(error);
                  print(stack);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
