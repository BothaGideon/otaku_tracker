import 'package:json_annotation/json_annotation.dart';

part 'anime.g.dart';

@JsonSerializable()
class Anime {
  final int id;
  final String title;
  final String mediumPicture;
  final String largePicture;

  Anime({
    required this.id,
    required this.title,
    required this.mediumPicture,
    required this.largePicture,
  });

  factory Anime.fromJson(Map<String, dynamic> json) => _$AnimeFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeToJson(this);
}
