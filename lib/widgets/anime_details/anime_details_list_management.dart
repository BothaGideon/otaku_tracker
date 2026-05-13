import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otaku_tracker/models/api/anime/anime.dart';
import 'package:otaku_tracker/providers/anime/anime_list_provider.dart';
import 'package:otaku_tracker/services/anime/anime_list_service.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';
import 'package:otaku_tracker/widgets/shared/loading/loading_skeletons.dart';

class AnimeListManagementSection extends ConsumerStatefulWidget {
  final int animeId;
  final int? totalEpisodes;

  const AnimeListManagementSection({
    super.key,
    required this.animeId,
    required this.totalEpisodes,
  });

  @override
  ConsumerState<AnimeListManagementSection> createState() =>
      _AnimeListManagementSectionState();
}

class _AnimeListManagementSectionState
    extends ConsumerState<AnimeListManagementSection> {
  bool isSubmitting = false;

  Future<void> _openEditor(ListStatus? currentStatus) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => AnimeListStatusEditorSheet(
        animeId: widget.animeId,
        totalEpisodes: widget.totalEpisodes,
        currentStatus: currentStatus,
        onSaved: _handleSave,
      ),
    );
  }

  Future<void> _handleSave(AnimeListStatusUpdate update) async {
    setState(() {
      isSubmitting = true;
    });

    try {
      await ref
          .read(animeListMutationControllerProvider)
          .updateAnimeListEntry(widget.animeId, update);

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
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _removeEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from your list?'),
        content: const Text(
          'This will delete the title from your MyAnimeList anime list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ref
          .read(animeListMutationControllerProvider)
          .removeAnimeListEntry(widget.animeId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from your list.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from your list: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(userDataProvider);
    final viewService = ref.read(animeDetailsViewServiceProvider);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'YOUR LIST',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 12),
            if (isSubmitting) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            userDataAsync.when(
              data: (userData) {
                if (userData['username'] == null) {
                  return const Text(
                    'Log in from the My List page to add this anime, track episodes watched, and rate it on your MAL list.',
                  );
                }

                final listEntryAsync =
                    ref.watch(userAnimeListEntryProvider(widget.animeId));

                return listEntryAsync.when(
                  data: (entry) {
                    final status = entry?.listStatus;
                    final presentation = viewService.buildListEntryPresentation(
                      status,
                      widget.totalEpisodes,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AnimeListInfoChip(
                              icon: Icons.bookmark_rounded,
                              label: presentation.statusLabel,
                            ),
                            _AnimeListInfoChip(
                              icon: Icons.play_circle_rounded,
                              label: presentation.episodesLabel,
                            ),
                            _AnimeListInfoChip(
                              icon: Icons.star_rounded,
                              label: presentation.scoreLabel,
                            ),
                            if (presentation.tags != null)
                              _AnimeListInfoChip(
                                icon: Icons.sell_rounded,
                                label: presentation.tags!,
                              ),
                          ],
                        ),
                        if (presentation.comments != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            presentation.comments!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: isSubmitting
                                  ? null
                                  : () => _openEditor(status),
                              icon: Icon(
                                status == null
                                    ? Icons.add_rounded
                                    : Icons.edit_rounded,
                              ),
                              label: Text(
                                presentation.hasEntry
                                    ? 'Edit entry'
                                    : 'Add to list',
                              ),
                            ),
                            if (presentation.hasEntry)
                              OutlinedButton.icon(
                                onPressed: isSubmitting ? null : _removeEntry,
                                icon: const Icon(Icons.delete_rounded),
                                label: const Text('Remove'),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const AnimeDetailsAccountSectionSkeleton(),
                  error: (error, stack) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Failed to load your list entry: $error'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => ref.invalidate(userAnimeListProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const AnimeDetailsAccountSectionSkeleton(),
              error: (error, stack) => Text(
                'Failed to load account state: $error',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeListStatusEditorSheet extends ConsumerStatefulWidget {
  final int animeId;
  final int? totalEpisodes;
  final ListStatus? currentStatus;
  final Future<void> Function(AnimeListStatusUpdate update) onSaved;

  const AnimeListStatusEditorSheet({
    super.key,
    required this.animeId,
    required this.totalEpisodes,
    required this.currentStatus,
    required this.onSaved,
  });

  @override
  ConsumerState<AnimeListStatusEditorSheet> createState() =>
      _AnimeListStatusEditorSheetState();
}

class _AnimeListStatusEditorSheetState
    extends ConsumerState<AnimeListStatusEditorSheet> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController watchedEpisodesController;
  late final TextEditingController rewatchCountController;
  late final TextEditingController tagsController;
  late final TextEditingController commentsController;
  late String selectedStatus;
  late int selectedScore;
  late int selectedPriority;
  late int selectedRewatchValue;
  late bool isRewatching;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final currentStatus = widget.currentStatus;

    watchedEpisodesController = TextEditingController(
      text: (currentStatus?.numEpisodesWatched ?? 0).toString(),
    );
    rewatchCountController = TextEditingController(
      text: (currentStatus?.numTimesRewatched ?? 0).toString(),
    );
    tagsController = TextEditingController(
      text: currentStatus?.tags ?? '',
    );
    commentsController = TextEditingController(
      text: currentStatus?.comments ?? '',
    );
    selectedStatus = currentStatus?.status ?? 'plan_to_watch';
    selectedScore = currentStatus?.score ?? 0;
    selectedPriority = currentStatus?.priority ?? 0;
    selectedRewatchValue = currentStatus?.rewatchValue ?? 0;
    isRewatching = currentStatus?.isRewatching ?? false;
  }

  @override
  void dispose() {
    watchedEpisodesController.dispose();
    rewatchCountController.dispose();
    tagsController.dispose();
    commentsController.dispose();
    super.dispose();
  }

  int _parseRequiredNonNegativeInt(String value, String fieldName) {
    final parsed = int.tryParse(value.trim());

    if (parsed == null || parsed < 0) {
      throw FormatException('$fieldName must be a non-negative whole number.');
    }

    return parsed;
  }

  Future<void> _save() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final watchedEpisodes = _parseRequiredNonNegativeInt(
      watchedEpisodesController.text,
      'Episodes watched',
    );
    final rewatchCount = _parseRequiredNonNegativeInt(
      rewatchCountController.text,
      'Times rewatched',
    );

    setState(() {
      isSaving = true;
    });

    try {
      await widget.onSaved(
        AnimeListStatusUpdate(
          status: selectedStatus,
          score: selectedScore,
          numWatchedEpisodes: watchedEpisodes,
          isRewatching: isRewatching,
          priority: selectedPriority,
          numTimesRewatched: rewatchCount,
          rewatchValue: selectedRewatchValue,
          tags: tagsController.text.trim(),
          comments: commentsController.text.trim(),
        ),
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
    final totalEpisodes = widget.totalEpisodes;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.currentStatus == null
                    ? 'Add to your list'
                    : 'Update your list entry',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'List status',
                  border: OutlineInputBorder(),
                ),
                items: animeListStatusOptions
                    .map(
                      (status) => DropdownMenuItem(
                        value: status.value,
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
                keyboardType: TextInputType.number,
                enabled: !isSaving,
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
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: isRewatching,
                onChanged: isSaving
                    ? null
                    : (value) {
                        setState(() {
                          isRewatching = value;
                        });
                      },
                title: const Text('Currently rewatching'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Priority 0')),
                  DropdownMenuItem(value: 1, child: Text('Priority 1')),
                  DropdownMenuItem(value: 2, child: Text('Priority 2')),
                ],
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedPriority = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: rewatchCountController,
                keyboardType: TextInputType.number,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Times rewatched',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  final parsed = int.tryParse(trimmed);

                  if (trimmed.isEmpty || parsed == null || parsed < 0) {
                    return 'Enter a non-negative whole number.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedRewatchValue,
                decoration: const InputDecoration(
                  labelText: 'Rewatch value',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  6,
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text('Value $value'),
                  ),
                ),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            selectedRewatchValue = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: tagsController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Tags',
                  hintText: 'Comma-separated tags',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentsController,
                enabled: !isSaving,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Comments',
                  border: OutlineInputBorder(),
                ),
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
                      child: Text(
                        isSaving
                            ? 'Saving...'
                            : widget.currentStatus == null
                                ? 'Add'
                                : 'Save',
                      ),
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

class _AnimeListInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AnimeListInfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
