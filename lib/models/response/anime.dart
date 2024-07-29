import 'package:json_annotation/json_annotation.dart';

part 'anime.g.dart';

@JsonSerializable()
class Anime {
  final List<AnimeData> data;
  final Paging? paging;

  Anime({required this.data, this.paging});

  factory Anime.fromJson(Map<String, dynamic> json) => _$AnimeFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeToJson(this);

  @override
  String toString() {
    return 'Anime(data: $data, paging: $paging)';
  }
}

@JsonSerializable()
class AnimeData {
  final Node node;

  AnimeData({required this.node});

  factory AnimeData.fromJson(Map<String, dynamic> json) =>
      _$AnimeDataFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeDataToJson(this);

  @override
  String toString() {
    return 'AnimeData(node: $node)';
  }
}

@JsonSerializable()
class Node {
  final int id;
  final String title;
  @JsonKey(name: 'main_picture')
  final MainPicture? mainPicture;

  Node({required this.id, required this.title, this.mainPicture});

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);

  @override
  String toString() {
    return 'Node(id: $id, title: $title, mainPicture: $mainPicture)';
  }
}

@JsonSerializable()
class MainPicture {
  final String medium;
  final String large;

  MainPicture({required this.medium, required this.large});

  factory MainPicture.fromJson(Map<String, dynamic> json) =>
      _$MainPictureFromJson(json);

  Map<String, dynamic> toJson() => _$MainPictureToJson(this);

  @override
  String toString() {
    return 'MainPicture(medium: $medium, large: $large)';
  }
}

@JsonSerializable()
class Paging {
  final String? next;

  Paging({this.next});

  factory Paging.fromJson(Map<String, dynamic> json) => _$PagingFromJson(json);

  Map<String, dynamic> toJson() => _$PagingToJson(this);

  @override
  String toString() {
    return 'Paging(next: $next)';
  }
}
