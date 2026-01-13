import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tatakai_mobile/models/download.dart';
import 'package:tatakai_mobile/services/download_service.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) => DownloadService());

final downloadsProvider = StateNotifierProvider<DownloadsNotifier, List<Download>>((ref) {
  return DownloadsNotifier(ref.read(downloadServiceProvider));
});

class DownloadsNotifier extends StateNotifier<List<Download>> {
  final DownloadService _downloadService;
  final Box _box = Hive.box('downloads');
  Timer? _progressTimer;

  DownloadsNotifier(this._downloadService) : super([]) {
    _loadDownloads();
  }

  void _loadDownloads() {
    final List<Download> loaded = [];
    for (var i = 0; i < _box.length; i++) {
      final map = _box.getAt(i);
      if (map is Map) {
        try {
          // Hive stores Map<dynamic, dynamic>, need to cast to Map<String, dynamic>
          final jsonMap = Map<String, dynamic>.from(map);
          loaded.add(Download.fromJson(jsonMap));
        } catch (e) {
          print('Error parsing download at index $i: $e');
        }
      }
    }
    // Sort by createdAt desc
    loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = loaded;

    // Resume or fail pending downloads on restart? 
    // For now, mark downloading as paused or failed if app killed
    for (var download in state) {
      if (download.status == DownloadStatus.downloading) {
        // Mark as paused effectively since we lost the ephemeral handle
        _updateDownloadStatus(download.id, DownloadStatus.paused);
      }
    }
  }

  Future<void> _saveDownload(Download download) async {
    // Check if exists
    final index = state.indexWhere((d) => d.id == download.id);
    if (index != -1) {
      // Update in box
      // We need to find the key in box. We used auto-increment keys or custom keys?
      // If we use put(id, data), it's easier.
      // Let's assume we use id as key.
      await _box.put(download.id, download.toJson());
      
      // Update state
      final newState = [...state];
      newState[index] = download;
      state = newState;
    } else {
      // New
      await _box.put(download.id, download.toJson());
      state = [download, ...state];
    }
  }

  Future<void> startDownload(Download download) async {
    // Add to list first as pending
    var activeDownload = download.copyWith(
      status: DownloadStatus.pending,
      updatedAt: DateTime.now(),
    );
    await _saveDownload(activeDownload);

    activeDownload = activeDownload.copyWith(status: DownloadStatus.downloading);
    await _saveDownload(activeDownload);

    try {
      await _downloadService.startDownload(
        download: activeDownload,
        onProgress: (progress) {
          // Update progress in state but throttle box writes
          // Actually, updating state triggers rebuilds. 
          // We can throttle state updates or just update.
          // Since this is one active download, it might be fine.
          // But creating new Download object every frame is expensive.
          // We can use a separate provider for progress or just update less frequently.
          
          // For simplicity, we optimize by not saving to Hive every progress tick, only state.
          final index = state.indexWhere((d) => d.id == activeDownload.id);
          if (index != -1) {
            final current = state[index];
            // Only update if progress changed significantly > 1%
            // Or just update.
            final newDownloadedBytes = (progress * current.totalBytes).toInt();
            
             // Create updated object
             final updated = current.copyWith(
               downloadedBytes: newDownloadedBytes,
               status: DownloadStatus.downloading,
             );
             
             // Update state directly for UI
             final newState = [...state];
             newState[index] = updated;
             state = newState;
          }
        },
        onComplete: (completed) {
           _saveDownload(completed);
        },
        onError: (error) {
          final failed = state.firstWhere((d) => d.id == activeDownload.id).copyWith(
            status: DownloadStatus.failed,
            errorMessage: error,
            updatedAt: DateTime.now(),
          );
          _saveDownload(failed);
        },
      );
    } catch (e) {
      final failed = activeDownload.copyWith(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
        updatedAt: DateTime.now(),
      );
      await _saveDownload(failed);
    }
  }

  Future<void> pauseDownload(String id) async {
    _downloadService.pauseDownload(id);
    _updateDownloadStatus(id, DownloadStatus.paused);
  }

  Future<void> resumeDownload(String id) async {
    final download = state.firstWhere((d) => d.id == id);
    if (download.canResume) {
      startDownload(download);
    }
  }

  Future<void> deleteDownload(String id) async {
    final download = state.firstWhere((d) => d.id == id);
    
    // Cancel if running
    if (download.status == DownloadStatus.downloading) {
      _downloadService.cancelDownload(id);
    }
    
    // Delete file
    await _downloadService.deleteDownload(download);
    
    // Remove from Hive
    await _box.delete(id);
    
    // Remove from state
    state = state.where((d) => d.id != id).toList();
  }

  Future<void> _updateDownloadStatus(String id, DownloadStatus status) async {
    final index = state.indexWhere((d) => d.id == id);
    if (index != -1) {
      final updated = state[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _saveDownload(updated);
    }
  }
}
