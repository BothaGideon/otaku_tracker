import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:otaku_tracker/constants/anime/anime_navigation.dart';
import 'package:otaku_tracker/constants/anime/anime_seasons_helper.dart';
import 'package:otaku_tracker/providers/anime/season_state_provider.dart';
import 'package:otaku_tracker/providers/anime/seasonal_anime_provider.dart';
import 'package:otaku_tracker/widgets/anime/cards/poster_image_title.dart';
import 'package:otaku_tracker/widgets/shared/app/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/shared/feedback/loading_error_state.dart';
import 'package:otaku_tracker/widgets/shared/loading/loading_skeletons.dart';

class SeasonalPage extends ConsumerStatefulWidget {
  const SeasonalPage({super.key});

  @override
  ConsumerState<SeasonalPage> createState() => _SeasonalPageState();
}

class _SeasonalPageState extends ConsumerState<SeasonalPage> {
  late final ScrollController _scrollController;

  Future<void> _refreshSeasonalAnime() async {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    await ref.read(seasonalAnimePaginationProvider.notifier).refresh();
  }

  Widget _buildCenteredRefreshableState({
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refreshSeasonalAnime,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(seasonalAnimePaginationProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final seasonalAnimeState = ref.watch(seasonalAnimePaginationProvider);
    final selection = ref.watch(seasonSelectionProvider);

    return Scaffold(
      appBar: const OtakuTrackerAppBar(title: Text('Seasonal Page')),
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
                  .updateSelection(newSelection);
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(0);
              }
            },
          ),
          const SizedBox(
            height: 10.0,
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (seasonalAnimeState.isInitialLoading) {
                  return const PosterGridSkeleton();
                }

                if (seasonalAnimeState.initialError != null) {
                  return _buildCenteredRefreshableState(
                    child: LoadingErrorState(
                      onRetry: _refreshSeasonalAnime,
                    ),
                  );
                }

                if (seasonalAnimeState.items.isEmpty) {
                  return _buildCenteredRefreshableState(
                    child: const Text('No anime found for this season'),
                  );
                }

                final itemCount = seasonalAnimeState.items.length +
                    (seasonalAnimeState.isLoadingMore ||
                            seasonalAnimeState.loadMoreError != null
                        ? 1
                        : 0);

                return RefreshIndicator(
                  onRefresh: _refreshSeasonalAnime,
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: itemCount,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisExtent: 308.0,
                      mainAxisSpacing: 10.0,
                      crossAxisSpacing: 10.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= seasonalAnimeState.items.length) {
                        if (seasonalAnimeState.loadMoreError != null) {
                          return Card(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Could not load more titles.',
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                      onPressed: () => ref
                                          .read(seasonalAnimePaginationProvider.notifier)
                                          .loadNextPage(),
                                      child: const Text('Try again'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final anime = seasonalAnimeState.items[index].node;
                      final imageUrl =
                          anime.mainPicture?.large ?? anime.mainPicture?.medium;

                      return GestureDetector(
                        onTap: () {
                          openAnimeDetailsPage(context, anime.id);
                        },
                        child: PosterImageTitle(
                          imageUrl: imageUrl,
                          title: anime.title,
                          userScore: anime.mean,
                          auxiliaryStatValue: anime.numListUsers,
                          showAuxiliaryStatWhenNoStatus: false,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
