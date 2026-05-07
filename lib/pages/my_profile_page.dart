import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/user_avatar.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  bool isLoggingOut = false;

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Log out of MyAnimeList?'),
              content: const Text(
                'This will remove your saved session from Otaku Tracker until you sign in again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Log out'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldLogout || !mounted) {
      return;
    }

    setState(() {
      isLoggingOut = true;
    });

    try {
      await ref.read(oauthProvider).logout();
      ref.invalidate(userDataProvider);
      ref.invalidate(currentUserProfileProvider);
      ref.invalidate(userAnimeListProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out of MyAnimeList')),
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: const OtakuTrackerAppBar(
        title: Text('My Profile'),
        showProfileAction: false,
      ),
      body: profileAsync.when(
        data: (profileData) {
          final username = profileData['username'] as String?;
          final picture = profileData['picture'] as String?;
          final animeStatistics =
              profileData['animeStatistics'] as Map<String, num?>?;

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

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      UserAvatar(
                        pictureUrl: picture,
                        radius: 40.0,
                        iconSize: 52.0,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Signed in to MyAnimeList',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your anime journey',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A few nice-to-know stats from your MyAnimeList profile.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 180,
                            child: _ProfileJourneyStatCard(
                              label: 'Episodes watched',
                              value: _formatEpisodes(
                                animeStatistics?['numEpisodes'],
                              ),
                              icon: Icons.live_tv_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: _ProfileJourneyStatCard(
                              label: 'Days spent watching',
                              value: _formatDaysWatched(
                                animeStatistics?['numDaysWatched'],
                              ),
                              icon: Icons.schedule_rounded,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: _ProfileJourneyStatCard(
                              label: 'Mean completed score',
                              value: _formatMeanScore(
                                animeStatistics?['meanScore'],
                              ),
                              icon: Icons.star_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .errorContainer
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Need to switch accounts or disconnect this device? Logging out clears your saved MyAnimeList session from Otaku Tracker.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: isLoggingOut ? null : _handleLogout,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        ),
                        icon: isLoggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.logout_rounded),
                        label: Text(
                          isLoggingOut ? 'Logging out...' : 'Log out',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadingErrorState(
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
      ),
    );
  }
}

class _ProfileJourneyStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileJourneyStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatEpisodes(num? episodes) {
  final value = episodes?.toInt();
  return value == null ? 'N/A' : '$value';
}

String _formatDaysWatched(num? daysWatched) {
  if (daysWatched == null) {
    return 'N/A';
  }

  return daysWatched.toStringAsFixed(1);
}

String _formatMeanScore(num? meanScore) {
  if (meanScore == null) {
    return 'N/A';
  }

  return meanScore.toStringAsFixed(2);
}
