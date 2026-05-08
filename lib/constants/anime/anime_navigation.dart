import 'package:flutter/material.dart';
import 'package:otaku_tracker/pages/anime_details/anime_details_page.dart';

void openAnimeDetailsPage(BuildContext context, int animeId) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AnimeDetailsPage(animeId: animeId),
    ),
  );
}
