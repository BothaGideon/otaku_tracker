import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/constants/app/number_format.dart';
import 'package:otaku_tracker/widgets/shared/loading/network_image_skeleton.dart';

class PosterImageTitle extends StatelessWidget {
  static const int _titleMaxLines = 2;
  static const double _titleHeight = 36.0;
  static const double _posterAspectRatio = 196.0 / 256.7;
  static const BorderRadius _posterBorderRadius =
      BorderRadius.all(Radius.circular(15.0));

  final Anime? anime;
  final String? userStatus;
  final num? userScore;
  final String? imageUrl;
  final String? title;
  final bool showBottomTitle;
  final bool showAuxiliaryStat;
  final num? auxiliaryStatValue;
  final IconData auxiliaryStatIcon;

  const PosterImageTitle({
    super.key,
    this.anime,
    this.userStatus,
    this.userScore,
    this.imageUrl,
    this.title,
    this.showBottomTitle = true,
    this.showAuxiliaryStat = false,
    this.auxiliaryStatValue,
    this.auxiliaryStatIcon = Icons.thumb_up_rounded,
  });

  static String _formatStatus(String status) {
    switch (status) {
      case 'watching':
        return 'Watching';
      case 'completed':
        return 'Completed';
      case 'on_hold':
        return 'On Hold';
      case 'dropped':
        return 'Dropped';
      case 'plan_to_watch':
        return 'Planned';
      default:
        return status;
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'watching':
        return const Color(0xFF388E3C); // green
      case 'completed':
        return const Color(0xFF1976D2); // blue
      case 'on_hold':
        return const Color(0xFFF57C00); // orange
      case 'dropped':
        return const Color(0xFFD32F2F); // red
      case 'plan_to_watch':
        return const Color(0xFF512DA8); // deep purple (matches app seed)
      default:
        return const Color(0xFF455A64); // blue-grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrlToUse = imageUrl ?? anime?.imageUrl ?? '';
    final titleToUse = title ?? anime?.titleEnglish ?? anime?.title ?? '';
    final scoreToUse = userScore ?? anime?.score;
    final auxiliaryStatToUse = auxiliaryStatValue ?? anime?.members;

    final hasImage = imageUrlToUse.isNotEmpty;

    Widget buildPosterImage() {
      if (hasImage) {
        return ClipRRect(
          borderRadius: _posterBorderRadius,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: NetworkImageSkeleton(
                  imageUrl: imageUrlToUse,
                  borderRadius: _posterBorderRadius,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 2.0),
                                    child: Icon(
                                        size: 16.0, Icons.star_rounded),
                                  ),
                                  Text(
                                    scoreToUse != null && scoreToUse > 0
                                        ? scoreToUse is double
                                            ? scoreToUse.toStringAsFixed(1)
                                            : scoreToUse.toString()
                                        : 'N/A',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        if (userStatus != null)
                          Flexible(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(userStatus!),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _formatStatus(userStatus!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else if (showAuxiliaryStat)
                          Flexible(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      child: Icon(
                                        size: 16.0,
                                        auxiliaryStatIcon,
                                      ),
                                    ),
                                    Text(
                                      formatNumberCompact(auxiliaryStatToUse),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return const NetworkImageSkeleton(
        imageUrl: null,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final poster = hasBoundedHeight
            ? Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: _posterAspectRatio,
                    child: buildPosterImage(),
                  ),
                ),
              )
            : SizedBox(
                height: hasImage ? 256.7 : 244.0,
                width: double.infinity,
                child: buildPosterImage(),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            poster,
            if (showBottomTitle) ...[
              const SizedBox(height: 10.0),
              SizedBox(
                height: _titleHeight,
                child: Text(
                  titleToUse,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: _titleMaxLines,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
