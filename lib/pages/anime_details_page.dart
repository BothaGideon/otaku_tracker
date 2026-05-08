import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/services/nsfw_content_service.dart';
import 'package:otaku_tracker/widgets/anime_details_content.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/loading_skeletons.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';

class AnimeDetailsPage extends ConsumerWidget {
  final int animeId;

  const AnimeDetailsPage({
    super.key,
    required this.animeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeDetailsAsync = ref.watch(animeDetailsViewProvider(animeId));

    return Scaffold(
      appBar: const OtakuTrackerAppBar(title: Text('Anime Details')),
      body: animeDetailsAsync.when(
        data: (details) => AnimeDetailsContent(details: details),
        loading: () => const AnimeDetailsPageSkeleton(),
        error: (error, stack) {
          if (error is NsfwContentHiddenException) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.visibility_off_rounded, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            'NSFW content is hidden',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.message,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return LoadingErrorState(
            onRetry: () => ref.invalidate(animeDetailsProvider(animeId)),
          );
        },
      ),
    );
  }
}
