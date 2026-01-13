import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  
  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'],
      displayName: user.userMetadata?['display_name'],
      avatarUrl: user.userMetadata?['avatar_url'],
      bio: user.userMetadata?['bio'],
      role: user.userMetadata?['role'] ?? 'user',
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: user.updatedAt != null ? DateTime.parse(user.updatedAt!) : DateTime.now(),
      preferences: user.userMetadata?['preferences'],
    );
  }
  
  bool get isAdmin => role == 'admin';
  bool get isBanned => role == 'banned';
}

@JsonSerializable()
class UserProfile {
  final String id;
  final String email;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String role; // 'user', 'admin', 'banned'
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? preferences;
  final String? bannerUrl;
  final bool isPublic;
  final String? fcmToken;
  
  UserProfile({
    required this.id,
    required this.email,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.bannerUrl,
    this.bio,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.isPublic = true,
    this.fcmToken,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String? ?? '', // Fallback or fetch from auth
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      fcmToken: json['fcm_token'] as String?,
      bio: json['bio'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
  
  bool get isAdmin => false; // This class no longer has a 'role' property
  bool get isBanned => false; // This class no longer has a 'role' property
}

@JsonSerializable()
class UserPreferences {
  final String theme;
  final String videoQuality; // '480p', '720p', '1080p', 'auto'
  final double playbackSpeed;
  final bool autoSkipIntro;
  final bool autoSkipOutro;
  final bool autoPlayNext;
  final String subtitleLanguage;
  final double subtitleSize;
  final String subtitleColor;
  final bool enableAnalytics;
  final bool enableNotifications;
  final bool downloadOnWifiOnly;
  final String downloadQuality;
  
  UserPreferences({
    this.theme = 'default_dark',
    this.videoQuality = 'auto',
    this.playbackSpeed = 1.0,
    this.autoSkipIntro = false,
    this.autoSkipOutro = false,
    this.autoPlayNext = true,
    this.subtitleLanguage = 'English',
    this.subtitleSize = 1.0,
    this.subtitleColor = '#FFFFFF',
    this.enableAnalytics = true,
    this.enableNotifications = true,
    this.downloadOnWifiOnly = true,
    this.downloadQuality = '720p',
  });
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) => 
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
  
  UserPreferences copyWith({
    String? theme,
    String? videoQuality,
    double? playbackSpeed,
    bool? autoSkipIntro,
    bool? autoSkipOutro,
    bool? autoPlayNext,
    String? subtitleLanguage,
    double? subtitleSize,
    String? subtitleColor,
    bool? enableAnalytics,
    bool? enableNotifications,
    bool? downloadOnWifiOnly,
    String? downloadQuality,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      videoQuality: videoQuality ?? this.videoQuality,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      autoSkipIntro: autoSkipIntro ?? this.autoSkipIntro,
      autoSkipOutro: autoSkipOutro ?? this.autoSkipOutro,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
      subtitleLanguage: subtitleLanguage ?? this.subtitleLanguage,
      subtitleSize: subtitleSize ?? this.subtitleSize,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      downloadOnWifiOnly: downloadOnWifiOnly ?? this.downloadOnWifiOnly,
      downloadQuality: downloadQuality ?? this.downloadQuality,
    );
  }
}

@JsonSerializable()
class WatchHistory {
  final String id;
  final String userId;
  final String animeId;
  final String animeName;
  final String? animePoster;
  final int episodeNumber;
  final String episodeId;
  final String? episodeTitle;
  final int progress; // seconds
  final int duration; // seconds
  final DateTime watchedAt;
  final DateTime updatedAt;
  
  WatchHistory({
    required this.id,
    required this.userId,
    required this.animeId,
    required this.animeName,
    this.animePoster,
    required this.episodeNumber,
    required this.episodeId,
    this.episodeTitle,
    required this.progress,
    required this.duration,
    required this.watchedAt,
    required this.updatedAt,
  });
  
  factory WatchHistory.fromJson(Map<String, dynamic> json) => 
      _$WatchHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$WatchHistoryToJson(this);
  
  double get progressPercentage => duration > 0 ? (progress / duration) : 0.0;
  bool get isCompleted => progressPercentage >= 0.9;
}

@JsonSerializable()
class WatchlistItem {
  final String id;
  final String userId;
  final String animeId;
  final String animeName;
  final String? animePoster;
  final String status; // 'watching', 'completed', 'plan_to_watch', 'dropped', 'on_hold'
  final int? progress;
  final int? totalEpisodes;
  final double? score;
  final DateTime updatedAt;

  WatchlistItem({
    required this.id,
    required this.userId,
    required this.animeId,
    required this.animeName,
    this.animePoster,
    required this.status,
    this.progress,
    this.totalEpisodes,
    this.score,
    required this.updatedAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      animeId: json['anime_id'] as String,
      animeName: json['anime_name'] as String,
      animePoster: json['anime_poster'] as String?,
      status: json['status'] as String? ?? 'plan_to_watch',
      progress: json['progress'] as int?,
      totalEpisodes: json['total_episodes'] as int?,
      score: (json['score'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Favorite { // Keeping this class for now to avoid breaking too many files, but it will map to WatchlistItem
  final String id;
  final String userId;
  final String animeId;
  final String animeName;
  final String animePoster;

  Favorite({
    required this.id,
    required this.userId,
    required this.animeId,
    required this.animeName,
    required this.animePoster,
    this.fallbackDate,
  });

  factory Favorite.fromWatchlist(WatchlistItem item) {
    return Favorite(
      id: item.id,
      userId: item.userId,
      animeId: item.animeId,
      animeName: item.animeName,
      animePoster: item.animePoster ?? '',
      // Map updatedAt to addedAt for compatibility
      fallbackDate: item.updatedAt,
    );
  }
  
  final DateTime? fallbackDate;
  
  DateTime get addedAt => fallbackDate ?? DateTime.now();
  
  factory Favorite.fromJson(Map<String, dynamic> json) {
     return Favorite(
       id: json['id'] as String? ?? '',
       userId: json['user_id'] as String? ?? '',
       animeId: json['anime_id'] as String? ?? '',
       animeName: json['anime_name'] as String? ?? '',
       animePoster: json['anime_poster'] as String? ?? '',
       // Try to parse added_at if it exists, else null
       fallbackDate: json['added_at'] != null ? DateTime.tryParse(json['added_at']) : null,
     );
  }
}
