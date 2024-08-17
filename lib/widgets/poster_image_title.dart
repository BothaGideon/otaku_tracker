import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:material_symbols_icons/symbols.dart';

class PosterImageTitle extends StatelessWidget {
  final Anime anime;

  const PosterImageTitle({
    super.key,
    required this.anime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        anime.imageUrl != null
            ? Stack(alignment: Alignment.bottomCenter, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/icons/logo_black.png',
                    image: anime.imageUrl,
                    fit: BoxFit.cover,
                    height: 260.0,
                  ),
                ),
                Container(
                  height: 260.0,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(size: 16.0, Symbols.star_rounded),
                          ),
                          Text(
                            anime.score.toString() ?? 'N/A',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14.0),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 3.0),
                            child: Icon(size: 16.0, Symbols.thumb_up_rounded),
                          ),
                          Text(
                            anime.popularity.toString() ?? 'N/A',
                            // Replace with your desired text.
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14.0),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ])
            : Container(
                height: 244.0,
                color: Colors.grey,
                child: const Icon(Icons.image_not_supported),
              ),
        const SizedBox(height: 10.0),
        Text(
          anime.titleEnglish ?? anime.title,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}
