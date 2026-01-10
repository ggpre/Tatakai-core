import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  
  @override
  void initState() {
    super.initState();
    _initializePlayer();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
  
  Future<void> _initializePlayer() async {
    // TODO: Fetch streaming sources from API
    // For now, using a placeholder
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // App bar overlay
            Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Episode ${widget.episodeNumber ?? ''}',
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Video player
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : _chewieController != null
                        ? Chewie(controller: _chewieController!)
                        : const Text(
                            'No video source available',
                            style: TextStyle(color: Colors.white),
                          ),
              ),
            ),
            
            // Controls and episode list
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Column(
                children: [
                  // Skip intro/outro buttons
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Skip Intro'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.fast_forward),
                          label: const Text('Skip Outro'),
                        ),
                      ],
                    ),
                  ),
                  
                  // Quality selector and settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Quality: Auto'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Speed: 1.0x'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.subtitles),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  
                  // Next episode button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Next Episode'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
