import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/user_avatar.dart';

class MyProfilePage extends ConsumerWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: const OtakuTrackerAppBar(
        title: Text('My Profile'),
        showProfileAction: false,
      ),
      body: userDataAsync.when(
        data: (userData) {
          final username = userData['username'];
          final picture = userData['picture'];

          if (username == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(radius: 36.0, iconSize: 48.0),
                  SizedBox(height: 16),
                  Text(
                    'Please sign in from My List to view your profile.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserAvatar(
                      pictureUrl: picture,
                      radius: 36.0,
                      iconSize: 48.0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Signed in to MyAnimeList',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadingErrorState(
          onRetry: () => ref.invalidate(userDataProvider),
        ),
      ),
    );
  }
}
