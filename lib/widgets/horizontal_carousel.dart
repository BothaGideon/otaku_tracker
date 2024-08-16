import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:otaku_tracker/models/response/anime.dart';

import 'carousel_title_subtitle.dart';

class HorizontalCarousel extends StatelessWidget {
  final List<AnimeData> animeList;
  final Key key;
  final String title;
  final String? subtitle;

  HorizontalCarousel(
      {required this.key,
      required this.animeList,
      required this.title,
      this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselTitleSubtitle(
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(
          height: 10.0,
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 260.0,
            aspectRatio: 3 / 2,
            autoPlay: false,
            enlargeCenterPage: false,
            viewportFraction: 0.33,
          ),
          items: animeList.map((animeData) {
            final anime = animeData.node;
            final mainPicture = anime.mainPicture;
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.33,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      mainPicture != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/icons/logo_black.png',
                                image: mainPicture.medium,
                                fit: BoxFit.cover,
                                height: 204.0,
                              ),
                            )
                          : Container(
                              height: 204.0,
                              color: Colors.grey,
                              child: const Icon(Icons.image_not_supported),
                            ),
                      const SizedBox(height: 10.0),
                      Text(
                        anime.title,
                        style: const TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
