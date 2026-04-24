import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:otaku_tracker/models/response/anime.dart';

class UserAnimeItem extends StatelessWidget {
  final UserAnimeData userAnimeData;

  const UserAnimeItem({super.key, required this.userAnimeData});

  @override
  Widget build(BuildContext context) {
    final node = userAnimeData.node;
    final listStatus = userAnimeData.listStatus;

    return Column(
      children: [
        node.mainPicture != null
            ? Stack(alignment: Alignment.bottomCenter, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/icons/logo_black.png',
                    image: node.mainPicture!.medium,
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
                        Colors.black.withValues(alpha: 0.7),
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
                            listStatus.score.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14.0),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Text(
                        listStatus.status,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14.0),
                        textAlign: TextAlign.center,
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
          node.title,
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}
