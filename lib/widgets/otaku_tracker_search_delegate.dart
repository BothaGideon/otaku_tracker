import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/constants/anime_navigation.dart';
import 'package:otaku_tracker/models/response/anime.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/loading_skeletons.dart';
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
      return const _QuickFilterBrowseView();
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

        return _AnimeSearchGrid(results: results);
      },
      loading: () => const SearchResultsSkeleton(),
      error: (error, stack) => LoadingErrorState(
        onRetry: () => ref.invalidate(animeSearchProvider(trimmedQuery)),
      ),
    );
  }
}

extension on AnimeSearchQuickFilter {
  String get label {
    switch (this) {
      case AnimeSearchQuickFilter.topAnime:
        return 'Top anime';
      case AnimeSearchQuickFilter.topRated:
        return 'Top rated';
      case AnimeSearchQuickFilter.recentlyAdded:
        return 'Recently added';
    }
  }

  IconData get icon {
    switch (this) {
      case AnimeSearchQuickFilter.topAnime:
        return Icons.local_fire_department_rounded;
      case AnimeSearchQuickFilter.topRated:
        return Icons.star_rounded;
      case AnimeSearchQuickFilter.recentlyAdded:
        return Icons.new_releases_rounded;
    }
  }

  String get description {
    switch (this) {
      case AnimeSearchQuickFilter.topAnime:
        return 'Popular picks to jump into quickly.';
      case AnimeSearchQuickFilter.topRated:
        return 'Highest-rated anime across MyAnimeList.';
      case AnimeSearchQuickFilter.recentlyAdded:
        return 'Freshly added titles from the anime catalogue.';
    }
  }
}

class _QuickFilterBrowseView extends ConsumerStatefulWidget {
  const _QuickFilterBrowseView();

  @override
  ConsumerState<_QuickFilterBrowseView> createState() =>
      _QuickFilterBrowseViewState();
}

class _QuickFilterBrowseViewState extends ConsumerState<_QuickFilterBrowseView> {
  AnimeSearchQuickFilter selectedFilter = AnimeSearchQuickFilter.topAnime;

  @override
  Widget build(BuildContext context) {
    final filterResultsAsync = ref.watch(
      animeSearchQuickFilterProvider(selectedFilter),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search for an anime title',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Or jump into a curated MAL feed.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: AnimeSearchQuickFilter.values.map((filter) {
                  return ChoiceChip(
                    avatar: Icon(filter.icon, size: 18),
                    label: Text(filter.label),
                    selected: selectedFilter == filter,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Text(
                selectedFilter.description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: filterResultsAsync.when(
            data: (results) => _AnimeSearchGrid(results: results),
            loading: () => const SearchResultsSkeleton(),
            error: (error, stack) => LoadingErrorState(
              onRetry: () => ref.invalidate(
                animeSearchQuickFilterProvider(selectedFilter),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimeSearchGrid extends StatelessWidget {
  final List<AnimeData> results;

  const _AnimeSearchGrid({required this.results});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: results.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisExtent: 320.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemBuilder: (context, index) {
        final anime = results[index].node;

        return InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => openAnimeDetailsPage(context, anime.id),
          child: PosterImageTitle(
            imageUrl: anime.mainPicture?.medium,
            title: anime.title,
            userScore: anime.mean,
            auxiliaryStatValue: anime.numScoringUsers,
            auxiliaryStatIcon: Icons.people_alt_rounded,
          ),
        );
      },
    );
  }
}
