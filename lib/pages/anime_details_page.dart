import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:otaku_tracker/providers/anime_list_provider.dart';
import 'package:otaku_tracker/widgets/loading_error_state.dart';
import 'package:otaku_tracker/widgets/otaku_tracker_app_bar.dart';
import 'package:otaku_tracker/widgets/poster_image_title.dart';

class AnimeDetailsPage extends ConsumerWidget {
  final int animeId;

  const AnimeDetailsPage({
    super.key,
    required this.animeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeDetailsAsync = ref.watch(animeDetailsProvider(animeId));

    return Scaffold(
      appBar: const OtakuTrackerAppBar(title: Text('Anime Details')),
      body: animeDetailsAsync.when(
        data: (details) => _AnimeDetailsView(details: details),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => LoadingErrorState(
          onRetry: () => ref.invalidate(animeDetailsProvider(animeId)),
        ),
      ),
    );
  }
}

class _AnimeDetailsView extends StatelessWidget {
  final AnimeDetailsData details;

  const _AnimeDetailsView({required this.details});

  @override
  Widget build(BuildContext context) {
    final anime = details.anime;
    final recommendations = details.recommendations.take(10).toList();
    final relations = anime.relations?.take(12).toList() ?? const [];
    final title = anime.titleEnglish ?? anime.title;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final maxHeroWidth = constraints.maxWidth > 1040
                  ? 1040.0
                  : constraints.maxWidth;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxHeroWidth),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
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
                                  child: PosterImageTitle(anime: anime),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _AnimeHeroDetails(
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
                                child: PosterImageTitle(anime: anime),
                              ),
                              const SizedBox(height: 20),
                              _AnimeHeroDetails(anime: anime, title: title),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'Synopsis',
            child: Text(
              anime.synopsis?.trim().isNotEmpty == true
                  ? anime.synopsis!.trim()
                  : 'No synopsis available for this title yet.',
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          if (anime.background?.trim().isNotEmpty == true) ...[
            _SectionCard(
              title: 'Background',
              child: Text(
                anime.background!.trim(),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _SectionCard(
            title: 'Related media',
            child: relations.isEmpty
                ? const Text('No related media listed.')
                : Column(
                    children: relations
                        .map(
                          (relation) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _RelationGroup(relation: relation),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Recommended next',
            child: recommendations.isEmpty
                ? const Text('No recommendations available.')
                : SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final recommendation = recommendations[index];
                        return SizedBox(
                          width: 140,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AnimeDetailsPage(
                                    animeId: recommendation.entry.malId,
                                  ),
                                ),
                              );
                            },
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
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          height: 180,
                                          width: 140,
                                          color: Colors.grey,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
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
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AnimeHeroDetails extends StatelessWidget {
  final Anime anime;
  final String title;

  const _AnimeHeroDetails({
    required this.anime,
    required this.title,
  });

  String? _formatSeason(Anime anime) {
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
      _InfoBadge(
        icon: Symbols.star_rounded,
        label: anime.score?.toStringAsFixed(2) ?? 'N/A',
      ),
      _InfoBadge(
        icon: Symbols.leaderboard_rounded,
        label: anime.rank != null ? '#${anime.rank}' : 'Unranked',
      ),
      _InfoBadge(
        icon: Symbols.thumb_up_rounded,
        label: anime.popularity != null ? '#${anime.popularity}' : 'N/A',
      ),
      if (anime.type != null)
        _InfoBadge(
          icon: Symbols.movie_rounded,
          label: anime.type!,
        ),
      if (anime.status != null)
        _InfoBadge(
          icon: Symbols.schedule_rounded,
          label: anime.status!,
        ),
      if (anime.episodes != null)
        _InfoBadge(
          icon: Symbols.live_tv_rounded,
          label: '${anime.episodes} eps',
        ),
      if (_formatSeason(anime) != null)
        _InfoBadge(
          icon: Symbols.calendar_month_rounded,
          label: _formatSeason(anime)!,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'OTAKU TRACKER',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.amber,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
        ),
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
        _ScorePanel(anime: anime),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: metadata,
        ),
        const SizedBox(height: 16),
        DecoratedBox(
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
                _LabelValueText(
                  label: 'Studios',
                  value: anime.studios.isNotEmpty
                      ? anime.studios.map((studio) => studio.name).join(', ')
                      : 'Unknown',
                  labelColor: subtitleColor,
                  valueColor: titleColor,
                ),
                _LabelValueText(
                  label: 'Genres',
                  value: anime.genres.isNotEmpty
                      ? anime.genres.map((genre) => genre.name).join(', ')
                      : 'Unknown',
                  labelColor: subtitleColor,
                  valueColor: titleColor,
                ),
                if (anime.duration?.isNotEmpty == true)
                  _LabelValueText(
                    label: 'Duration',
                    value: anime.duration!,
                    labelColor: subtitleColor,
                    valueColor: titleColor,
                  ),
                if (anime.rating?.isNotEmpty == true)
                  _LabelValueText(
                    label: 'Rating',
                    value: anime.rating!,
                    labelColor: subtitleColor,
                    valueColor: titleColor,
                  ),
                if (anime.source?.isNotEmpty == true)
                  _LabelValueText(
                    label: 'Source',
                    value: anime.source!,
                    labelColor: subtitleColor,
                    valueColor: titleColor,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScorePanel extends StatelessWidget {
  final Anime anime;

  const _ScorePanel({required this.anime});

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
            _HeroStat(
              label: 'User score',
              value: anime.score?.toStringAsFixed(2) ?? 'N/A',
              icon: Symbols.star_rounded,
            ),
            _HeroStat(
              label: 'Rank',
              value: anime.rank != null ? '#${anime.rank}' : 'Unranked',
              icon: Symbols.leaderboard_rounded,
            ),
            _HeroStat(
              label: 'Popularity',
              value: anime.popularity != null ? '#${anime.popularity}' : 'N/A',
              icon: Symbols.thumb_up_rounded,
            ),
            _HeroStat(
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

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroStat({
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
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

class _RelationGroup extends StatelessWidget {
  final Relation relation;

  const _RelationGroup({required this.relation});

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: relation.entry
              .map(
                (entry) => ActionChip(
                  label: Text(entry.name),
                  onPressed: entry.type.toLowerCase() == 'anime'
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnimeDetailsPage(animeId: entry.malId),
                            ),
                          );
                        }
                      : null,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBadge({
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

class _LabelValueText extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const _LabelValueText({
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
