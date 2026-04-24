import 'package:json_annotation/json_annotation.dart';

part 'anime.g.dart';

@JsonSerializable()
class AnimeDTO {
  final List<AnimeData> data;
  final Paging? paging;

  AnimeDTO({required this.data, this.paging});

  factory AnimeDTO.fromJson(Map<String, dynamic> json) => _$AnimeDTOFromJson(json);

  Map<String, dynamic> toJson() => _$AnimeDTOToJson(this);

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

@JsonSerializable()
class UserAnimeListDTO {
  final List<UserAnimeData> data;
  final Paging? paging;

  UserAnimeListDTO({required this.data, this.paging});

  factory UserAnimeListDTO.fromJson(Map<String, dynamic> json) => _$UserAnimeListDTOFromJson(json);

  Map<String, dynamic> toJson() => _$UserAnimeListDTOToJson(this);
}

@JsonSerializable()
class UserAnimeData {
  final Node node;
  @JsonKey(name: 'list_status')
  final ListStatus listStatus;

  UserAnimeData({required this.node, required this.listStatus});

  factory UserAnimeData.fromJson(Map<String, dynamic> json) => _$UserAnimeDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserAnimeDataToJson(this);
}

@JsonSerializable()
class ListStatus {
  final String status;
  final int score;
  @JsonKey(name: 'num_episodes_watched')
  final int numEpisodesWatched;
  @JsonKey(name: 'is_rewatching')
  final bool isRewatching;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  ListStatus({required this.status, required this.score, required this.numEpisodesWatched, required this.isRewatching, required this.updatedAt});

  factory ListStatus.fromJson(Map<String, dynamic> json) => _$ListStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ListStatusToJson(this);
}
