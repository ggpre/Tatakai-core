import 'package:json_annotation/json_annotation.dart';

part 'episode_model.g.dart';

@JsonSerializable()
class EpisodeData {
  final int number;
  final String title;
  final String episodeId;
  final bool isFiller;
  
  EpisodeData({
    required this.number,
    required this.title,
    required this.episodeId,
    required this.isFiller,
  });
  
  factory EpisodeData.fromJson(Map<String, dynamic> json) => 
      _$EpisodeDataFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeDataToJson(this);
}

@JsonSerializable()
class EpisodeList {
  final int totalEpisodes;
  final List<EpisodeData> episodes;
  
  EpisodeList({
    required this.totalEpisodes,
    required this.episodes,
  });
  
  factory EpisodeList.fromJson(Map<String, dynamic> json) => 
      _$EpisodeListFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeListToJson(this);
}

@JsonSerializable()
class EpisodeServer {
  final int serverId;
  final String serverName;
  
  EpisodeServer({
    required this.serverId,
    required this.serverName,
  });
  
  factory EpisodeServer.fromJson(Map<String, dynamic> json) => 
      _$EpisodeServerFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeServerToJson(this);
}

@JsonSerializable()
class EpisodeServers {
  final String episodeId;
  final int episodeNo;
  final List<EpisodeServer> sub;
  final List<EpisodeServer> dub;
  final List<EpisodeServer> raw;
  
  EpisodeServers({
    required this.episodeId,
    required this.episodeNo,
    required this.sub,
    required this.dub,
    required this.raw,
  });
  
  factory EpisodeServers.fromJson(Map<String, dynamic> json) => 
      _$EpisodeServersFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeServersToJson(this);
}

@JsonSerializable()
class StreamingSource {
  final String url;
  final bool isM3U8;
  final String? quality;
  final String? language;
  final String? langCode;
  final bool? isDub;
  final String? providerName;
  final bool? needsHeadless;
  final bool? isEmbed;
  
  StreamingSource({
    required this.url,
    required this.isM3U8,
    this.quality,
    this.language,
    this.langCode,
    this.isDub,
    this.providerName,
    this.needsHeadless,
    this.isEmbed,
  });
  
  factory StreamingSource.fromJson(Map<String, dynamic> json) => 
      _$StreamingSourceFromJson(json);
  Map<String, dynamic> toJson() => _$StreamingSourceToJson(this);
}

@JsonSerializable()
class Subtitle {
  final String lang;
  final String url;
  final String? label;
  
  Subtitle({
    required this.lang,
    required this.url,
    this.label,
  });
  
  factory Subtitle.fromJson(Map<String, dynamic> json) => 
      _$SubtitleFromJson(json);
  Map<String, dynamic> toJson() => _$SubtitleToJson(this);
}

@JsonSerializable()
class StreamingHeaders {
  @JsonKey(name: 'Referer')
  final String referer;
  
  @JsonKey(name: 'User-Agent')
  final String userAgent;
  
  StreamingHeaders({
    required this.referer,
    required this.userAgent,
  });
  
  factory StreamingHeaders.fromJson(Map<String, dynamic> json) => 
      _$StreamingHeadersFromJson(json);
  Map<String, dynamic> toJson() => _$StreamingHeadersToJson(this);
}

@JsonSerializable()
class SkipTime {
  final int start;
  final int end;
  
  SkipTime({required this.start, required this.end});
  
  factory SkipTime.fromJson(Map<String, dynamic> json) => 
      _$SkipTimeFromJson(json);
  Map<String, dynamic> toJson() => _$SkipTimeToJson(this);
}

@JsonSerializable()
class StreamingData {
  final StreamingHeaders headers;
  final List<StreamingSource> sources;
  final List<Subtitle> subtitles;
  final List<Subtitle>? tracks;
  final int? anilistID;
  final int? malID;
  final SkipTime? intro;
  final SkipTime? outro;
  
  StreamingData({
    required this.headers,
    required this.sources,
    required this.subtitles,
    this.tracks,
    this.anilistID,
    this.malID,
    this.intro,
    this.outro,
  });
  
  factory StreamingData.fromJson(Map<String, dynamic> json) => 
      _$StreamingDataFromJson(json);
  Map<String, dynamic> toJson() => _$StreamingDataToJson(this);
}
