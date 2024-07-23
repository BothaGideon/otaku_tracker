import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/anime_list_provider.dart';

class LandingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animeListAsyncValue = ref.watch(animeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Anime List'),
      ),
      body: animeListAsyncValue.when(
        data: (animeList) {
          return ListView.builder(
            itemCount: animeList.data.length,
            itemBuilder: (context, index) {
              final anime = animeList.data[index];
              return ListTile(
                leading: Image.network(
                  anime.mediumPicture ?? "https://via.placeholder.com/150",
                  fit: BoxFit.cover,
                  width: 50.0,
                  height: 50.0,
                ),
                title: Text(anime.title),
                onTap: () {
                  print('Tapped on ${anime.title}');
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
