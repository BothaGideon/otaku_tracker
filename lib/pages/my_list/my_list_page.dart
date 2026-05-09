import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/providers/anime/anime_list_provider.dart';
import 'package:otaku_tracker/providers/auth/oauth_provider.dart';
import 'package:otaku_tracker/providers/my_list/my_list_filter_provider.dart';
import 'package:otaku_tracker/widgets/my_list/my_list_anime_tile.dart';
import 'package:otaku_tracker/widgets/my_list/my_list_controls_sheet.dart';
import 'package:otaku_tracker/widgets/my_list/my_list_detail_view.dart';
import 'package:otaku_tracker/widgets/shared/app/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/shared/feedback/loading_error_state.dart';
import 'package:otaku_tracker/widgets/shared/loading/loading_skeletons.dart';

class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  ConsumerState<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage> {
  bool isLoading = false;

  Future<void> _refreshMyList() async {
    final accessToken = await ref.read(oauthProvider).getAccessToken();

    if (accessToken == null) {
      ref.invalidate(userAnimeListProvider);
      return;
    }

    final animeListService = ref.read(animeListServiceProvider);
    animeListService.invalidateUserAnimeList(accessToken);
    ref.invalidate(userAnimeListProvider);
    await ref.read(userAnimeListProvider.future);
  }

  Widget _buildCenteredRefreshableState({
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refreshMyList,
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

  int _compareByLastUpdated(UserAnimeData a, UserAnimeData b) {
    final first = DateTime.tryParse(a.listStatus.updatedAt ?? '');
    final second = DateTime.tryParse(b.listStatus.updatedAt ?? '');

    if (first == null && second == null) {
      return a.node.title.toLowerCase().compareTo(b.node.title.toLowerCase());
    }

    if (first == null) {
      return 1;
    }

    if (second == null) {
      return -1;
    }

    return second.compareTo(first);
  }

  int _compareByTitle(UserAnimeData a, UserAnimeData b) {
    return a.node.title.toLowerCase().compareTo(b.node.title.toLowerCase());
  }

  int _compareByScore(UserAnimeData a, UserAnimeData b) {
    final scoreComparison = b.listStatus.score.compareTo(a.listStatus.score);

    if (scoreComparison != 0) {
      return scoreComparison;
    }

    return _compareByTitle(a, b);
  }

  int _compareByProgress(UserAnimeData a, UserAnimeData b) {
    final progressComparison = b.listStatus.numEpisodesWatched.compareTo(
      a.listStatus.numEpisodesWatched,
    );

    if (progressComparison != 0) {
      return progressComparison;
    }

    return _compareByTitle(a, b);
  }

  int Function(UserAnimeData, UserAnimeData) _comparatorForSort(
      MyListSortOption sortOption) {
    switch (sortOption) {
      case MyListSortOption.lastUpdated:
        return _compareByLastUpdated;
      case MyListSortOption.title:
        return _compareByTitle;
      case MyListSortOption.score:
        return _compareByScore;
      case MyListSortOption.progress:
        return _compareByProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final oauthService = ref.read(oauthProvider);
    final userDataAsync = ref.watch(userDataProvider);
    final selectedStatus = ref.watch(myListFilterProvider);
    final selectedViewMode = ref.watch(myListViewModeProvider);
    final selectedSort = ref.watch(myListSortProvider);

    return userDataAsync.when(
      data: (userData) {
        if (userData['username'] == null) {
          return Scaffold(
            appBar: const OtakuTrackerAppBar(title: Text('My List')),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons/mal_logo_short.png',
                              height: 84,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Log in with MyAnimeList',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Connect your MAL account to sync your list and unlock your profile stats inside Otaku Tracker.',
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                      });

                                      try {
                                        final result = await oauthService.login();

                                        if (!mounted) {
                                          return;
                                        }

                                        if (result != null &&
                                            !result.startsWith('An error occurred')) {
                                          ref.invalidate(userDataProvider);
                                          ref.invalidate(currentUserProfileProvider);
                                          ref.invalidate(userAnimeListProvider);
                                          setState(() {
                                            isLoading = false;
                                          });

                                          Fluttertoast.showToast(
                                            msg: "Login successful",
                                            backgroundColor: Colors.green,
                                          );
                                        } else {
                                          setState(() {
                                            isLoading = false;
                                          });

                                          Fluttertoast.showToast(
                                            msg: result ?? "Login failed",
                                            backgroundColor: Colors.red,
                                          );
                                        }
                                      } catch (e) {
                                        if (!mounted) {
                                          return;
                                        }

                                        setState(() {
                                          isLoading = false;
                                        });

                                        Fluttertoast.showToast(
                                          msg: "Login failed: $e",
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Symbols.login),
                              label: Text(
                                isLoading
                                    ? 'Connecting to MyAnimeList...'
                                    : 'Login with MyAnimeList',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'We do not store your anime data. Otaku Tracker only interacts with the MyAnimeList API on your behalf.',
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          final userAnimeAsync = ref.watch(userAnimeListProvider);

          return Scaffold(
            appBar: const OtakuTrackerAppBar(title: Text('My List')),
            body: Column(
              children: [
                MyListControlsBar(
                  selectedStatus: selectedStatus,
                  selectedSort: selectedSort,
                  selectedViewMode: selectedViewMode,
                  onApply: (selection) async {
                    await ref.read(myListFilterProvider.notifier).setFilter(
                          selection.status,
                        );
                    await ref.read(myListSortProvider.notifier).setSort(
                          selection.sort,
                        );
                    await ref.read(myListViewModeProvider.notifier).setViewMode(
                          selection.viewMode,
                        );
                  },
                ),
                Expanded(
                  child: userAnimeAsync.when(
                    skipLoadingOnRefresh: true,
                    skipLoadingOnReload: true,
                    data: (userAnimeList) {
                      final filteredList =
                          selectedStatus == MyListStatusFilter.all
                          ? userAnimeList.data
                          : userAnimeList.data
                              .where((item) =>
                                  item.listStatus.status ==
                                  selectedStatus.apiValue)
                              .toList();
                      final sortedList = [...filteredList];

                      sortedList.sort(_comparatorForSort(selectedSort));

                      if (sortedList.isEmpty) {
                        return _buildCenteredRefreshableState(
                          child: Text(
                            'No titles in ${selectedStatus.label}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (selectedViewMode == MyListViewMode.detail) {
                        return RefreshIndicator(
                          onRefresh: _refreshMyList,
                          child: MyListDetailView(items: sortedList),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshMyList,
                        child: GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: sortedList.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200.0,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: 0.6,
                            ),
                            itemBuilder: (context, index) {
                              final userAnimeData = sortedList[index];

                              return KeyedSubtree(
                                key: ValueKey(userAnimeData.node.id),
                                child: MyListAnimeTile(
                                  userAnimeData: userAnimeData,
                                ),
                              );
                            }),
                      );
                    },
                    loading: () {
                      if (selectedViewMode == MyListViewMode.detail) {
                        return const MyListDetailListSkeleton();
                      }

                      return const MyListPosterGridSkeleton();
                    },
                    error: (error, stack) => _buildCenteredRefreshableState(
                      child: LoadingErrorState(
                        onRetry: () => _refreshMyList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      loading: () => const Scaffold(
        appBar: OtakuTrackerAppBar(title: Text('My List')),
        body: MyListPageSkeleton(),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading user data: $error')),
      ),
    );
  }
}
