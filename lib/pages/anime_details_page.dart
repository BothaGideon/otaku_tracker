import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/widgets/anime_details_content.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadingErrorState(
          onRetry: () => ref.invalidate(animeDetailsProvider(animeId)),
        ),
      ),
    );
  }
}
