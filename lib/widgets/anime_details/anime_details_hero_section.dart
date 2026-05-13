import 'package:flutter/material.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_metadata_panel.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_score_panel.dart';
import 'package:otaku_tracker/widgets/shared/loading/network_image_skeleton.dart';

class AnimeDetailsHeroSection extends StatelessWidget {
  final AnimeDetailsViewData details;

  const AnimeDetailsHeroSection({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeroWidth =
            constraints.maxWidth > 1040 ? 1040.0 : constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxHeroWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 20.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 720;

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 220,
                            child: AnimeDetailsHeroPoster(
                              imageUrl: details.imageUrl,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: AnimeDetailsHeroContent(
                              details: details,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          child: AnimeDetailsHeroPoster(
                            imageUrl: details.imageUrl,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimeDetailsHeroContent(details: details),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimeDetailsHeroContent extends StatelessWidget {
  final AnimeDetailsViewData details;

  const AnimeDetailsHeroContent({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = Colors.white;
    final subtitleColor = Colors.white70;
    final metadata = details.heroBadges
        .map(
          (badge) => AnimeDetailsInfoBadge(
            icon: _iconForHeroBadge(badge.kind),
            label: badge.label,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          details.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (details.japaneseTitle != null) ...[
          const SizedBox(height: 8),
          Text(
            details.japaneseTitle!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: subtitleColor,
                ),
          ),
        ],
        if (details.synonymsLine != null) ...[
          const SizedBox(height: 8),
          Text(
            details.synonymsLine!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AnimeDetailsScorePanel(stats: details.heroStats),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: metadata,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AnimeDetailsMetadataPanel(
            rows: details.metadataRows,
            labelColor: subtitleColor,
            valueColor: titleColor,
          ),
        ),
      ],
    );
  }

  IconData _iconForHeroBadge(AnimeDetailsHeroBadgeKind kind) {
    switch (kind) {
      case AnimeDetailsHeroBadgeKind.type:
        return Icons.movie_rounded;
      case AnimeDetailsHeroBadgeKind.status:
        return Icons.schedule_rounded;
      case AnimeDetailsHeroBadgeKind.episodes:
        return Icons.live_tv_rounded;
      case AnimeDetailsHeroBadgeKind.season:
        return Icons.calendar_month_rounded;
    }
  }
}

class AnimeDetailsHeroPoster extends StatelessWidget {
  final String imageUrl;

  const AnimeDetailsHeroPoster({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        height: 260.0,
        width: double.infinity,
        child: NetworkImageSkeleton(
          imageUrl: hasImage ? imageUrl : null,
        ),
      ),
    );
  }
}

class AnimeDetailsInfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const AnimeDetailsInfoBadge({
    super.key,
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
