import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

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
  
  UserProfile({
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
  
  factory UserProfile.fromJson(Map<String, dynamic> json) => 
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
  
  bool get isAdmin => role == 'admin';
  bool get isBanned => role == 'banned';
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
class Favorite {
  final String id;
  final String userId;
  final String animeId;
  final String animeName;
  final String? animePoster;
  final DateTime addedAt;
  
  Favorite({
    required this.id,
    required this.userId,
    required this.animeId,
    required this.animeName,
    this.animePoster,
    required this.addedAt,
  });
  
  factory Favorite.fromJson(Map<String, dynamic> json) => 
      _$FavoriteFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}
