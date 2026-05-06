import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:otaku_tracker/constants/anime_navigation.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/my_list_filter_provider.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/poster_image_title.dart';

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

    return userDataAsync.when(
      data: (userData) {
        if (userData['username'] == null) {
          return Scaffold(
            appBar: const OtakuTrackerAppBar(title: Text('My List')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
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
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Symbols.login),
                              const SizedBox(width: 8),
                              const Text('Authenticate with MyAnimeList'),
                            ],
                          ),
                  ),
                ],
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
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: MyListStatusFilter.values
                          .map(
                            (status) => ChoiceChip(
                              label: Text(status.label),
                              selected: selectedStatus == status,
                              onSelected: (_) {
                                ref.read(myListFilterProvider.notifier).state =
                                    status;
                              },
                            ),
                          )
                        .toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: userAnimeAsync.when(
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
                          final node = userAnimeData.node;

                          return InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => openAnimeDetailsPage(context, node.id),
                            child: PosterImageTitle(
                              imageUrl: node.mainPicture?.medium,
                              title: node.title,
                              userStatus: userAnimeData.listStatus.status,
                              userScore: userAnimeData.listStatus.score > 0
                                  ? userAnimeData.listStatus.score
                                  : null,
                            ),
                          );
                        },
                      );
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
