import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
class Playlist {
  final String id;
  final String userId;
  final String name;
  final String? description;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'items_count', defaultValue: 0)
  final int itemsCount;
  @JsonKey(name: 'is_public', defaultValue: false)
  final bool isPublic;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  
  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverImage,
    this.itemsCount = 0,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}

@JsonSerializable()
class PlaylistItem {
  final String id;
  final String playlistId;
  final String animeId;
  final String animeName;
  final String? animePoster;
  final DateTime addedAt;

  PlaylistItem({
    required this.id,
    required this.playlistId,
    required this.animeId,
    required this.animeName,
    this.animePoster,
    required this.addedAt,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) => _$PlaylistItemFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistItemToJson(this);
}