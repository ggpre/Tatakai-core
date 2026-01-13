import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;
  final int likes;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
    this.likes = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}