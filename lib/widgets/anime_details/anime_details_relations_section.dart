import 'package:flutter/material.dart';
import 'package:otaku_tracker/constants/anime/anime_navigation.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';
import 'package:otaku_tracker/widgets/anime_details/anime_details_section_card.dart';

class AnimeDetailsRelationsSection extends StatelessWidget {
  final List<AnimeDetailsRelationGroupViewData> relations;

  const AnimeDetailsRelationsSection({
    super.key,
    required this.relations,
  });

  @override
  Widget build(BuildContext context) {
    return AnimeDetailsSectionCard(
      title: 'Related media',
      child: relations.isEmpty
          ? const Text('No related media listed.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: relations
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

class AnimeDetailsRelationGroup extends StatelessWidget {
  final AnimeDetailsRelationGroupViewData relation;

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
            children: relation.entries
                .map(
                  (entry) => ActionChip(
                    label: Text(entry.name),
                    onPressed: entry.canOpenAnimeDetails
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
