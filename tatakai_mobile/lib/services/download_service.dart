import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tatakai_mobile/config/env.dart';
import 'package:tatakai_mobile/models/download.dart';

class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  final Map<String, double> _progress = {};
  
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit permission for app storage
  }
  
  Future<String> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final Directory? externalDir = await getExternalStorageDirectory();
      final String downloadPath = '${externalDir!.path}/Tatakai/Downloads';
      final Directory downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadPath;
    } else {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String downloadPath = '${appDocDir.path}/Downloads';
      final Directory downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadPath;
    }
  }
  
  Future<Download> startDownload({
    required Download download,
    required Function(double) onProgress,
    required Function(Download) onComplete,
    required Function(String) onError,
  }) async {
    try {
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }
      
      final cancelToken = CancelToken();
      _cancelTokens[download.id] = cancelToken;
      
      final downloadDir = await getDownloadDirectory();
      final fileName = '${download.animeId}_ep${download.episodeNumber}_${download.quality}.mp4';
      final filePath = '$downloadDir/$fileName';
      
      await _dio.download(
        download.videoUrl,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _progress[download.id] = progress;
            onProgress(progress);
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Accept': '*/*',
          },
        ),
      );
      
      final completedDownload = download.copyWith(
        status: DownloadStatus.completed,
        downloadedBytes: download.totalBytes,
        updatedAt: DateTime.now(),
      );
      
      _cancelTokens.remove(download.id);
      _progress.remove(download.id);
      
      onComplete(completedDownload);
      return completedDownload;
      
    } catch (e) {
      _cancelTokens.remove(download.id);
      _progress.remove(download.id);
      
      if (e is DioException && CancelToken.isCancel(e)) {
        onError('Download cancelled');
      } else {
        onError(e.toString());
      }
      
      return download.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
    }
  }
  
  void pauseDownload(String downloadId) {
    final cancelToken = _cancelTokens[downloadId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download paused');
    }
  }
  
  void cancelDownload(String downloadId) {
    final cancelToken = _cancelTokens[downloadId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled');
    }
    _cancelTokens.remove(downloadId);
    _progress.remove(downloadId);
  }
  
  double? getProgress(String downloadId) {
    return _progress[downloadId];
  }
  
  Future<void> deleteDownload(Download download) async {
    final file = File(download.localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
  
  Future<int> getTotalDownloadedSize() async {
    final downloadDir = await getDownloadDirectory();
    final dir = Directory(downloadDir);
    
    if (!await dir.exists()) return 0;
    
    int totalSize = 0;
    await for (final entity in dir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        totalSize += stat.size;
      }
    }
    
    return totalSize;
  }
  
  Future<List<FileSystemEntity>> getDownloadedFiles() async {
    final downloadDir = await getDownloadDirectory();
    final dir = Directory(downloadDir);
    
    if (!await dir.exists()) return [];
    
    return await dir.list().toList();
  }
  
  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
