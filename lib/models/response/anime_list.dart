import 'package:json_annotation/json_annotation.dart';

import 'anime.dart';

part 'anime_list.g.dart';

@JsonSerializable()
class AnimeList {
  final List<Anime> data;
  final String? nextPage;

  AnimeList({
    required this.data,
    this.nextPage,
  });

  factory AnimeList.fromJson(Map<String, dynamic> json) =>
      _$AnimeListFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeListToJson(this);
}
