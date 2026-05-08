import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:material_symbols_icons/symbols.dart';

class PosterImageTitle extends StatelessWidget {
  final Anime? anime;
  final String? userStatus;
  final num? userScore;
  final String? imageUrl;
  final String? title;
  final bool showBottomTitle;
  final bool showAuxiliaryStatWhenNoStatus;
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
    this.showAuxiliaryStatWhenNoStatus = true,
    this.auxiliaryStatValue,
    this.auxiliaryStatIcon = Symbols.thumb_up_rounded,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'watching':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'on_hold':
        return Colors.orange;
      case 'dropped':
        return Colors.red;
      case 'plan_to_watch':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatStatusText(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrlToUse = imageUrl ?? anime?.imageUrl ?? '';
    final titleToUse = title ?? anime?.titleEnglish ?? anime?.title ?? '';
    final scoreToUse = userScore ?? anime?.score;
    final auxiliaryStatToUse = auxiliaryStatValue ?? anime?.favorites;

    final hasImage = imageUrlToUse.isNotEmpty;

    Widget buildPosterImage() {
      if (hasImage) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrlToUse,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
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
                                        size: 16.0, Symbols.star_rounded),
                                  ),
                                  Text(
                                    scoreToUse != null && scoreToUse > 0
                                        ? scoreToUse is double
                                            ? scoreToUse.toStringAsFixed(1)
                                            : scoreToUse.toString()
                                        : 'N/A',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: userStatus != null && userStatus!.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(userStatus!),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Text(
                                        _formatStatusText(userStatus!),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : showAuxiliaryStatWhenNoStatus
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 3.0),
                                              child: Icon(
                                                  size: 16.0, auxiliaryStatIcon),
                                            ),
                                            Text(
                                              auxiliaryStatToUse?.toString() ??
                                                  'N/A',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14.0),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final poster = hasBoundedHeight
            ? Flexible(child: buildPosterImage())
            : SizedBox(
                height: hasImage ? 260.0 : 244.0,
                width: double.infinity,
                child: buildPosterImage(),
              );

        return Column(
          children: [
            poster,
            if (showBottomTitle) ...[
              const SizedBox(height: 10.0),
              Text(
                titleToUse,
                style:
                    const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ],
        );
      },
    );
  }
}
