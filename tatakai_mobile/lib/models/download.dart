import 'package:json_annotation/json_annotation.dart';

part 'download.g.dart';

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
  cancelled,
}

@JsonSerializable()
class Download {
  final String id;
  final String userId;
  final String animeId;
  final String animeName;
  final String? animePoster;
  final int episodeNumber;
  final String episodeId;
  final String episodeTitle;
  final String quality;
  final String videoUrl;
  final String localPath;
  final int totalBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? errorMessage;
  
  Download({
    required this.id,
    required this.userId,
    required this.animeId,
    required this.animeName,
    this.animePoster,
    required this.episodeNumber,
    required this.episodeId,
    required this.episodeTitle,
    required this.quality,
    required this.videoUrl,
    required this.localPath,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.errorMessage,
  });
  
  factory Download.fromJson(Map<String, dynamic> json) => 
      _$DownloadFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadToJson(this);
  
  double get progress => totalBytes > 0 ? (downloadedBytes / totalBytes) : 0.0;
  
  String get sizeInMB => '${(downloadedBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  String get totalSizeInMB => '${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  
  bool get isComplete => status == DownloadStatus.completed;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get canResume => status == DownloadStatus.paused || status == DownloadStatus.failed;
  
  Download copyWith({
    DownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    String? errorMessage,
    DateTime? updatedAt,
  }) {
    return Download(
      id: id,
      userId: userId,
      animeId: animeId,
      animeName: animeName,
      animePoster: animePoster,
      episodeNumber: episodeNumber,
      episodeId: episodeId,
      episodeTitle: episodeTitle,
      quality: quality,
      videoUrl: videoUrl,
      localPath: localPath,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@JsonSerializable()
class DownloadQueue {
  final List<Download> queue;
  final int maxConcurrent;
  final int activeDownloads;
  
  DownloadQueue({
    required this.queue,
    this.maxConcurrent = 3,
    required this.activeDownloads,
  });
  
  factory DownloadQueue.fromJson(Map<String, dynamic> json) => 
      _$DownloadQueueFromJson(json);
  Map<String, dynamic> toJson() => _$DownloadQueueToJson(this);
  
  bool get canStartNew => activeDownloads < maxConcurrent;
  List<Download> get activeItems => 
      queue.where((d) => d.isDownloading).toList();
  List<Download> get pendingItems => 
      queue.where((d) => d.status == DownloadStatus.pending).toList();
  List<Download> get completedItems => 
      queue.where((d) => d.isComplete).toList();
}
