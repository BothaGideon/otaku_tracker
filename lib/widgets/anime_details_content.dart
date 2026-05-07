import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:otaku_tracker/constants/anime_navigation.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';

class AnimeDetailsContent extends StatelessWidget {
  final AnimeDetailsData details;

  const AnimeDetailsContent({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final anime = details.anime;
    final title = anime.titleEnglish ?? anime.title;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimeDetailsHeroSection(
            anime: anime,
            title: title,
          ),
          const SizedBox(height: 24),
          AnimeDetailsTextSection(
            title: 'Synopsis',
            content: anime.synopsis?.trim().isNotEmpty == true
                ? anime.synopsis!.trim()
                : 'No synopsis available for this title yet.',
          ),
          if (anime.background?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 16),
            AnimeDetailsTextSection(
              title: 'Background',
              content: anime.background!.trim(),
              isBodyLarge: false,
            ),
          ],
          const SizedBox(height: 16),
          AnimeDetailsRelationsSection(relations: anime.relations),
          const SizedBox(height: 16),
          AnimeDetailsRecommendationsSection(
            recommendations: details.recommendations,
          ),
        ],
      ),
    );
  }
}

class AnimeDetailsHeroSection extends StatelessWidget {
  final Anime anime;
  final String title;

  const AnimeDetailsHeroSection({
    super.key,
    required this.anime,
    required this.title,
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
                              imageUrl: anime.imageUrl,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: AnimeDetailsHeroContent(
                              anime: anime,
                              title: title,
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
                            imageUrl: anime.imageUrl,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimeDetailsHeroContent(
                          anime: anime,
                          title: title,
                        ),
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
  final Anime anime;
  final String title;

  const AnimeDetailsHeroContent({
    super.key,
    required this.anime,
    required this.title,
  });

  String? _formatSeason() {
    if (anime.season == null || anime.year == null) {
      return null;
    }

    final season = anime.season!;
    return '${season[0].toUpperCase()}${season.substring(1)} ${anime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = Colors.white;
    final subtitleColor = Colors.white70;
    final metadata = <Widget>[
      AnimeDetailsInfoBadge(
        icon: Symbols.star_rounded,
        label: anime.score?.toStringAsFixed(2) ?? 'N/A',
      ),
      AnimeDetailsInfoBadge(
        icon: Symbols.leaderboard_rounded,
        label: anime.rank != null ? '#${anime.rank}' : 'Unranked',
      ),
      AnimeDetailsInfoBadge(
        icon: Symbols.thumb_up_rounded,
        label: anime.popularity != null ? '#${anime.popularity}' : 'N/A',
      ),
      if (anime.type != null)
        AnimeDetailsInfoBadge(
          icon: Symbols.movie_rounded,
          label: anime.type!,
        ),
      if (anime.status != null)
        AnimeDetailsInfoBadge(
          icon: Symbols.schedule_rounded,
          label: anime.status!,
        ),
      if (anime.episodes != null)
        AnimeDetailsInfoBadge(
          icon: Symbols.live_tv_rounded,
          label: '${anime.episodes} eps',
        ),
      if (_formatSeason() != null)
        AnimeDetailsInfoBadge(
          icon: Symbols.calendar_month_rounded,
          label: _formatSeason()!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (anime.titleJapanese?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            anime.titleJapanese!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: subtitleColor,
                ),
          ),
        ],
        if (anime.titleSynonyms.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            anime.titleSynonyms.take(3).join(' • '),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                ),
          ),
        ],
        const SizedBox(height: 16),
        AnimeDetailsScorePanel(anime: anime),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: metadata,
        ),
        const SizedBox(height: 16),
        AnimeDetailsMetadataPanel(
          anime: anime,
          labelColor: subtitleColor,
          valueColor: titleColor,
        ),
      ],
    );
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
      child: hasImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 260.0,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 260.0,
                  width: double.infinity,
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            )
          : Container(
              height: 260.0,
              width: double.infinity,
              color: Colors.grey,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported),
            ),
    );
  }
}

class AnimeDetailsScorePanel extends StatelessWidget {
  final Anime anime;

  const AnimeDetailsScorePanel({
    super.key,
    required this.anime,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: [
            AnimeDetailsHeroStat(
              label: 'User score',
              value: anime.score?.toStringAsFixed(2) ?? 'N/A',
              icon: Symbols.star_rounded,
            ),
            AnimeDetailsHeroStat(
              label: 'Rank',
              value: anime.rank != null ? '#${anime.rank}' : 'Unranked',
              icon: Symbols.leaderboard_rounded,
            ),
            AnimeDetailsHeroStat(
              label: 'Popularity',
              value: anime.popularity != null ? '#${anime.popularity}' : 'N/A',
              icon: Symbols.thumb_up_rounded,
            ),
            AnimeDetailsHeroStat(
              label: 'Members',
              value: anime.members?.toString() ?? 'N/A',
              icon: Symbols.groups_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeDetailsHeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const AnimeDetailsHeroStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimeDetailsMetadataPanel extends StatelessWidget {
  final Anime anime;
  final Color? labelColor;
  final Color? valueColor;

  const AnimeDetailsMetadataPanel({
    super.key,
    required this.anime,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimeDetailsLabelValueText(
              label: 'Studios',
              value: anime.studios.isNotEmpty
                  ? anime.studios.map((studio) => studio.name).join(', ')
                  : 'Unknown',
              labelColor: labelColor,
              valueColor: valueColor,
            ),
            AnimeDetailsLabelValueText(
              label: 'Genres',
              value: anime.genres.isNotEmpty
                  ? anime.genres.map((genre) => genre.name).join(', ')
                  : 'Unknown',
              labelColor: labelColor,
              valueColor: valueColor,
            ),
            if (anime.duration?.isNotEmpty == true)
              AnimeDetailsLabelValueText(
                label: 'Duration',
                value: anime.duration!,
                labelColor: labelColor,
                valueColor: valueColor,
              ),
            if (anime.rating?.isNotEmpty == true)
              AnimeDetailsLabelValueText(
                label: 'Rating',
                value: anime.rating!,
                labelColor: labelColor,
                valueColor: valueColor,
              ),
            if (anime.source?.isNotEmpty == true)
              AnimeDetailsLabelValueText(
                label: 'Source',
                value: anime.source!,
                labelColor: labelColor,
                valueColor: valueColor,
              ),
          ],
        ),
      ),
    );
  }
}

class AnimeDetailsTextSection extends StatelessWidget {
  final String title;
  final String content;
  final bool isBodyLarge;

  const AnimeDetailsTextSection({
    super.key,
    required this.title,
    required this.content,
    this.isBodyLarge = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimeDetailsSectionCard(
      title: title,
      child: Text(
        content,
        style: isBodyLarge
            ? Theme.of(context).textTheme.bodyLarge
            : Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class AnimeDetailsRelationsSection extends StatelessWidget {
  final BuiltList<Relation>? relations;

  const AnimeDetailsRelationsSection({
    super.key,
    required this.relations,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRelations = relations?.take(12).toList() ?? const [];

    return AnimeDetailsSectionCard(
      title: 'Related media',
      child: visibleRelations.isEmpty
          ? const Text('No related media listed.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: visibleRelations
                  .map(
                    (relation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AnimeDetailsRelationGroup(relation: relation),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class AnimeDetailsRecommendationsSection extends StatelessWidget {
  final List<Recommendation> recommendations;

  const AnimeDetailsRecommendationsSection({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final visibleRecommendations = recommendations.take(10).toList();

    return AnimeDetailsSectionCard(
      title: 'Recommended next',
      child: visibleRecommendations.isEmpty
          ? const Text('No recommendations available.')
          : SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visibleRecommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final recommendation = visibleRecommendations[index];
                  return AnimeDetailsRecommendationCard(
                    recommendation: recommendation,
                  );
                },
              ),
            ),
    );
  }
}

class AnimeDetailsRecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const AnimeDetailsRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openAnimeDetailsPage(context, recommendation.entry.malId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: recommendation.entry.imageUrl.isNotEmpty
                  ? Image.network(
                      recommendation.entry.imageUrl,
                      height: 180,
                      width: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: 140,
                          color: Colors.grey,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      width: 140,
                      color: Colors.grey,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                recommendation.entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${recommendation.votes} votes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeDetailsRelationGroup extends StatelessWidget {
  final Relation relation;

  const AnimeDetailsRelationGroup({
    super.key,
    required this.relation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          relation.relation,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            children: relation.entry
                .map(
                  (entry) => ActionChip(
                    label: Text(entry.name),
                    onPressed: entry.type.toLowerCase() == 'anime'
                        ? () => openAnimeDetailsPage(context, entry.malId)
                        : null,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class AnimeDetailsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const AnimeDetailsSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
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
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeDetailsLabelValueText extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const AnimeDetailsLabelValueText({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
