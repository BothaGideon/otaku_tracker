import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/poster_image_title.dart';

class OtakuTrackerSearchDelegate extends SearchDelegate<void> {
  @override
  String get searchFieldLabel => 'Search anime';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'Clear search',
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResults(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchResults(query: query);
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;

  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return const Center(
        child: Text(
          'Search for an anime title',
          textAlign: TextAlign.center,
        ),
      );
    }

    final searchResultsAsync = ref.watch(animeSearchProvider(trimmedQuery));

    return searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Text(
              'No results for "$trimmedQuery"',
              textAlign: TextAlign.center,
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: results.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            final anime = results[index].node;

            return PosterImageTitle(
              imageUrl: anime.mainPicture?.medium,
              title: anime.title,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => LoadingErrorState(
        onRetry: () => ref.invalidate(animeSearchProvider(trimmedQuery)),
      ),
    );
  }
}
