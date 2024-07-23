// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimeList _$AnimeListFromJson(Map<String, dynamic> json) => AnimeList(
      data: (json['data'] as List<dynamic>)
          .map((e) => Anime.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPage: json['nextPage'] as String?,
    );

Map<String, dynamic> _$AnimeListToJson(AnimeList instance) => <String, dynamic>{
      'data': instance.data,
      'nextPage': instance.nextPage,
    };
