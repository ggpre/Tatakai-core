import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';
import 'package:tatakai_mobile/models/anime.dart';
import 'package:tatakai_mobile/models/episode_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EpisodesScreen extends ConsumerStatefulWidget {
  final String animeId;
  
  const EpisodesScreen({
    super.key,
    required this.animeId,
  });
  
  @override
  ConsumerState<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends ConsumerState<EpisodesScreen> {
  // Sorting preference: true = ascending (1..N), false = descending (N..1)
  bool _ascending = true;
  
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
    final episodesState = ref.watch(episodesProvider(widget.animeId));
    final anime = ref.watch(animeDetailDataProvider)?.anime.info;
    
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: _buildAppBar(anime),
      body: episodesState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : episodesState.error != null
              ? Center(child: Text('Error: ${episodesState.error}', style: const TextStyle(color: Colors.white)))
              : _buildEpisodeList(episodesState.data?.episodes ?? [], anime?.poster),
    );
  }
  
  PreferredSizeWidget _buildAppBar(AnimeInfoData? anime) {
    return AppBar(
      backgroundColor: AppThemes.darkSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Anime thumbnail
          if (anime != null)
            Container(
              width: 40,
              height: 56,
              decoration: BoxDecoration(
                color: AppThemes.darkBackground,
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(anime.poster),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(width: AppThemes.spaceMd),
          // Title and metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anime?.name ?? 'Anime Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${anime?.stats.episodes.sub ?? '?'} Episodes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_ascending ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
          tooltip: 'Sort order',
          onPressed: () {
            setState(() {
              _ascending = !_ascending;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildEpisodeList(List<EpisodeData> episodes, String? posterUrl) {
    // Sort logic
    final sortedEpisodes = List<EpisodeData>.from(episodes);
    if (!_ascending) {
      sortedEpisodes.sort((a, b) => b.number.compareTo(a.number));
    } else {
      sortedEpisodes.sort((a, b) => a.number.compareTo(b.number));
    }

    if (sortedEpisodes.isEmpty) {
       return const Center(child: Text('No episodes found', style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: sortedEpisodes.length,
      itemBuilder: (context, index) {
        return _buildEpisodeCard(sortedEpisodes[index], posterUrl);
      },
    );
  }
  
  Widget _buildEpisodeCard(EpisodeData episode, String? posterUrl) {
    return GestureDetector(
      onTap: () {
        context.push('/watch/${episode.episodeId}?animeId=${widget.animeId}&episodeNumber=${episode.number}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
        padding: const EdgeInsets.all(AppThemes.spaceMd),
        decoration: BoxDecoration(
          color: AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 140,
              height: 80,
              decoration: BoxDecoration(
                color: AppThemes.darkBackground,
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                image: posterUrl != null ? DecorationImage(
                   image: CachedNetworkImageProvider(posterUrl),
                   fit: BoxFit.cover,
                   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                ) : null,
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.play_circle_fill, size: 36, color: Colors.white70),
                  ),
                  if (episode.isFiller)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                         decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                         child: const Text('FILLER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppThemes.spaceMd),
            
            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Episode number and title
                  Text(
                    'Episode ${episode.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    episode.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

