import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/content_preferences_provider.dart';
import 'package:otaku_tracker/providers/oauth_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/loading_skeletons.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/user_avatar.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  bool isLoggingOut = false;

  Widget _buildContentPreferencesCard(bool showNsfwContent) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content preferences',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose whether Otaku Tracker should fetch and display NSFW anime results in search, browsing, and detail views on this device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show NSFW content'),
              subtitle: Text(
                showNsfwContent
                    ? 'NSFW anime can appear in supported app surfaces.'
                    : 'NSFW anime is hidden where the app can filter it.',
              ),
              value: showNsfwContent,
              onChanged: (value) {
                ref.read(nsfwPreferenceProvider.notifier).setEnabled(value);
              },
            ),
          ],
        ),
      ),
    );
  }

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
    final showNsfwContent = ref.watch(nsfwPreferenceProvider);

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
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        UserAvatar(radius: 36.0, iconSize: 48.0),
                        SizedBox(height: 16),
                        Text(
                          'Please sign in from My List to view your profile.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildContentPreferencesCard(showNsfwContent),
              ],
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
              _buildContentPreferencesCard(showNsfwContent),
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
                        'A live snapshot of the anime statistics from your MyAnimeList profile.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      if (animeStatistics == null)
                        _ProfileStatsUnavailableCard()
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: _ProfileJourneyStatCard(
                                    label: 'Episodes watched',
                                    value: _formatEpisodes(
                                      animeStatistics['numEpisodes'],
                                    ),
                                    icon: Icons.live_tv_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: _ProfileJourneyStatCard(
                                    label: 'Days spent watching',
                                    value: _formatDaysWatched(
                                      animeStatistics['numDaysWatched'],
                                    ),
                                    icon: Icons.schedule_rounded,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: _ProfileJourneyStatCard(
                                    label: 'Mean completed score',
                                    value: _formatMeanScore(
                                      animeStatistics['meanScore'],
                                    ),
                                    icon: Icons.star_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'List breakdown',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _ProfileListBreakdownTile(
                                  label: 'Watching',
                                  value: _formatCount(
                                    animeStatistics['numItemsWatching'],
                                  ),
                                  icon: Icons.play_circle_fill_rounded,
                                ),
                                _ProfileListBreakdownTile(
                                  label: 'Completed',
                                  value: _formatCount(
                                    animeStatistics['numItemsCompleted'],
                                  ),
                                  icon: Icons.check_circle_rounded,
                                ),
                                _ProfileListBreakdownTile(
                                  label: 'On hold',
                                  value: _formatCount(
                                    animeStatistics['numItemsOnHold'],
                                  ),
                                  icon: Icons.pause_circle_rounded,
                                ),
                                _ProfileListBreakdownTile(
                                  label: 'Dropped',
                                  value: _formatCount(
                                    animeStatistics['numItemsDropped'],
                                  ),
                                  icon: Icons.cancel_rounded,
                                ),
                                _ProfileListBreakdownTile(
                                  label: 'Plan to watch',
                                  value: _formatCount(
                                    animeStatistics['numItemsPlanToWatch'],
                                  ),
                                  icon: Icons.bookmark_rounded,
                                ),
                                _ProfileListBreakdownTile(
                                  label: 'Total entries',
                                  value: _formatCount(
                                    animeStatistics['numItems'],
                                  ),
                                  icon: Icons.collections_bookmark_rounded,
                                ),
                                _ProfileListBreakdownTile(
                                  label: 'Rewatches',
                                  value: _formatCount(
                                    animeStatistics['numTimesRewatched'],
                                  ),
                                  icon: Icons.replay_rounded,
                                ),
                              ],
                            ),
                          ],
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
                        'Disclaimer',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Otaku Tracker pulls these details directly from the MyAnimeList API whenever your session is active.',
                        style: Theme.of(context).textTheme.bodyMedium,
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
                      .surfaceContainer
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Need to switch accounts or disconnect this device? Logging out clears your saved MyAnimeList session from Otaku Tracker.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
        loading: () => const MyProfilePageSkeleton(),
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
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatsUnavailableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'We could not load your anime statistics from MyAnimeList right now. Pull to retry or reopen your profile after your session finishes refreshing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileListBreakdownTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileListBreakdownTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
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

String _formatCount(num? value) {
  final count = value?.toInt();
  return count == null ? 'N/A' : '$count';
}
