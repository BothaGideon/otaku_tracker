import 'package:flutter/material.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_hero_section.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_list_management.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_recommendations_section.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_relations_section.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_section_card.dart';

class AnimeDetailsContent extends StatelessWidget {
  final AnimeDetailsViewData details;

  const AnimeDetailsContent({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimeDetailsHeroSection(details: details),
          const SizedBox(height: 24),
          AnimeListManagementSection(
            animeId: details.animeId,
            totalEpisodes: details.totalEpisodes,
          ),
          const SizedBox(height: 16),
          AnimeDetailsTextSection(
            title: 'Synopsis',
            content: details.synopsis,
          ),
          if (details.background != null) ...[
            const SizedBox(height: 16),
            AnimeDetailsTextSection(
              title: 'Background',
              content: details.background!,
              isBodyLarge: false,
            ),
          ],
          const SizedBox(height: 16),
          AnimeDetailsRelationsSection(relations: details.relatedMedia),
          const SizedBox(height: 16),
          AnimeDetailsRecommendationsSection(
            recommendations: details.recommendations,
          ),
        ],
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
