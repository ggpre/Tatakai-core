import 'package:json_annotation/json_annotation.dart';

part 'anime.g.dart';

@JsonSerializable()
class Episode {
  @JsonKey(defaultValue: 0)
  final int sub;
  @JsonKey(defaultValue: 0)
  final int dub;
  
  Episode({required this.sub, required this.dub});
  
  factory Episode.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: API sometimes returns null or missing fields
    int parseNum(dynamic v) {
      try {
        if (v == null) return 0;
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
        return 0;
      } catch (e) {
        return 0;
      }
    }

    final sub = parseNum(json['sub']);
    final dub = parseNum(json['dub']);
    return Episode(sub: sub, dub: dub);
  }

  Map<String, dynamic> toJson() => _$EpisodeToJson(this);
}

@JsonSerializable()
class AnimeCard {
  final String id;
  final String name;
  final String? jname;
  final String poster;
  final String? type;
  final String? duration;
  final String? rating;
  final Episode episodes;
  
  AnimeCard({
    required this.id,
    required this.name,
    this.jname,
    required this.poster,
    this.type,
    this.duration,
    this.rating,
    required this.episodes,
  });
  
  factory AnimeCard.fromJson(Map<String, dynamic> json) => _$AnimeCardFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeCardToJson(this);
}

@JsonSerializable()
class SpotlightAnime {
  final String id;
  final String name;
  final String jname;
  final String poster;
  final String description;
  final int rank;
  final List<String> otherInfo;
  final Episode episodes;
  
  SpotlightAnime({
    required this.id,
    required this.name,
    required this.jname,
    required this.poster,
    required this.description,
    required this.rank,
    required this.otherInfo,
    required this.episodes,
  });
  
  factory SpotlightAnime.fromJson(Map<String, dynamic> json) => 
      _$SpotlightAnimeFromJson(json);
  Map<String, dynamic> toJson() => _$SpotlightAnimeToJson(this);
}

@JsonSerializable()
class TrendingAnime {
  final String id;
  final String name;
  final String poster;
  final int rank;
  
  TrendingAnime({
    required this.id,
    required this.name,
    required this.poster,
    required this.rank,
  });
  
  factory TrendingAnime.fromJson(Map<String, dynamic> json) => 
      _$TrendingAnimeFromJson(json);
  Map<String, dynamic> toJson() => _$TrendingAnimeToJson(this);
}

@JsonSerializable()
class TopAnime {
  final String id;
  final String name;
  final String poster;
  final int rank;
  final Episode episodes;
  
  TopAnime({
    required this.id,
    required this.name,
    required this.poster,
    required this.rank,
    required this.episodes,
  });
  
  factory TopAnime.fromJson(Map<String, dynamic> json) => 
      _$TopAnimeFromJson(json);
  Map<String, dynamic> toJson() => _$TopAnimeToJson(this);
}

@JsonSerializable()
class Top10Animes {
  final List<TopAnime> today;
  final List<TopAnime> week;
  final List<TopAnime> month;
  
  Top10Animes({
    required this.today,
    required this.week,
    required this.month,
  });
  
  factory Top10Animes.fromJson(Map<String, dynamic> json) => 
      _$Top10AnimesFromJson(json);
  Map<String, dynamic> toJson() => _$Top10AnimesToJson(this);
}

@JsonSerializable()
class HomeData {
  final List<String> genres;
  final List<AnimeCard> latestEpisodeAnimes;
  final List<SpotlightAnime> spotlightAnimes;
  final Top10Animes top10Animes;
  final List<AnimeCard> topAiringAnimes;
  final List<AnimeCard> topUpcomingAnimes;
  final List<TrendingAnime> trendingAnimes;
  final List<AnimeCard> mostPopularAnimes;
  final List<AnimeCard> mostFavoriteAnimes;
  final List<AnimeCard> latestCompletedAnimes;
  
  HomeData({
    required this.genres,
    required this.latestEpisodeAnimes,
    required this.spotlightAnimes,
    required this.top10Animes,
    required this.topAiringAnimes,
    required this.topUpcomingAnimes,
    required this.trendingAnimes,
    required this.mostPopularAnimes,
    required this.mostFavoriteAnimes,
    required this.latestCompletedAnimes,
  });
  
  factory HomeData.fromJson(Map<String, dynamic> json) => 
      _$HomeDataFromJson(json);
  Map<String, dynamic> toJson() => _$HomeDataToJson(this);
}

@JsonSerializable()
class AnimeStats {
  final String rating;
  final String quality;
  final Episode episodes;
  final String type;
  final String duration;
  
  AnimeStats({
    required this.rating,
    required this.quality,
    required this.episodes,
    required this.type,
    required this.duration,
  });
  
  factory AnimeStats.fromJson(Map<String, dynamic> json) {
    return AnimeStats(
      rating: json['rating'] as String? ?? 'N/A',
      quality: json['quality'] as String? ?? 'HD',
      episodes: json['episodes'] != null 
          ? Episode.fromJson(json['episodes'] as Map<String, dynamic>)
          : Episode(sub: 0, dub: 0),
      type: json['type'] as String? ?? 'TV',
      duration: json['duration'] as String? ?? 'Unknown',
    );
  }
  
  Map<String, dynamic> toJson() => _$AnimeStatsToJson(this);
}

@JsonSerializable()
class Character {
  final String id;
  final String poster;
  final String name;
  final String cast;
  
  Character({
    required this.id,
    required this.poster,
    required this.name,
    required this.cast,
  });
  
  factory Character.fromJson(Map<String, dynamic> json) => 
      _$CharacterFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}

@JsonSerializable()
class CharacterVoiceActor {
  final Character character;
  final Character voiceActor;
  
  CharacterVoiceActor({
    required this.character,
    required this.voiceActor,
  });
  
  factory CharacterVoiceActor.fromJson(Map<String, dynamic> json) => 
      _$CharacterVoiceActorFromJson(json);
  Map<String, dynamic> toJson() => _$CharacterVoiceActorToJson(this);
}

@JsonSerializable()
class PromotionalVideo {
  final String? title;
  final String? source;
  final String? thumbnail;
  
  PromotionalVideo({this.title, this.source, this.thumbnail});
  
  factory PromotionalVideo.fromJson(Map<String, dynamic> json) => 
      _$PromotionalVideoFromJson(json);
  Map<String, dynamic> toJson() => _$PromotionalVideoToJson(this);
}

@JsonSerializable()
class AnimeInfoData {
  final String id;
  final String name;
  final String poster;
  final String description;
  final AnimeStats stats;
  @JsonKey(defaultValue: [])
  final List<PromotionalVideo> promotionalVideos;
  @JsonKey(defaultValue: [])
  final List<CharacterVoiceActor> characterVoiceActor;
  final int? anilistId;
  final int? malId;
  
  AnimeInfoData({
    required this.id,
    required this.name,
    required this.poster,
    required this.description,
    required this.stats,
    this.promotionalVideos = const [],
    this.characterVoiceActor = const [],
    this.anilistId,
    this.malId,
  });
  
  factory AnimeInfoData.fromJson(Map<String, dynamic> json) {
    // Handle null arrays gracefully
    final promoVideos = json['promotionalVideos'];
    final castList = json['characterVoiceActor'];
    
    return AnimeInfoData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      poster: json['poster'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stats: AnimeStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      promotionalVideos: promoVideos == null
          ? []
          : (promoVideos as List).map((e) => PromotionalVideo.fromJson(e as Map<String, dynamic>)).toList(),
      characterVoiceActor: castList == null
          ? []
          : (castList as List).map((e) => CharacterVoiceActor.fromJson(e as Map<String, dynamic>)).toList(),
      anilistId: json['anilistId'] as int?,
      malId: json['malId'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() => _$AnimeInfoDataToJson(this);
}

@JsonSerializable()
class AnimeMoreInfo {
  final String aired;
  final List<String> genres;
  final String status;
  final String studios;
  final String duration;
  
  AnimeMoreInfo({
    required this.aired,
    required this.genres,
    required this.status,
    required this.studios,
    required this.duration,
  });
  
  factory AnimeMoreInfo.fromJson(Map<String, dynamic> json) {
    final genreList = json['genres'];
    return AnimeMoreInfo(
      aired: json['aired'] as String? ?? 'Unknown',
      genres: genreList == null 
          ? [] 
          : (genreList as List).map((e) => e.toString()).toList(),
      status: json['status'] as String? ?? 'Unknown',
      studios: json['studios'] as String? ?? 'Unknown',
      duration: json['duration'] as String? ?? 'Unknown',
    );
  }
  
  Map<String, dynamic> toJson() => _$AnimeMoreInfoToJson(this);
}

@JsonSerializable()
class AnimeInfo {
  final AnimeInfoData info;
  final AnimeMoreInfo moreInfo;
  
  AnimeInfo({
    required this.info,
    required this.moreInfo,
  });
  
  factory AnimeInfo.fromJson(Map<String, dynamic> json) => 
      _$AnimeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeInfoToJson(this);
}

@JsonSerializable()
class AnimeInfoResponse {
  final AnimeInfo anime;
  final List<AnimeCard> recommendedAnimes;
  final List<AnimeCard> relatedAnimes;
  
  AnimeInfoResponse({
    required this.anime,
    required this.recommendedAnimes,
    required this.relatedAnimes,
  });
  
  factory AnimeInfoResponse.fromJson(Map<String, dynamic> json) => 
      _$AnimeInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AnimeInfoResponseToJson(this);
}

@JsonSerializable()
class SearchResult {
  final List<AnimeCard> animes;
  final List<AnimeCard> mostPopularAnimes;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;
  final String searchQuery;
  
  SearchResult({
    required this.animes,
    required this.mostPopularAnimes,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
    required this.searchQuery,
  });
  
  factory SearchResult.fromJson(Map<String, dynamic> json) => 
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}
