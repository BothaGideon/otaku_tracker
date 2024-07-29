import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/anime_list_provider.dart';
import '../../widgets/horizontal_carousel.dart';

class LandingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinedListAsyncValue = ref.watch(combinedAnimeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime List'),
      ),
      body: combinedListAsyncValue.when(
        data: (combinedList) {
          return Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text('Current season'),
                  )),
              SizedBox(
                height: 10.0,
              ),
              HorizontalCarousel(
                animeList: combinedList.seasonalAnimeList,
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: combinedList.animeList.length,
                  itemBuilder: (context, index) {
                    final anime = combinedList.animeList[index].node;
                    final mainPicture = anime.mainPicture;
                    return ListTile(
                      leading: mainPicture != null
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/icons/logo_black.png',
                              image: mainPicture.medium,
                              fit: BoxFit.cover,
                              width: 50.0,
                              height: 50.0,
                            )
                          : Container(
                              width: 50.0,
                              height: 50.0,
                              color: Colors.grey,
                              child: Icon(Icons.image_not_supported),
                            ),
                      title: Text(anime.title),
                      onTap: () {
                        print('Tapped on ${anime.title}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
