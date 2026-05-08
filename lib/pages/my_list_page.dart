import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/my_list_filter_provider.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/widgets/my_list_detail_view.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/my_list_anime_tile.dart';

class MyListPage extends ConsumerStatefulWidget {
  const MyListPage({super.key});

  @override
  ConsumerState<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final oauthService = ref.read(oauthProvider);
    final userDataAsync = ref.watch(userDataProvider);
    final selectedStatus = ref.watch(myListFilterProvider);
    final selectedViewMode = ref.watch(myListViewModeProvider);

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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final controls = [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: MyListStatusFilter.values
                              .map(
                                (status) => ChoiceChip(
                                  label: Text(status.label),
                                  selected: selectedStatus == status,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    ref.read(myListFilterProvider.notifier).state =
                                        status;
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        SegmentedButton<MyListViewMode>(
                          segments: MyListViewMode.values
                              .map(
                                (viewMode) => ButtonSegment<MyListViewMode>(
                                  value: viewMode,
                                  label: Text(viewMode.label),
                                ),
                              )
                              .toList(),
                          selected: {selectedViewMode},
                          onSelectionChanged: (selection) {
                            if (selection.isNotEmpty) {
                              ref.read(myListViewModeProvider.notifier).state =
                                  selection.first;
                            }
                          },
                        ),
                      ];

                      if (constraints.maxWidth < 720) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            controls.first,
                            const SizedBox(height: 12),
                            controls.last,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: controls.first),
                          const SizedBox(width: 12),
                          controls.last,
                        ],
                      );
                    },
                  ),
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

                      if (filteredList.isEmpty) {
                        return Center(
                          child: Text(
                            'No titles in ${selectedStatus.label}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (selectedViewMode == MyListViewMode.detail) {
                        return MyListDetailView(items: filteredList);
                      }

                      return GridView.builder(
                          itemCount: filteredList.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200.0,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (context, index) {
                            final userAnimeData = filteredList[index];

                            return KeyedSubtree(
                              key: ValueKey(userAnimeData.node.id),
                              child: MyListAnimeTile(
                                userAnimeData: userAnimeData,
                              ),
                            );
                          });
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => LoadingErrorState(
                      onRetry: () {
                        // Retry logic if needed
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error loading user data: $error')),
      ),
    );
  }
}
