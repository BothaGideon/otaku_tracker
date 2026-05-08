import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/constants/anime_navigation.dart';
import 'package:otaku_tracker/models/response/anime.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/providers/my_list_filter_provider.dart';
import 'package:otaku_tracker/services/anime_list_service.dart';
import 'package:otaku_tracker/widgets/poster_image_title.dart';

class MyListAnimeTile extends StatelessWidget {
  final UserAnimeData userAnimeData;

  const MyListAnimeTile({
    super.key,
    required this.userAnimeData,
  });

  String _episodesLabel() {
    final watchedEpisodes = userAnimeData.listStatus.numEpisodesWatched;
    final totalEpisodes = userAnimeData.node.numEpisodes;

    if (totalEpisodes == null || totalEpisodes <= 0) {
      return '$watchedEpisodes watched';
    }

    return '$watchedEpisodes / $totalEpisodes watched';
  }

  @override
  Widget build(BuildContext context) {
    final node = userAnimeData.node;
    final displayedScore = userAnimeData.listStatus.score > 0
        ? userAnimeData.listStatus.score
        : node.mean;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => openAnimeDetailsPage(context, node.id),
                    child: PosterImageTitle(
                      imageUrl: node.mainPicture?.medium,
                      title: node.title,
                      userStatus: userAnimeData.listStatus.status,
                      userScore: displayedScore,
                      showBottomTitle: false,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: MyListQuickEditButton(
                  userAnimeData: userAnimeData,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          node.title,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          _episodesLabel(),
          style: Theme.of(context).textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

class MyListQuickEditButton extends ConsumerWidget {
  final UserAnimeData userAnimeData;

  const MyListQuickEditButton({
    super.key,
    required this.userAnimeData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Quick edit ${userAnimeData.node.title}',
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => MyListQuickEditSheet(
                userAnimeData: userAnimeData,
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.edit, size: 18),
          ),
        ),
      ),
    );
  }
}

class MyListQuickEditSheet extends ConsumerStatefulWidget {
  final UserAnimeData userAnimeData;

  const MyListQuickEditSheet({
    super.key,
    required this.userAnimeData,
  });

  @override
  ConsumerState<MyListQuickEditSheet> createState() =>
      _MyListQuickEditSheetState();
}

class _MyListQuickEditSheetState extends ConsumerState<MyListQuickEditSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController watchedEpisodesController;
  late String selectedStatus;
  late int selectedScore;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    watchedEpisodesController = TextEditingController(
      text: widget.userAnimeData.listStatus.numEpisodesWatched.toString(),
    );
    selectedStatus = widget.userAnimeData.listStatus.status;
    selectedScore = widget.userAnimeData.listStatus.score;
  }

  @override
  void dispose() {
    watchedEpisodesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final watchedEpisodes =
        int.parse(watchedEpisodesController.text.trim());

    setState(() {
      isSaving = true;
    });

    try {
      await ref.read(animeListMutationControllerProvider).updateAnimeListEntry(
            widget.userAnimeData.node.id,
            AnimeListStatusUpdate(
              status: selectedStatus,
              score: selectedScore,
              numWatchedEpisodes: watchedEpisodes,
            ),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your list entry was updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update your list entry: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalEpisodes = widget.userAnimeData.node.numEpisodes;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick edit',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                widget.userAnimeData.node.title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'List status',
                  border: OutlineInputBorder(),
                ),
                items: MyListStatusFilter.values
                    .where((status) => status != MyListStatusFilter.all)
                    .map(
                      (status) => DropdownMenuItem(
                        value: status.apiValue,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: watchedEpisodesController,
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: totalEpisodes == null
                      ? 'Episodes watched'
                      : 'Episodes watched (out of $totalEpisodes)',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  final parsed = int.tryParse(trimmed);

                  if (trimmed.isEmpty || parsed == null || parsed < 0) {
                    return 'Enter a non-negative whole number.';
                  }

                  if (totalEpisodes != null && parsed > totalEpisodes) {
                    return 'Cannot exceed the total episode count.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedScore,
                decoration: const InputDecoration(
                  labelText: 'Score',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  11,
                  (score) => DropdownMenuItem(
                    value: score,
                    child: Text(
                      score == 0 ? 'Not rated (0)' : '$score / 10',
                    ),
                  ),
                ),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedScore = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 16),
              Text(
                'Advanced fields such as tags, comments, and rewatch options remain available on the anime details page.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isSaving ? null : _save,
                      child: Text(isSaving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
