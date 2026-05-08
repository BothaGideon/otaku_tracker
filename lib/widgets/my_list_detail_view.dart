import 'package:flutter/material.dart';
import 'package:otaku_tracker/constants/anime_navigation.dart';
import 'package:otaku_tracker/models/response/anime.dart';
import 'package:otaku_tracker/widgets/my_list_anime_tile.dart';

class MyListDetailView extends StatelessWidget {
  final List<UserAnimeData> items;

  const MyListDetailView({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => index == 0
          ? const SizedBox(height: 8)
          : const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _MyListDetailHeader();
        }

        final userAnimeData = items[index - 1];

        return MyListDetailRow(
          key: ValueKey(userAnimeData.node.id),
          userAnimeData: userAnimeData,
        );
      },
    );
  }
}

class MyListDetailRow extends StatelessWidget {
  final UserAnimeData userAnimeData;

  const MyListDetailRow({
    super.key,
    required this.userAnimeData,
  });

  String _formatStatusText(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _episodesLabel() {
    final watchedEpisodes = userAnimeData.listStatus.numEpisodesWatched;
    final totalEpisodes = userAnimeData.node.numEpisodes;

    if (totalEpisodes == null || totalEpisodes <= 0) {
      return '$watchedEpisodes watched';
    }

    return '$watchedEpisodes / $totalEpisodes';
  }

  String _scoreLabel() {
    final score = userAnimeData.listStatus.score;
    final fallback = userAnimeData.node.mean;

    if (score > 0) {
      return '$score / 10';
    }

    if (fallback != null && fallback > 0) {
      return '${fallback.toStringAsFixed(1)} avg';
    }

    return 'Not rated';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = userAnimeData.node;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => openAnimeDetailsPage(context, node.id),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: node.mainPicture?.medium != null
                    ? Image.network(
                        node.mainPicture!.medium,
                        width: 72,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 72,
                            height: 100,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      )
                    : Container(
                        width: 72,
                        height: 100,
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _DetailStat(
                          label: 'Status',
                          value: _formatStatusText(userAnimeData.listStatus.status),
                        ),
                        _DetailStat(
                          label: 'Progress',
                          value: _episodesLabel(),
                        ),
                        _DetailStat(
                          label: 'Score',
                          value: _scoreLabel(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MyListQuickEditButton(
                userAnimeData: userAnimeData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyListDetailHeader extends StatelessWidget {
  const _MyListDetailHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          Text(
            'Title',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Status',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Progress',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Score',
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;

  const _DetailStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
