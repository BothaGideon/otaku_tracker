import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:otaku_tracker/models/response/anime.dart';

class HorizontalCarousel extends StatelessWidget {
  final List<AnimeData> animeList;

  HorizontalCarousel({required this.animeList});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
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
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
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
                          child: Icon(Icons.image_not_supported),
                        ),
                  SizedBox(height: 10.0),
                  Text(
                    anime.title,
                    style: TextStyle(fontSize: 16.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
