import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class WatchScreen extends ConsumerStatefulWidget {
  final String episodeId;
  final String? animeId;
  final int? episodeNumber;
  
  const WatchScreen({
    super.key,
    required this.episodeId,
    this.animeId,
    this.episodeNumber,
  });
  
  @override
  ConsumerState<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends ConsumerState<WatchScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _showControls = true;
  String _selectedQuality = 'Auto';
  String _selectedSpeed = '1.0x';
  String _selectedServer = 'HD-1';
  
  final List<String> _qualities = ['Auto', '1080p', '720p', '480p', '360p'];
  final List<String> _speeds = ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '2.0x'];
  final List<String> _servers = ['HD-1', 'HD-2', 'HD-3', 'SD-1'];
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  
  Future<void> _initializePlayer() async {
    // TODO: Fetch streaming sources from API
    // For now, using a placeholder
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
    });
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video player area
            Center(
              child: _isLoading
                  ? const _LoadingIndicator()
                  : _chewieController != null
                      ? Chewie(controller: _chewieController!)
                      : _buildNoVideoPlaceholder(),
            ),
            
            // Custom controls overlay
            if (_showControls) ...[
              // Top bar
              _buildTopBar(),
              
              // Center controls
              _buildCenterControls(),
              
              // Bottom bar
              _buildBottomBar(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoVideoPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppThemes.darkSurface,
              borderRadius: BorderRadius.circular(AppThemes.radiusXLarge),
            ),
            child: const Icon(
              Icons.play_disabled,
              size: 40,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: AppThemes.spaceLg),
          const Text(
            'No video source available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppThemes.spaceSm),
          Text(
            'Try selecting a different server',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppThemes.spaceXl),
          ElevatedButton.icon(
            onPressed: () {
              _showServerSelector();
            },
            icon: const Icon(Icons.dns_outlined, size: 18),
            label: const Text('Change Server'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.accentPink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemes.spaceXl,
                vertical: AppThemes.spaceMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusPill),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + AppThemes.spaceSm,
          left: AppThemes.spaceMd,
          right: AppThemes.spaceMd,
          bottom: AppThemes.spaceMd,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: AppThemes.spaceSm),
            
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Episode ${widget.episodeNumber ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Anime Title',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Actions
            IconButton(
              icon: const Icon(Icons.download_outlined, color: Colors.white),
              onPressed: () => _showDownloadOptions(),
            ),
            IconButton(
              icon: const Icon(Icons.subtitles_outlined, color: Colors.white),
              onPressed: () => _showSubtitleOptions(),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => _showSettingsSheet(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCenterControls() {
    return Positioned.fill(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous episode
            IconButton(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.skip_previous,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onPressed: () {
                // Go to previous episode
              },
            ),
            const SizedBox(width: AppThemes.spaceXl),
            
            // Rewind 10s
            IconButton(
              icon: const Icon(
                Icons.replay_10,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {
                // Rewind 10 seconds
              },
            ),
            const SizedBox(width: AppThemes.spaceLg),
            
            // Play/Pause
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppThemes.accentPink, AppThemes.accentPinkLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: AppThemes.accentPink.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  // Play/Pause
                },
              ),
            ),
            const SizedBox(width: AppThemes.spaceLg),
            
            // Forward 10s
            IconButton(
              icon: const Icon(
                Icons.forward_10,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {
                // Forward 10 seconds
              },
            ),
            const SizedBox(width: AppThemes.spaceXl),
            
            // Next episode
            IconButton(
              icon: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.skip_next,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onPressed: () {
                // Go to next episode
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + AppThemes.spaceMd,
          left: AppThemes.spaceLg,
          right: AppThemes.spaceLg,
          top: AppThemes.spaceLg,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Row(
              children: [
                Text(
                  '00:00',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: AppThemes.spaceSm),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                      activeTrackColor: AppThemes.accentPink,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: AppThemes.accentPink,
                      overlayColor: AppThemes.accentPink.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: 0.3,
                      onChanged: (value) {},
                    ),
                  ),
                ),
                const SizedBox(width: AppThemes.spaceSm),
                Text(
                  '24:00',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppThemes.spaceMd),
            
            // Bottom actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip intro button
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemes.spaceMd,
                      vertical: AppThemes.spaceXs,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    ),
                  ),
                  child: const Text('Skip Intro'),
                ),
                
                Row(
                  children: [
                    // Quality button
                    TextButton(
                      onPressed: () => _showQualitySelector(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.hd,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedQuality,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    // Speed button
                    TextButton(
                      onPressed: () => _showSpeedSelector(),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedSpeed,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    // Fullscreen
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // Toggle fullscreen
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDownloadOptions() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Download Episode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...['1080p', '720p', '480p', '360p'].map((quality) {
                return ListTile(
                  leading: const Icon(Icons.download, color: Colors.white),
                  title: Text(
                    quality,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    quality == '1080p' ? '~500 MB' : 
                    quality == '720p' ? '~300 MB' : 
                    quality == '480p' ? '~150 MB' : '~80 MB',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Downloading in $quality...'),
                        backgroundColor: AppThemes.darkSurface,
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
  
  void _showSubtitleOptions() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Subtitles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildSubtitleOption('Off', false),
              _buildSubtitleOption('English', true),
              _buildSubtitleOption('Spanish', false),
              _buildSubtitleOption('French', false),
              _buildSubtitleOption('German', false),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSubtitleOption(String language, bool isSelected) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
      ),
      title: Text(
        language,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
  
  void _showSettingsSheet() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dns_outlined, color: Colors.white),
                title: const Text(
                  'Server',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  _selectedServer,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showServerSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.hd, color: Colors.white),
                title: const Text(
                  'Quality',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  _selectedQuality,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showQualitySelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.speed, color: Colors.white),
                title: const Text(
                  'Playback Speed',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  _selectedSpeed,
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSpeedSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.white),
                title: const Text(
                  'Report Issue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
  
  void _showServerSelector() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Select Server',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._servers.map((server) {
                final isSelected = _selectedServer == server;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
                  ),
                  title: Text(
                    server,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedServer = server);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
  
  void _showQualitySelector() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._qualities.map((quality) {
                final isSelected = _selectedQuality == quality;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
                  ),
                  title: Text(
                    quality,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedQuality = quality);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
  
  void _showSpeedSelector() {
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
              const Padding(
                padding: EdgeInsets.all(AppThemes.spaceLg),
                child: Text(
                  'Playback Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._speeds.map((speed) {
                final isSelected = _selectedSpeed == speed;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
                  ),
                  title: Text(
                    speed,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedSpeed = speed);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: const AlwaysStoppedAnimation<Color>(AppThemes.accentPink),
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
        const SizedBox(height: AppThemes.spaceLg),
        const Text(
          'Loading video...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
