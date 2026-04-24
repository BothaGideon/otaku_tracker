import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/user_anime_item.dart';

class MyListPage extends ConsumerStatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends ConsumerState<MyListPage> {
  String selectedStatus = 'all';
  bool isLoading = false;

  static const List<String> statuses = [
    'all',
    'watching',
    'completed',
    'on_hold',
    'dropped',
    'plan_to_watch'
  ];

  @override
  Widget build(BuildContext context) {
    final oauthService = ref.read(oauthProvider);
    final userDataAsync = ref.watch(userDataProvider);

    return userDataAsync.when(
      data: (userData) {
        if (userData['username'] == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My List')),
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

                              if (result != null &&
                                  !result.startsWith('An error occurred')) {
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
            appBar: AppBar(title: const Text('My List')),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                    items: statuses
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.replaceAll('_', ' ')),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: userAnimeAsync.when(
                    data: (userAnimeList) {
                      final filteredList = selectedStatus == 'all'
                          ? userAnimeList.data
                          : userAnimeList.data
                              .where((item) =>
                                  item.listStatus.status == selectedStatus)
                              .toList();

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
                          return UserAnimeItem(
                              userAnimeData: filteredList[index]);
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
