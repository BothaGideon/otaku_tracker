import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:jikan_api/jikan_api.dart';
import 'package:otaku_tracker/constants/anime_navigation.dart';
import 'package:otaku_tracker/widgets/network_image_skeleton.dart';

import 'carousel_title_subtitle.dart';

class HorizontalCarousel extends StatelessWidget {
  final List<Anime> animeList;
  final String title;
  final String? subtitle;

  const HorizontalCarousel(
      {super.key,
      required this.animeList,
      required this.title,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 16.0,
        ),
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
            final anime = animeData;
            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => openAnimeDetailsPage(context, anime.malId),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.33,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        anime.imageUrl.isNotEmpty
                            ? NetworkImageSkeleton(
                                imageUrl: anime.imageUrl,
                                height: 204.0,
                              )
                            : const SizedBox(
                                height: 204.0,
                                child: NetworkImageSkeleton(
                                  imageUrl: null,
                                ),
                              ),
                        const SizedBox(height: 10.0),
                        Text(
                          anime.titleEnglish ?? anime.title,
                          style: const TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
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
