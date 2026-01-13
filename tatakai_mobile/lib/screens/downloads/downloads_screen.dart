import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/models/download.dart';
import 'package:tatakai_mobile/providers/download_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});
  
  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  bool _isSelecting = false;
  final Set<String> _selectedItems = {}; // Changed to String for IDs
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final downloads = ref.watch(downloadsProvider);
    
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: _buildAppBar(downloads),
      body: _buildContent(downloads),
    );
  }
  
  PreferredSizeWidget _buildAppBar(List<Download> downloads) {
    return AppBar(
      backgroundColor: AppThemes.darkBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _isSelecting 
            ? '${_selectedItems.length} selected' 
            : 'Downloads',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isSelecting) ...[
          IconButton(
            icon: const Icon(Icons.select_all, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_selectedItems.length == downloads.length) {
                  _selectedItems.clear();
                } else {
                  _selectedItems.addAll(downloads.map((d) => d.id));
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _selectedItems.isNotEmpty 
                ? () => _showDeleteDialog() 
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSelecting = false;
                _selectedItems.clear();
              });
            },
          ),
        ] else ...[
          if (downloads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.checklist, color: Colors.white),
              onPressed: () {
                setState(() => _isSelecting = true);
              },
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptionsMenu(downloads),
          ),
        ],
      ],
    );
  }
  
  Widget _buildContent(List<Download> downloads) {
    if (downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceXl),
              decoration: BoxDecoration(
                color: AppThemes.darkSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.download_done,
                size: 48,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: AppThemes.spaceLg),
            const Text(
              'No downloads yet',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
  
    return Column(
      children: [
        // Storage info
        _buildStorageInfo(downloads),
        
        // Downloads list
        Expanded(
          child: _buildDownloadsList(downloads),
        ),
      ],
    );
  }
  
  Widget _buildStorageInfo(List<Download> downloads) {
    // Calculate storage used by app downloads
    int usedBytes = downloads.fold(0, (sum, d) => sum + d.downloadedBytes);
    String usedString = _formatBytes(usedBytes);
    
    return Container(
      margin: const EdgeInsets.all(AppThemes.spaceLg),
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppThemes.accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: const Icon(
              Icons.folder,
              color: AppThemes.accentPink,
              size: 26,
            ),
          ),
          const SizedBox(width: AppThemes.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storage Used',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceXs),
                Text(
                  '$usedString used by downloads',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDownloadsList(List<Download> downloads) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        return _buildDownloadItem(downloads[index]);
      },
    );
  }
  
  Widget _buildDownloadItem(Download download) {
    final isSelected = _selectedItems.contains(download.id);
    final isDownloading = download.status == DownloadStatus.downloading;
    final isPaused = download.status == DownloadStatus.paused;
    final isFailed = download.status == DownloadStatus.failed;
    
    // Determine progress and status color
    double progress = download.progress;
    Color statusColor = AppThemes.ratingGreen;
    IconData statusIcon = Icons.check_circle;
    
    if (isDownloading) {
      statusColor = AppThemes.accentPink;
      statusIcon = Icons.downloading;
    } else if (isPaused) {
      statusColor = Colors.orange;
      statusIcon = Icons.pause_circle;
    } else if (isFailed) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    }
    
    return GestureDetector(
      onTap: () {
        if (_isSelecting) {
          setState(() {
            if (isSelected) {
              _selectedItems.remove(download.id);
            } else {
              _selectedItems.add(download.id);
            }
          });
        } else if (download.isComplete) {
          // Play downloaded video
          // context.push('/watch/local/${download.id}'); // Need to implement local playback in WatchScreen or separate
          // For now, retry WatchScreen but with local file support if possible, or new route
          // Assuming WatchScreen can handle local files or we pass path?
          // The current WatchScreen uses ApiService.
          // Let's implement a simple snackbar for now or try to push watch screen
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Playing local file not fully wired yet')),
          );
        } else if (isDownloading) {
           ref.read(downloadsProvider.notifier).pauseDownload(download.id);
        } else if (isPaused || isFailed) {
           ref.read(downloadsProvider.notifier).resumeDownload(download.id);
        }
      },
      onLongPress: () {
        if (!_isSelecting) {
          setState(() {
            _isSelecting = true;
            _selectedItems.add(download.id);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
        padding: const EdgeInsets.all(AppThemes.spaceMd),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppThemes.accentPink.withOpacity(0.1) 
              : AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          border: isSelected 
              ? Border.all(color: AppThemes.accentPink, width: 2) 
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection checkbox
            if (_isSelecting)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: AppThemes.spaceMd),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppThemes.accentPink 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected 
                        ? AppThemes.accentPink 
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            
            // Thumbnail
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppThemes.darkBackground,
                    borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                    image: download.animePoster != null 
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(download.animePoster!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: download.animePoster == null 
                      ? const Center(child: Icon(Icons.movie, size: 28, color: Colors.white24))
                      : null,
                ),
                if (isDownloading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppThemes.accentPink,
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppThemes.spaceMd),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download.animeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Episode ${download.episodeNumber}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceSm),
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDownloading
                            ? '${(progress * 100).toInt()}%'
                            : isFailed ? 'Failed' : download.totalSizeInMB,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: AppThemes.spaceMd),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppThemes.spaceSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemes.darkBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          download.quality,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            if (!_isSelecting)
              IconButton(
                icon: Icon(
                  isDownloading ? Icons.pause_circle_outline : Icons.more_vert,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: () {
                   if (isDownloading) {
                     ref.read(downloadsProvider.notifier).pauseDownload(download.id);
                   } else {
                     _showItemMenu(download);
                   }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showItemMenu(Download download) {
     showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.darkSurface,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                 leading: const Icon(Icons.play_arrow, color: Colors.white),
                 title: const Text('Play', style: TextStyle(color: Colors.white)),
                 onTap: () {
                    Navigator.pop(context);
                    // Play logic
                 }
              ),
              ListTile(
                 leading: const Icon(Icons.delete_outline, color: Colors.red),
                 title: const Text('Delete', style: TextStyle(color: Colors.red)),
                 onTap: () {
                    Navigator.pop(context);
                    ref.read(downloadsProvider.notifier).deleteDownload(download.id);
                 }
              ),
            ],
          ),
        );
      }
     );
  }
  
  void _showOptionsMenu(List<Download> downloads) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppThemes.radiusXLarge),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppThemes.spaceMd),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete All',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAllDialog(downloads);
                },
              ),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text(
            'Delete Downloads',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Delete ${_selectedItems.length} selected items?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                for (var id in _selectedItems) {
                   ref.read(downloadsProvider.notifier).deleteDownload(id);
                }
                setState(() {
                  _selectedItems.clear();
                  _isSelecting = false;
                });
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeleteAllDialog(List<Download> downloads) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text(
            'Delete All Downloads',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete all downloads? This action cannot be undone.',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                 for (var d in downloads) {
                   ref.read(downloadsProvider.notifier).deleteDownload(d.id);
                }
              },
              child: const Text(
                'Delete All',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
