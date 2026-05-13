import 'package:flutter/material.dart';
import 'package:otaku_tracker/constants/anime/anime_navigation.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_section_card.dart';
import 'package:otaku_tracker/widgets/shared/loading/network_image_skeleton.dart';

class AnimeDetailsRecommendationsSection extends StatelessWidget {
  final List<AnimeDetailsRecommendationViewData> recommendations;

  const AnimeDetailsRecommendationsSection({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return AnimeDetailsSectionCard(
      title: 'Recommended next',
      child: recommendations.isEmpty
          ? const Text('No recommendations available.')
          : SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final recommendation = recommendations[index];
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
  final AnimeDetailsRecommendationViewData recommendation;

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
        onTap: () => openAnimeDetailsPage(context, recommendation.malId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 180,
                width: 140,
                child: NetworkImageSkeleton(
                  imageUrl:
                      recommendation.imageUrl.isNotEmpty
                          ? recommendation.imageUrl
                          : null,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                recommendation.title,
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
