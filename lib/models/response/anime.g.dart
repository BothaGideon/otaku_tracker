// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Anime _$AnimeFromJson(Map<String, dynamic> json) => Anime(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      mediumPicture: json['mediumPicture'] as String,
      largePicture: json['largePicture'] as String,
    );

Map<String, dynamic> _$AnimeToJson(Anime instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'mediumPicture': instance.mediumPicture,
      'largePicture': instance.largePicture,
    };
