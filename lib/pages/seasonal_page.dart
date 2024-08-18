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
                    selectedAnimeList =
                        seasonalAnimeList.previousSeasonAnimeList;
                    break;
                  case SeasonSelectionFilter.upcoming:
                    selectedAnimeList =
                        seasonalAnimeList.upcomingSeasonAnimeList;
                    break;
                  default:
                    selectedAnimeList =
                        seasonalAnimeList.currentSeasonAnimeList;
                    // Add logic to fetch current season anime
                    break;
                }

                return GridView.builder(
                  itemBuilder: (BuildContext context, int index) {
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
                  itemCount: selectedAnimeList.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 0.6,
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
