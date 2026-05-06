import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:material_symbols_icons/symbols.dart';

class PosterImageTitle extends StatelessWidget {
  final Anime? anime;
  final String? userStatus;
  final int? userScore;
  final String? imageUrl;
  final String? title;

  const PosterImageTitle({
    super.key,
    this.anime,
    this.userStatus,
    this.userScore,
    this.imageUrl,
    this.title,
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
    final popularityToUse = anime?.popularity;

    final hasImage = imageUrlToUse.isNotEmpty;

    return Column(
      children: [
        hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    FadeInImage.assetNetwork(
                      placeholder: 'assets/icons/logo_black.png',
                      image: imageUrlToUse,
                      fit: BoxFit.cover,
                      height: 260.0,
                      width: double.infinity,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 2.0),
                                    child: Icon(
                                        size: 16.0, Symbols.star_rounded),
                                  ),
                                  Text(
                                    scoreToUse != null && scoreToUse > 0
                                        ? scoreToUse.toString()
                                        : 'N/A',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14.0),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              if (userStatus != null && userStatus!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(userStatus!),
                                    borderRadius: BorderRadius.circular(12.0),
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
                              else
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 3.0),
                                      child: Icon(
                                          size: 16.0,
                                          Symbols.thumb_up_rounded),
                                    ),
                                    Text(
                                      popularityToUse?.toString() ?? 'N/A',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14.0),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                height: 244.0,
                color: Colors.grey,
                child: const Icon(Icons.image_not_supported),
              ),
        const SizedBox(height: 10.0),
        Text(
          titleToUse,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}
