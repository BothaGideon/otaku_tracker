import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/anime_list_provider.dart';
import '../providers/navigation_index_provider.dart';
import '../widgets/loading_error_state.dart';
import '../widgets/poster_image_title.dart';

class SeasonalPage extends ConsumerWidget {
  const SeasonalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final seasonalAnime = ref.watch(combinedAnimeListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Seasonal Page')),
      body: seasonalAnime.when(
        data: (seasonalAnimeList) {
          return GridView.builder(
            itemBuilder: (BuildContext context, int index) {
              return PosterImageTitle(
                anime: seasonalAnimeList.currentSeasonAnimeList[index],
              );
            },
            itemCount: seasonalAnimeList.currentSeasonAnimeList.length,
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
    );
  }
}
