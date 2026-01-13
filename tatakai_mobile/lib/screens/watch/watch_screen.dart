import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/services/api_service.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';
import 'package:tatakai_mobile/providers/download_provider.dart';
import 'package:tatakai_mobile/models/download.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';
import 'package:tatakai_mobile/models/episode_model.dart' as ep;
import 'package:tatakai_mobile/models/anime.dart';
import 'package:uuid/uuid.dart';

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
  String _error = '';
  
  // State for streaming data
  List<ep.EpisodeServer> _servers = [];
  List<ep.StreamingSource> _sources = [];
  List<ep.Subtitle> _subtitles = [];
  
  ep.EpisodeServer? _currentServer;
  ep.StreamingSource? _currentSource;
  ep.Subtitle? _currentSubtitle;
  String _currentCategory = 'sub'; // sub or dub
  
  // Anime Info
  AnimeInfoResponse? _animeInfo;
  
  // Player settings
  String _selectedQuality = 'Auto';
  String _selectedSpeed = '1.0x';
  final List<String> _speeds = ['0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '2.0x'];
  
  List<String> get _qualities => _sources.map((s) => s.quality ?? 'default').toSet().toList();
  
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
  
  // Extra sources cache
  Map<String, ep.StreamingData> _extraSources = {};

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _extraSources.clear();
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // Fetch anime info if available
      if (widget.animeId != null) {
        _animeInfo = await apiService.fetchAnimeInfo(widget.animeId!);
      }
      
      // 1. Fetch available servers (HiAnime)
      final serverData = await apiService.fetchEpisodeServers(widget.episodeId);
      
      List<ep.EpisodeServer> availableServers = [];
      if (serverData.sub.isNotEmpty) {
        availableServers = serverData.sub;
        _currentCategory = 'sub';
      } else if (serverData.dub.isNotEmpty) {
        availableServers = serverData.dub;
        _currentCategory = 'dub';
      } else if (serverData.raw.isNotEmpty) {
        availableServers = serverData.raw;
        _currentCategory = 'raw';
      }
      
      // 2. Check for Extra Servers (WatchAnimeWorld, AnimeHindiDubbed) in parallel
      // Only if we have episode number and animeId/slug
      if (widget.episodeId.isNotEmpty && widget.episodeNumber != null) {
        try {
          // Extract slug from episodeId or animeId
          // episodeId format: "one-piece-100?ep=..."
          // We need generic slug: "one-piece"
          String slug = widget.episodeId.split('?')[0]; 
          // Remove last number (anime ID in HiAnime)
          slug = slug.replaceAll(RegExp(r'-\d+$'), '');
          
          if (slug.isNotEmpty) {
             // 2a. WatchAnimeWorld
             final wawSlug = '$slug-1x${widget.episodeNumber}';
             _checkWatchAnimeWorld(apiService, wawSlug).then((data) {
               if (data != null && data.sources.isNotEmpty) {
                 if (mounted) {
                   setState(() {
                     _extraSources['WatchAnimeWorld'] = data;
                     _servers.add(ep.EpisodeServer(serverId: 9999, serverName: 'WatchAnimeWorld'));
                   });
                 }
               }
             });

             // 2b. AnimeHindiDubbed
             _checkAnimeHindiDubbed(apiService, slug, widget.episodeNumber!).then((data) {
                if (data != null && data.sources.isNotEmpty) {
                  if (mounted) {
                    setState(() {
                      _extraSources['AnimeHindiDubbed'] = data;
                      _servers.add(ep.EpisodeServer(serverId: 8888, serverName: 'AnimeHindiDubbed'));
                    });
                  }
                }
             });
          }
        } catch (e) {
          print('Error checking extra servers: $e');
        }
      }
      
      if (mounted) {
        setState(() {
          _servers = availableServers;
        });
      }
      
      if (_servers.isEmpty && _extraSources.isEmpty) {
        // Wait a bit if async checks haven't finished? 
        // Or just show error if HiAnime failed and we rely on that initially.
        // For now, if HiAnime empty, we error. But extra servers might populate later.
        // Let's delay errorcheck or handle empty state visually.
        if (availableServers.isEmpty) throw Exception('No servers available');
      }
      
      // select default server
      if (availableServers.isNotEmpty) {
         _currentServer = availableServers.firstWhere(
          (s) => s.serverName.toLowerCase().contains('hd-1'),
          orElse: () => availableServers.first,
        );
        await _loadSource(_currentServer!.serverName);
      } else {
        // Wait for extra servers?
        // UI will update when setState called in then().
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<ep.StreamingData?> _checkWatchAnimeWorld(ApiService api, String slug) async {
    try {
      final json = await api.fetchWatchAnimeWorldSources(slug);
      return ep.StreamingData.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<ep.StreamingData?> _checkAnimeHindiDubbed(ApiService api, String slug, int episodeNo) async {
    try {
      final json = await api.fetchAnimeHindiDubbedData(slug);
      // Logic to find episode in json and construct StreamingData
      // Json structure: { title, ..., servers: { filemoon: [], ... } }
      // This is NOT StreamingData structure. Need to convert.
      
      List<ep.StreamingSource> sources = [];
      
      // Helper to match episode
      bool matches(String name) {
         if (name == episodeNo.toString()) return true;
         if (name == episodeNo.toString().padLeft(2, '0')) return true;
         if (name.contains('Episode $episodeNo')) return true;
         return false;
      }

      final servers = json['servers'] as Map<String, dynamic>;
      
      if (servers.containsKey('servabyss')) {
          final list = servers['servabyss'] as List;
          final ep = list.firstWhere((e) => matches(e['name'].toString()), orElse: () => null);
          if (ep != null) {
            sources.add(ep.StreamingSource(
              url: ep['url'],
              isM3U8: false,
              quality: '720p',
              providerName: 'Servabyss (Berlin)',
              isEmbed: true,
              needsHeadless: true,
            ));
          }
      }
      
      if (servers.containsKey('vidgroud')) {
          final list = servers['vidgroud'] as List;
          final ep = list.firstWhere((e) => matches(e['name'].toString()), orElse: () => null);
          if (ep != null) {
             sources.add(ep.StreamingSource(
              url: ep['url'],
              isM3U8: false,
              quality: '720p',
              providerName: 'Vidgroud (Madrid)',
              isEmbed: true,
              needsHeadless: true,
            ));
          }
      }

      if (sources.isNotEmpty) {
        return ep.StreamingData(
          headers: ep.StreamingHeaders(referer: '', userAgent: ''),
          sources: sources,
          subtitles: [],
          intro: null,
          outro: null, 
          anilistID: null, 
          malID: null,
        );
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  
  Future<void> _loadSource(String serverName) async {
    setState(() {
      _isLoading = true;
    });
    
    // Cleanup previous controllers
    _videoController?.dispose();
    _chewieController?.dispose();
    _videoController = null;
    _chewieController = null;
    
    try {
      final apiService = ref.read(apiServiceProvider);
      
      // 2. Fetch streaming sources for selected server
      print('Loading source for server: $serverName');
      
      ep.StreamingData streamingData;
      
      if (_extraSources.containsKey(serverName)) {
        streamingData = _extraSources[serverName]!;
      } else {
        streamingData = await apiService.fetchStreamingSources(
          widget.episodeId,
          server: serverName.toLowerCase().replaceAll(' ', '-'),
          category: _currentCategory,
        );
      }
      
      _sources = streamingData.sources;
      _subtitles = streamingData.subtitles;
      
      // Handle tracks if subtitles is empty but tracks is populated
      if (_subtitles.isEmpty && streamingData.tracks != null) {
        _subtitles = streamingData.tracks!;
      }
      
      if (_sources.isEmpty) {
        throw Exception('No streaming sources found');
      }
      
      // Auto-select best quality
      _currentSource = _sources.firstWhere(
        (s) => s.quality == 'auto' || s.quality == 'default',
        orElse: () => _sources.first,
      );
      
      _selectedQuality = _currentSource?.quality ?? 'Auto';
      
      // 3. Initialize Video Player
      final videoUrl = apiService.getProxiedVideoUrl(
        _currentSource!.url,
        referer: streamingData.headers.referer,
      );
      
      // Build headers map
      final headers = <String, String>{
        'Referer': streamingData.headers.referer,
        'User-Agent': streamingData.headers.userAgent,
      };
      
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: headers,
      ); 
      
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: AppThemes.accentPink,
          handleColor: AppThemes.accentPink,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
      print('Video load error: $e');
    }
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  Future<void> _startDownload(ep.StreamingSource source) async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to download')),
      );
      return;
    }

    // Attempt to get anime name and poster
    String animeName = _animeInfo?.anime.info.name ?? 'Unknown Anime';
    String? animePoster = _animeInfo?.anime.info.poster;
    
    // Create new Download object
    final download = Download(
      id: const Uuid().v4(),
      userId: user.id,
      animeId: widget.animeId ?? 'unknown',
      animeName: animeName,
      animePoster: animePoster,
      episodeNumber: widget.episodeNumber ?? 1,
      episodeId: widget.episodeId,
      episodeTitle: 'Episode ${widget.episodeNumber}',
      quality: source.quality ?? 'default',
      videoUrl: source.url,
      localPath: '',
      totalBytes: 0,
      downloadedBytes: 0,
      status: DownloadStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Start download via provider
    ref.read(downloadsProvider.notifier).startDownload(download);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started downloading ${source.quality}...'),
        backgroundColor: AppThemes.darkSurface,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // If error, show error screen
    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error loading video',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializePlayer,
                style: ElevatedButton.styleFrom(backgroundColor: AppThemes.accentPink),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppThemes.accentPink))
                : _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : _buildNoVideoPlaceholder(),
            if (_showControls && !_isLoading && _chewieController != null)
               _buildTopBar(),
          ],
        ),
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
          top: MediaQuery.of(context).padding.top + AppThemes.spaceSm - 20,
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
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: AppThemes.spaceSm),
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
                    _animeInfo?.anime.info.name ?? 'Loading Title...',
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
            IconButton(
              icon: const Icon(Icons.download_outlined, color: Colors.white),
              onPressed: () => _showDownloadOptions(),
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
  
  Widget _buildNoVideoPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppThemes.accentPink),
            const SizedBox(height: 16),
            const Text('Initializing player...', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 24),
             ElevatedButton.icon(
              onPressed: () {
                _showServerSelector();
              },
              icon: const Icon(Icons.dns_outlined, size: 18),
              label: const Text('Change Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.accentPink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
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
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final server = _servers[index];
                    final isSelected = _currentServer?.serverId == server.serverId;
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
                      ),
                      title: Text(
                        server.serverName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _currentServer = server;
                        });
                        _loadSource(server.serverName);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
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
              if (_sources.isEmpty)
                 const Padding(
                   padding: EdgeInsets.all(16.0),
                   child: Text('No download sources available', style: TextStyle(color: Colors.white54)),
                 ),
              ..._sources.where((s) => s.quality != 'auto' && s.quality != 'default').map((source) {
                return ListTile(
                  leading: const Icon(Icons.download, color: Colors.white),
                  title: Text(
                    source.quality ?? 'Unknown',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    source.isM3U8 ? 'HLS' : 'MP4',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _startDownload(source);
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
                  _currentServer?.serverName ?? 'Select',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showServerSelector();
                },
              ),
              ListTile(
                leading: const Icon(Icons.high_quality, color: Colors.white),
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
                  'Speed',
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
                    // Apply speed to video controller
                    double speedValue = double.tryParse(speed.replaceAll('x', '')) ?? 1.0;
                    _videoController?.setPlaybackSpeed(speedValue);
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
