import 'package:flutter/material.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';

class AnimeDetailsScorePanel extends StatelessWidget {
  final List<AnimeDetailsHeroStatData> stats;

  const AnimeDetailsScorePanel({
    super.key,
    required this.stats,
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
          horizontal: 14.0,
          vertical: 14.0,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: stats
              .map(
                (stat) => AnimeDetailsHeroStat(
                  label: stat.label,
                  value: stat.value,
                  icon: _iconForHeroStat(stat.kind),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  IconData _iconForHeroStat(AnimeDetailsHeroStatKind kind) {
    switch (kind) {
      case AnimeDetailsHeroStatKind.userScore:
        return Icons.star_rounded;
      case AnimeDetailsHeroStatKind.rank:
        return Icons.leaderboard_rounded;
      case AnimeDetailsHeroStatKind.popularity:
        return Icons.thumb_up_rounded;
      case AnimeDetailsHeroStatKind.members:
        return Icons.groups_rounded;
    }
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
        mainAxisAlignment: MainAxisAlignment.start,
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
