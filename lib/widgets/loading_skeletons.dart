import 'package:flutter/material.dart';

import 'skeleton_box.dart';

class LandingPageSkeleton extends StatelessWidget {
  const LandingPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('landing-page-skeleton'),
      children: const [
        HorizontalCarouselSkeleton(showSubtitle: true),
        HorizontalCarouselSkeleton(showSubtitle: true),
        HorizontalCarouselSkeleton(showSubtitle: true),
        HorizontalCarouselSkeleton(),
        HorizontalCarouselSkeleton(),
        HorizontalCarouselSkeleton(),
      ],
    );
  }
}

class HorizontalCarouselSkeleton extends StatelessWidget {
  final bool showSubtitle;

  const HorizontalCarouselSkeleton({
    super.key,
    this.showSubtitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 150, height: 24),
              if (showSubtitle) ...[
                const SizedBox(height: 8),
                const SkeletonBox(width: 96, height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        SizedBox(
          height: 260.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10.0),
            itemBuilder: (_, __) => const SizedBox(
              width: 130,
              child: _PosterCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

class PosterGridSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int itemCount;

  const PosterGridSkeleton({
    super.key,
    this.padding = const EdgeInsets.all(12.0),
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey('poster-grid-skeleton'),
      padding: padding,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisExtent: 320.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemBuilder: (_, __) => const _PosterTitleSkeleton(),
    );
  }
}

class MyListPageSkeleton extends StatelessWidget {
  const MyListPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SkeletonBox(
                      width: 84,
                      height: 84,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    SizedBox(height: 20),
                    SkeletonBox(width: 220, height: 28),
                    SizedBox(height: 10),
                    SkeletonBox(width: double.infinity, height: 18),
                    SizedBox(height: 8),
                    SkeletonBox(width: 280, height: 18),
                    SizedBox(height: 24),
                    SkeletonBox(
                      width: double.infinity,
                      height: 48,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    SizedBox(height: 16),
                    SkeletonBox(width: double.infinity, height: 16),
                    SizedBox(height: 8),
                    SkeletonBox(width: 260, height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyListDetailListSkeleton extends StatelessWidget {
  const MyListDetailListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('my-list-detail-skeleton'),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _MyListDetailRowSkeleton(),
    );
  }
}

class MyListPosterGridSkeleton extends StatelessWidget {
  const MyListPosterGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosterGridSkeleton(
      key: ValueKey('my-list-poster-skeleton'),
    );
  }
}

class MyProfilePageSkeleton extends StatelessWidget {
  const MyProfilePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('my-profile-skeleton'),
      padding: const EdgeInsets.all(16.0),
      children: const [
        _ProfileHeaderSkeleton(),
        SizedBox(height: 16),
        _ProfileJourneySkeleton(),
        SizedBox(height: 16),
        _ProfileDisclaimerSkeleton(),
        SizedBox(height: 24),
        Divider(),
        SizedBox(height: 16),
        _ProfileLogoutSkeleton(),
      ],
    );
  }
}

class AnimeDetailsPageSkeleton extends StatelessWidget {
  const AnimeDetailsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('anime-details-skeleton'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _AnimeDetailsHeroSkeleton(),
          SizedBox(height: 24),
          _AnimeDetailsListManagementSkeleton(),
          SizedBox(height: 16),
          _TextSectionSkeleton(lineCount: 5),
          SizedBox(height: 16),
          _TextSectionSkeleton(lineCount: 3),
          SizedBox(height: 16),
          _RecommendationsSkeleton(),
        ],
      ),
    );
  }
}

class SearchResultsSkeleton extends StatelessWidget {
  const SearchResultsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const PosterGridSkeleton(
      key: ValueKey('search-results-skeleton'),
    );
  }
}

class AnimeDetailsAccountSectionSkeleton extends StatelessWidget {
  const AnimeDetailsAccountSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 150, height: 16),
          SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              SkeletonBox(
                width: 120,
                height: 34,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              SkeletonBox(
                width: 104,
                height: 34,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              SkeletonBox(
                width: 96,
                height: 34,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SkeletonBox(
                width: 112,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
              SizedBox(width: 12),
              SkeletonBox(
                width: 96,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(999)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PosterCardSkeleton extends StatelessWidget {
  const _PosterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(height: 204.0),
        SizedBox(height: 10.0),
        SkeletonBox(width: double.infinity, height: 16),
        SizedBox(height: 6.0),
        SkeletonBox(width: 84, height: 16),
      ],
    );
  }
}

class _PosterTitleSkeleton extends StatelessWidget {
  const _PosterTitleSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SkeletonBox()),
        SizedBox(height: 10.0),
        SkeletonBox(width: double.infinity, height: 16),
        SizedBox(height: 6.0),
        SkeletonBox(width: 120, height: 16),
      ],
    );
  }
}

class _MyListDetailRowSkeleton extends StatelessWidget {
  const _MyListDetailRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(
              width: 72,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 20),
                  SizedBox(height: 8),
                  SkeletonBox(width: 180, height: 20),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _DetailStatSkeleton(),
                      _DetailStatSkeleton(),
                      _DetailStatSkeleton(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStatSkeleton extends StatelessWidget {
  const _DetailStatSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SkeletonBox(width: 48, height: 14),
        SizedBox(height: 4),
        SkeletonBox(width: 72, height: 16),
      ],
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: const [
            SkeletonBox(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SizedBox(height: 16),
            SkeletonBox(width: 160, height: 28),
            SizedBox(height: 8),
            SkeletonBox(width: 180, height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileJourneySkeleton extends StatelessWidget {
  const _ProfileJourneySkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 180, height: 24),
            const SizedBox(height: 8),
            const SkeletonBox(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            const SkeletonBox(width: 280, height: 16),
            const SizedBox(height: 20),
            for (var index = 0; index < 3; index++) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      SkeletonBox(
                        width: 20,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      SizedBox(width: 10),
                      SkeletonBox(width: 72, height: 24),
                      SizedBox(width: 8),
                      Expanded(child: SkeletonBox(height: 16)),
                    ],
                  ),
                ),
              ),
              if (index < 2) const SizedBox(height: 10),
            ],
            const SizedBox(height: 24),
            const SkeletonBox(width: 120, height: 20),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ProfileBreakdownSkeletonTile(),
                _ProfileBreakdownSkeletonTile(),
                _ProfileBreakdownSkeletonTile(),
                _ProfileBreakdownSkeletonTile(),
                _ProfileBreakdownSkeletonTile(),
                _ProfileBreakdownSkeletonTile(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBreakdownSkeletonTile extends StatelessWidget {
  const _ProfileBreakdownSkeletonTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonBox(
            width: 20,
            height: 20,
            borderRadius: BorderRadius.all(Radius.circular(999)),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBox(width: 36, height: 18),
              SizedBox(height: 6),
              SkeletonBox(width: 72, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileDisclaimerSkeleton extends StatelessWidget {
  const _ProfileDisclaimerSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 100, height: 20),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 16),
            SizedBox(height: 8),
            SkeletonBox(width: 300, height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileLogoutSkeleton extends StatelessWidget {
  const _ProfileLogoutSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20.0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 72, height: 20),
          SizedBox(height: 8),
          SkeletonBox(width: double.infinity, height: 16),
          SizedBox(height: 8),
          SkeletonBox(width: 320, height: 16),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SkeletonBox(
              width: 110,
              height: 40,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimeDetailsHeroSkeleton extends StatelessWidget {
  const _AnimeDetailsHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 220,
                    child: SkeletonBox(
                      height: 260,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(child: _AnimeDetailsHeroContentSkeleton()),
                ],
              );
            }

            return const Column(
              children: [
                SizedBox(
                  width: 220,
                  child: SkeletonBox(
                    height: 260,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
                SizedBox(height: 20),
                _AnimeDetailsHeroContentSkeleton(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimeDetailsHeroContentSkeleton extends StatelessWidget {
  const _AnimeDetailsHeroContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 8),
        SkeletonBox(width: 260, height: 32),
        SizedBox(height: 8),
        SkeletonBox(width: 180, height: 20),
        SizedBox(height: 8),
        SkeletonBox(width: 220, height: 16),
        SizedBox(height: 16),
        _AnimeDetailsPanelSkeleton(height: 84),
        SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            SkeletonBox(
              width: 110,
              height: 34,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SkeletonBox(
              width: 120,
              height: 34,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            SkeletonBox(
              width: 104,
              height: 34,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ),
        SizedBox(height: 16),
        _AnimeDetailsPanelSkeleton(height: 132),
      ],
    );
  }
}

class _AnimeDetailsPanelSkeleton extends StatelessWidget {
  final double height;

  const _AnimeDetailsPanelSkeleton({
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: double.infinity,
      height: height,
      borderRadius: BorderRadius.circular(18),
    );
  }
}

class _AnimeDetailsListManagementSkeleton extends StatelessWidget {
  const _AnimeDetailsListManagementSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 72, height: 16),
            SizedBox(height: 12),
            AnimeDetailsAccountSectionSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _TextSectionSkeleton extends StatelessWidget {
  final int lineCount;

  const _TextSectionSkeleton({
    required this.lineCount,
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
            const SkeletonBox(width: 92, height: 16),
            const SizedBox(height: 12),
            for (var index = 0; index < lineCount; index++) ...[
              SkeletonBox(
                width: index == lineCount - 1 ? 240 : double.infinity,
                height: 16,
              ),
              if (index < lineCount - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationsSkeleton extends StatelessWidget {
  const _RecommendationsSkeleton();

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
            const SkeletonBox(width: 160, height: 16),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 140,
                        height: 180,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      SizedBox(height: 8),
                      SkeletonBox(width: double.infinity, height: 16),
                      SizedBox(height: 6),
                      SkeletonBox(width: 72, height: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
