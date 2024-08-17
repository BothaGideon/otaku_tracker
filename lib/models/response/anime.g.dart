// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimeDTO _$AnimeFromJson(Map<String, dynamic> json) => AnimeDTO(
      data: (json['data'] as List<dynamic>)
          .map((e) => AnimeData.fromJson(e as Map<String, dynamic>))
          .toList(),
      paging: json['paging'] == null
          ? null
          : Paging.fromJson(json['paging'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnimeToJson(AnimeDTO instance) => <String, dynamic>{
      'data': instance.data,
      'paging': instance.paging,
    };

AnimeData _$AnimeDataFromJson(Map<String, dynamic> json) => AnimeData(
      node: Node.fromJson(json['node'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnimeDataToJson(AnimeData instance) => <String, dynamic>{
      'node': instance.node,
    };

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      mainPicture: json['main_picture'] == null
          ? null
          : MainPicture.fromJson(json['main_picture'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'main_picture': instance.mainPicture,
    };

MainPicture _$MainPictureFromJson(Map<String, dynamic> json) => MainPicture(
      medium: json['medium'] as String,
      large: json['large'] as String,
    );

Map<String, dynamic> _$MainPictureToJson(MainPicture instance) =>
    <String, dynamic>{
      'medium': instance.medium,
      'large': instance.large,
    };

Paging _$PagingFromJson(Map<String, dynamic> json) => Paging(
      next: json['next'] as String?,
    );

Map<String, dynamic> _$PagingToJson(Paging instance) => <String, dynamic>{
      'next': instance.next,
    };
