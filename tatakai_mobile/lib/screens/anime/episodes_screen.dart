import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

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
  int _selectedSeason = 1;
  final List<int> _seasons = [1, 2, 3]; // Example seasons
  
  @override
  void initState() {
    super.initState();
    // Set status bar style for dark theme
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
      body: Column(
        children: [
          // Season selector
          _buildSeasonSelector(),
          
          // Episode list
          Expanded(
            child: _buildEpisodeList(),
          ),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
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
          Container(
            width: 40,
            height: 56,
            decoration: BoxDecoration(
              color: AppThemes.darkBackground,
              borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
            ),
            child: const Center(
              child: Icon(Icons.movie, size: 20, color: Colors.white24),
            ),
          ),
          const SizedBox(width: AppThemes.spaceMd),
          // Title and metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anime Title',
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
                  'TV • 24 Episodes',
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
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            _showOptionsMenu();
          },
        ),
      ],
    );
  }
  
  Widget _buildSeasonSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemes.spaceLg,
        vertical: AppThemes.spaceMd,
      ),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _seasons.map((season) {
            final isSelected = _selectedSeason == season;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSeason = season;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: AppThemes.spaceSm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemes.spaceLg,
                  vertical: AppThemes.spaceMd,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppThemes.accentPink : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppThemes.radiusLarge),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                ),
                child: Text(
                  'Season $season',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildEpisodeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: 24,
      itemBuilder: (context, index) {
        return _buildEpisodeCard(index + 1);
      },
    );
  }
  
  Widget _buildEpisodeCard(int episodeNumber) {
    return GestureDetector(
      onTap: () {
        context.push('/watch/ep-$episodeNumber?animeId=${widget.animeId}&episodeNumber=$episodeNumber');
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
              ),
              child: Stack(
                children: [
                  // Placeholder
                  const Center(
                    child: Icon(Icons.play_circle_fill, size: 36, color: Colors.white24),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '24:00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                    'Episode $episodeNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Episode Title Goes Here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppThemes.spaceSm),
                  
                  // Air date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Jan ${episodeNumber}, 2024',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceXs),
                  
                  // Description preview
                  Text(
                    'Brief episode description that gives a preview of what happens...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white.withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () {
                    // Add to playlist
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: AppThemes.spaceSm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${5 + episodeNumber}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
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
                  'Sort Episodes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_list, color: Colors.white),
                title: const Text(
                  'Filter by Type',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: const Text(
                  'Download All',
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
}
