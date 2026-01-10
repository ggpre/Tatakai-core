import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class DownloadsScreen extends ConsumerStatefulWidget {
  const DownloadsScreen({super.key});
  
  @override
  ConsumerState<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends ConsumerState<DownloadsScreen> {
  bool _isSelecting = false;
  final Set<int> _selectedItems = {};
  
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
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
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
                if (_selectedItems.length == 10) {
                  _selectedItems.clear();
                } else {
                  _selectedItems.addAll(List.generate(10, (i) => i));
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
          IconButton(
            icon: const Icon(Icons.checklist, color: Colors.white),
            onPressed: () {
              setState(() => _isSelecting = true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildContent() {
    return Column(
      children: [
        // Storage info
        _buildStorageInfo(),
        
        // Downloads list
        Expanded(
          child: _buildDownloadsList(),
        ),
      ],
    );
  }
  
  Widget _buildStorageInfo() {
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
                  '2.4 GB of 10 GB',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppThemes.spaceSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.24,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppThemes.accentPink,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDownloadsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildDownloadItem(index);
      },
    );
  }
  
  Widget _buildDownloadItem(int index) {
    final isSelected = _selectedItems.contains(index);
    final downloadProgress = index < 2 ? (0.3 + index * 0.4) : 1.0;
    final isDownloading = downloadProgress < 1.0;
    
    return GestureDetector(
      onTap: () {
        if (_isSelecting) {
          setState(() {
            if (isSelected) {
              _selectedItems.remove(index);
            } else {
              _selectedItems.add(index);
            }
          });
        } else if (!isDownloading) {
          context.push('/watch/downloaded-$index');
        }
      },
      onLongPress: () {
        if (!_isSelecting) {
          setState(() {
            _isSelecting = true;
            _selectedItems.add(index);
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
            // Selection checkbox or thumbnail
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
                  ),
                  child: const Center(
                    child: Icon(Icons.movie, size: 28, color: Colors.white24),
                  ),
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
                            value: downloadProgress,
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
                    'Anime Title ${index + 1}',
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
                    'Episode ${(index % 12) + 1}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceSm),
                  Row(
                    children: [
                      Icon(
                        isDownloading ? Icons.downloading : Icons.check_circle,
                        size: 14,
                        color: isDownloading 
                            ? AppThemes.accentPink 
                            : AppThemes.ratingGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDownloading
                            ? '${(downloadProgress * 100).toInt()}%'
                            : '${(200 + index * 50)} MB',
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
                        child: const Text(
                          '720p',
                          style: TextStyle(
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
            if (!_isSelecting && isDownloading)
              IconButton(
                icon: Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: () {},
              )
            else if (!_isSelecting)
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.5),
                ),
                color: AppThemes.darkSurface,
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteItem(index);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        const Text('Play', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 8),
                        const Text('Details', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  void _showOptionsMenu() {
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
                leading: const Icon(Icons.sort, color: Colors.white),
                title: const Text(
                  'Sort Downloads',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.pause_circle_outline, color: Colors.white),
                title: const Text(
                  'Pause All',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete All',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAllDialog();
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
  
  void _showDeleteAllDialog() {
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
  
  void _deleteItem(int index) {
    // Delete single item
  }
}
