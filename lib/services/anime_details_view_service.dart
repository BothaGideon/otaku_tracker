import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/models/response/anime.dart';

enum AnimeDetailsHeroBadgeKind {
  type,
  status,
  episodes,
  season,
}

enum AnimeDetailsHeroStatKind {
  userScore,
  rank,
  popularity,
  members,
}

class AnimeDetailsHeroBadgeData {
  final AnimeDetailsHeroBadgeKind kind;
  final String label;

  const AnimeDetailsHeroBadgeData({
    required this.kind,
    required this.label,
  });
}

class AnimeDetailsHeroStatData {
  final AnimeDetailsHeroStatKind kind;
  final String label;
  final String value;

  const AnimeDetailsHeroStatData({
    required this.kind,
    required this.label,
    required this.value,
  });
}

class AnimeDetailsMetadataRowData {
  final String label;
  final String value;

  const AnimeDetailsMetadataRowData({
    required this.label,
    required this.value,
  });
}

class AnimeDetailsRelationEntryViewData {
  final String name;
  final int malId;
  final bool canOpenAnimeDetails;

  const AnimeDetailsRelationEntryViewData({
    required this.name,
    required this.malId,
    required this.canOpenAnimeDetails,
  });
}

class AnimeDetailsRelationGroupViewData {
  final String relation;
  final List<AnimeDetailsRelationEntryViewData> entries;

  const AnimeDetailsRelationGroupViewData({
    required this.relation,
    required this.entries,
  });
}

class AnimeDetailsRecommendationViewData {
  final int malId;
  final String title;
  final String imageUrl;
  final int votes;

  const AnimeDetailsRecommendationViewData({
    required this.malId,
    required this.title,
    required this.imageUrl,
    required this.votes,
  });
}

class AnimeDetailsViewData {
  final int animeId;
  final int? totalEpisodes;
  final String imageUrl;
  final String title;
  final String? japaneseTitle;
  final String? synonymsLine;
  final String synopsis;
  final String? background;
  final List<AnimeDetailsHeroBadgeData> heroBadges;
  final List<AnimeDetailsHeroStatData> heroStats;
  final List<AnimeDetailsMetadataRowData> metadataRows;
  final List<AnimeDetailsRelationGroupViewData> relatedMedia;
  final List<AnimeDetailsRecommendationViewData> recommendations;

  const AnimeDetailsViewData({
    required this.animeId,
    required this.totalEpisodes,
    required this.imageUrl,
    required this.title,
    required this.japaneseTitle,
    required this.synonymsLine,
    required this.synopsis,
    required this.background,
    required this.heroBadges,
    required this.heroStats,
    required this.metadataRows,
    required this.relatedMedia,
    required this.recommendations,
  });
}

class AnimeListEntryPresentation {
  final bool hasEntry;
  final String statusLabel;
  final String episodesLabel;
  final String scoreLabel;
  final String? tags;
  final String? comments;

  const AnimeListEntryPresentation({
    required this.hasEntry,
    required this.statusLabel,
    required this.episodesLabel,
    required this.scoreLabel,
    required this.tags,
    required this.comments,
  });
}

class AnimeListStatusOption {
  final String value;
  final String label;

  const AnimeListStatusOption(this.value, this.label);
}

const animeListStatusOptions = [
  AnimeListStatusOption('watching', 'Watching'),
  AnimeListStatusOption('completed', 'Completed'),
  AnimeListStatusOption('on_hold', 'On hold'),
  AnimeListStatusOption('dropped', 'Dropped'),
  AnimeListStatusOption('plan_to_watch', 'Plan to watch'),
];

class AnimeDetailsViewService {
  AnimeDetailsViewData buildViewData({
    required Anime anime,
    required List<Recommendation> recommendations,
  }) {
    return AnimeDetailsViewData(
      animeId: anime.malId,
      totalEpisodes: anime.episodes,
      imageUrl: anime.imageUrl,
      title: anime.titleEnglish ?? anime.title,
      japaneseTitle: _nonEmpty(anime.titleJapanese),
      synonymsLine: anime.titleSynonyms.isEmpty
          ? null
          : anime.titleSynonyms.take(3).join(' • '),
      synopsis: _nonEmpty(anime.synopsis?.trim()) ??
          'No synopsis available for this title yet.',
      background: _nonEmpty(anime.background?.trim()),
      heroBadges: _buildHeroBadges(anime),
      heroStats: _buildHeroStats(anime),
      metadataRows: _buildMetadataRows(anime),
      relatedMedia: _buildRelatedMedia(anime.relations),
      recommendations: _buildRecommendations(recommendations),
    );
  }

  AnimeListEntryPresentation buildListEntryPresentation(
    ListStatus? status,
    int? totalEpisodes,
  ) {
    final trimmedTags = _nonEmpty(status?.tags?.trim());
    final trimmedComments = _nonEmpty(status?.comments?.trim());

    return AnimeListEntryPresentation(
      hasEntry: status != null,
      statusLabel: status == null
          ? 'Not in your list'
          : statusLabel(status.status),
      episodesLabel: episodesLabel(
        status?.numEpisodesWatched ?? 0,
        totalEpisodes,
      ),
      scoreLabel: status == null || status.score == 0
          ? 'Not rated'
          : 'Rated ${status.score}/10',
      tags: trimmedTags,
      comments: trimmedComments,
    );
  }

  String statusLabel(String status) {
    for (final option in animeListStatusOptions) {
      if (option.value == status) {
        return option.label;
      }
    }

    return status.replaceAll('_', ' ');
  }

  String episodesLabel(int watchedEpisodes, int? totalEpisodes) {
    if (totalEpisodes == null || totalEpisodes <= 0) {
      return '$watchedEpisodes watched';
    }

    return '$watchedEpisodes / $totalEpisodes watched';
  }

  List<AnimeDetailsHeroBadgeData> _buildHeroBadges(Anime anime) {
    return [
      if (_nonEmpty(anime.type) != null)
        AnimeDetailsHeroBadgeData(
          kind: AnimeDetailsHeroBadgeKind.type,
          label: anime.type!,
        ),
      if (_nonEmpty(anime.status) != null)
        AnimeDetailsHeroBadgeData(
          kind: AnimeDetailsHeroBadgeKind.status,
          label: anime.status!,
        ),
      if (anime.episodes != null)
        AnimeDetailsHeroBadgeData(
          kind: AnimeDetailsHeroBadgeKind.episodes,
          label: '${anime.episodes} eps',
        ),
      if (_seasonLabel(anime) != null)
        AnimeDetailsHeroBadgeData(
          kind: AnimeDetailsHeroBadgeKind.season,
          label: _seasonLabel(anime)!,
        ),
    ];
  }

  List<AnimeDetailsHeroStatData> _buildHeroStats(Anime anime) {
    return [
      AnimeDetailsHeroStatData(
        kind: AnimeDetailsHeroStatKind.userScore,
        label: 'User score',
        value: anime.score?.toStringAsFixed(2) ?? 'N/A',
      ),
      AnimeDetailsHeroStatData(
        kind: AnimeDetailsHeroStatKind.rank,
        label: 'Rank',
        value: anime.rank != null ? '#${anime.rank}' : 'Unranked',
      ),
      AnimeDetailsHeroStatData(
        kind: AnimeDetailsHeroStatKind.popularity,
        label: 'Popularity',
        value: anime.popularity != null ? '#${anime.popularity}' : 'N/A',
      ),
      AnimeDetailsHeroStatData(
        kind: AnimeDetailsHeroStatKind.members,
        label: 'Members',
        value: anime.members?.toString() ?? 'N/A',
      ),
    ];
  }

  List<AnimeDetailsMetadataRowData> _buildMetadataRows(Anime anime) {
    return [
      AnimeDetailsMetadataRowData(
        label: 'Studios',
        value: anime.studios.isNotEmpty
            ? anime.studios.map((studio) => studio.name).join(', ')
            : 'Unknown',
      ),
      AnimeDetailsMetadataRowData(
        label: 'Genres',
        value: anime.genres.isNotEmpty
            ? anime.genres.map((genre) => genre.name).join(', ')
            : 'Unknown',
      ),
      if (_nonEmpty(anime.duration) != null)
        AnimeDetailsMetadataRowData(
          label: 'Duration',
          value: anime.duration!,
        ),
      if (_nonEmpty(anime.rating) != null)
        AnimeDetailsMetadataRowData(
          label: 'Rating',
          value: anime.rating!,
        ),
      if (_nonEmpty(anime.source) != null)
        AnimeDetailsMetadataRowData(
          label: 'Source',
          value: anime.source!,
        ),
    ];
  }

  List<AnimeDetailsRelationGroupViewData> _buildRelatedMedia(
    BuiltList<Relation>? relations,
  ) {
    return (relations?.take(12).toList() ?? const [])
        .map(
          (relation) => AnimeDetailsRelationGroupViewData(
            relation: relation.relation,
            entries: relation.entry
                .map(
                  (entry) => AnimeDetailsRelationEntryViewData(
                    name: entry.name,
                    malId: entry.malId,
                    canOpenAnimeDetails: entry.type.toLowerCase() == 'anime',
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  List<AnimeDetailsRecommendationViewData> _buildRecommendations(
    List<Recommendation> recommendations,
  ) {
    return recommendations
        .take(10)
        .map(
          (recommendation) => AnimeDetailsRecommendationViewData(
            malId: recommendation.entry.malId,
            title: recommendation.entry.title,
            imageUrl: recommendation.entry.imageUrl,
            votes: recommendation.votes,
          ),
        )
        .toList();
  }

  String? _seasonLabel(Anime anime) {
    if (anime.season == null || anime.year == null) {
      return null;
    }

    final season = anime.season!;
    return '${season[0].toUpperCase()}${season.substring(1)} ${anime.year}';
  }

  String? _nonEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }
}
