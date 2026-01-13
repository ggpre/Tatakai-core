import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';
import 'package:tatakai_mobile/screens/anime/comment_section.dart';
import 'package:tatakai_mobile/models/anime.dart';
import 'package:tatakai_mobile/providers/favorites_provider.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';


class AnimeDetailScreen extends ConsumerStatefulWidget {
  final String animeId;
  
  const AnimeDetailScreen({
    super.key,
    required this.animeId,
  });
  
  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _selectedTabIndex = 0;
  
  final List<String> _tabs = ['General', 'Cast', 'Comments', 'Lists'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _scrollController.addListener(_onScroll);

    // Fetch anime details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(animeDetailProvider.notifier).fetchAnimeDetail(widget.animeId);
    });
    
    // Set status bar style for light theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  void _onScroll() {
    if (_scrollController.offset > 200 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 200 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final animeState = ref.watch(animeDetailProvider);
    final animeData = animeState.data;

    return Theme(
      data: AppThemes.themes['wakuwaku_light']!,
      child: Scaffold(
        backgroundColor: AppThemes.lightBackground,
        body: animeState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                controller: _scrollController,
                slivers: [
            // Transparent app bar with back button
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.45,
              pinned: true,
              backgroundColor: _isScrolled ? AppThemes.lightBackground : Colors.transparent,
              elevation: _isScrolled ? 1 : 0,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isScrolled ? Colors.transparent : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: _isScrolled ? AppThemes.darkBackground : AppThemes.darkBackground,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isScrolled ? Colors.transparent : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final favoritesState = ref.watch(favoritesProvider);
                        final isFavorite = favoritesState.items.any((item) => item.animeId == widget.animeId);
                        
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : AppThemes.darkBackground,
                          ),
                          onPressed: () {
                            if (animeData != null) {
                               ref.read(favoritesProvider.notifier).toggleFavorite(
                                 animeData.anime.info.id,
                                 animeData.anime.info.name,
                                 animeData.anime.info.poster,
                               );
                            }
                          },
                        );
                      }
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isScrolled ? Colors.transparent : Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: AppThemes.darkBackground,
                      ),
                      onPressed: () {
                         // Simple share via share_plus if available, or Clipboard
                         // Using Clipboard for now due to unknown deps
                         if (animeData != null) {
                            Clipboard.setData(ClipboardData(text: 'Check out ${animeData.anime.info.name} on Tatakai! Download it now!  https://tatakai.gabhasti.tech/download'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied to clipboard')),
                            );
                         }
                      },
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroImage(animeData),
              ),
            ),
            
            // Content
            SliverToBoxAdapter(
              child: _buildContent(animeData),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeroImage(AnimeInfoResponse? animeData) {
    final apiService = ref.watch(apiServiceProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppThemes.radiusXXLarge),
          bottomRight: Radius.circular(AppThemes.radiusXXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppThemes.radiusXXLarge),
          bottomRight: Radius.circular(AppThemes.radiusXXLarge),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster image
            Container(
              color: AppThemes.darkSurface,
              child: animeData != null && animeData.anime.info.poster.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: apiService.getProxiedImageUrl(animeData.anime.info.poster),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, size: 80, color: Colors.white24),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.movie, size: 80, color: Colors.white24),
                    ),
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContent(AnimeInfoResponse? animeData) {
    return Container(
      color: AppThemes.lightBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Padding(
            padding: const EdgeInsets.all(AppThemes.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  animeData?.anime.info.name ?? 'Loading...',
                  style: TextStyle(
                    color: AppThemes.darkBackground,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: AppThemes.spaceSm),
                
                // Year + Original title
                Row(
                  children: [
                    Text(
                      animeData != null ? (animeData.anime.moreInfo.aired.length >= 4 ? animeData.anime.moreInfo.aired.substring(animeData.anime.moreInfo.aired.length - 4) : animeData.anime.moreInfo.aired) : '—',
                      style: TextStyle(
                        color: AppThemes.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppThemes.spaceSm),
                    Text(
                      '•',
                      style: TextStyle(
                        color: AppThemes.textSecondaryLight,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: AppThemes.spaceSm),
                    Expanded(
                      child: Text(
                        animeData?.anime.info.name ?? '',
                        style: TextStyle(
                          color: AppThemes.textSecondaryLight,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppThemes.spaceMd),
                
                // Rating
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemes.spaceMd,
                        vertical: AppThemes.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.ratingGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppThemes.ratingGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            animeData?.anime.info.stats.rating ?? '—',
                            style: TextStyle(
                              color: AppThemes.ratingGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab bar
          _buildTabBar(),
          
          const SizedBox(height: AppThemes.spaceLg),
          
          // Stats row
          _buildStatsRow(),
          
          const SizedBox(height: AppThemes.spaceXl),
          
          // Action buttons
          _buildActionButtons(),
          
          const SizedBox(height: AppThemes.spaceXl),
          
          // Tab content
          _buildTabContent(animeData),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
              _tabController.animateTo(index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppThemes.spaceSm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppThemes.spaceLg,
                vertical: AppThemes.spaceMd,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppThemes.accentPink : Colors.transparent,
                borderRadius: BorderRadius.circular(AppThemes.radiusXXLarge),
                border: isSelected
                    ? null
                    : Border.all(
                        color: AppThemes.textSecondaryLight.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppThemes.textSecondaryLight,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatsRow() {
    final supabase = ref.watch(supabaseServiceProvider);
    final animeData = ref.watch(animeDetailDataProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      child: FutureBuilder<Map<String, int>>(
        future: supabase.getAnimeStats(widget.animeId),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {};
          final episodeCount = animeData?.anime.info.stats.episodes.sub ?? 0; // Use fetched anime info for eps
          
          final displayStats = [
            {'icon': Icons.bookmark_border, 'value': '${stats['saved'] ?? '—'}', 'label': 'Saved'},
            {'icon': Icons.favorite_border, 'value': 'N/A', 'label': 'Likes'}, // Not available yet
            {'icon': Icons.visibility_outlined, 'value': 'N/A', 'label': 'Views'}, // Not available yet
            {'icon': Icons.chat_bubble_outline, 'value': '${stats['comments'] ?? '—'}', 'label': 'Comments'},
            {'icon': Icons.list_alt, 'value': '${stats['lists'] ?? '—'}', 'label': 'Lists'},
            {'icon': Icons.movie_outlined, 'value': '$episodeCount', 'label': 'Episodes'},
          ];
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: displayStats.map((stat) {
              return Column(
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    color: AppThemes.textSecondaryLight,
                    size: 24,
                  ),
                  const SizedBox(height: AppThemes.spaceXs),
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      color: AppThemes.darkBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        }
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      child: Row(
        children: [
          // Watching button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                 // Check for watch history to resume
                 final supabase = ref.read(supabaseServiceProvider);
                 final user = supabase.currentUser;
                 if (user != null) {
                   final history = await supabase.getLastWatchedEpisode(user.id, widget.animeId);
                   if (history != null && context.mounted) {
                     context.push(
                       Uri(
                         path: '/watch/${history.episodeId}',
                         queryParameters: {
                           'animeId': widget.animeId,
                           'episodeNumber': history.episodeNumber.toString(),
                         },
                       ).toString(),
                     );
                     return;
                   }
                 }
                 
                 // If no history, go to episodes screen
                 if (context.mounted) {
                    context.push('/anime/${widget.animeId}/episodes');
                 }
              },
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('Watch Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemes.accentPink,
                side: const BorderSide(color: AppThemes.accentPink, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemes.radiusPill),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppThemes.spaceMd),
          
          // Review button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.rate_review_outlined, size: 20),
              label: const Text('Review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppThemes.accentPink,
                side: const BorderSide(color: AppThemes.accentPink, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppThemes.radiusPill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabContent(AnimeInfoResponse? animeData) {
    return IndexedStack(
      index: _selectedTabIndex,
      children: [
        _buildGeneralTab(animeData),
        _buildCastTab(animeData),
        _buildCommentsTab(animeData),
        _buildListsTab(),
      ],
    );
  }
  
  Widget _buildGeneralTab(AnimeInfoResponse? animeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synopsis',
            style: TextStyle(
              color: AppThemes.darkBackground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          Text(
            animeData?.anime.info.description ?? 'No description available.',
            style: TextStyle(
              color: AppThemes.textSecondaryLight,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppThemes.spaceXl),
          
          // Info rows
          _buildInfoRow('Status', animeData?.anime.moreInfo.status ?? 'Unknown'),
          _buildInfoRow('Genres', animeData?.anime.moreInfo.genres.join(', ') ?? 'N/A'),
          _buildInfoRow('Studio', animeData?.anime.moreInfo.studios ?? 'Unknown'),
          _buildInfoRow('Episodes', animeData != null ? '${animeData.anime.info.stats.episodes.sub + (animeData.anime.info.stats.episodes.dub ?? 0)}' : '0'),
          _buildInfoRow('Duration', animeData?.anime.moreInfo.duration ?? '—'),
          
          const SizedBox(height: AppThemes.spaceXl),
          
          // Episodes preview
          Text(
            'Episodes',
            style: TextStyle(
              color: AppThemes.darkBackground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          
          // Episode list button
          InkWell(
            onTap: () {
              context.push('/anime/${widget.animeId}/episodes');
            },
            child: Container(
              padding: const EdgeInsets.all(AppThemes.spaceLg),
              decoration: BoxDecoration(
                color: AppThemes.lightSurface,
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppThemes.darkSurface,
                      borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppThemes.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View all episodes',
                          style: TextStyle(
                            color: AppThemes.darkBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '24 episodes available',
                          style: TextStyle(
                            color: AppThemes.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppThemes.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemes.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppThemes.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppThemes.darkBackground,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCastTab(AnimeInfoResponse? animeData) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
            padding: const EdgeInsets.all(AppThemes.spaceMd),
            decoration: BoxDecoration(
              color: AppThemes.lightSurface,
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppThemes.darkSurface,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: AppThemes.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Character Name ${index + 1}',
                        style: TextStyle(
                          color: AppThemes.darkBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Voice Actor Name',
                        style: TextStyle(
                          color: AppThemes.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCommentsTab(AnimeInfoResponse? animeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      child: Column(
        children: [
          // Comment input
          Container(
            padding: const EdgeInsets.all(AppThemes.spaceMd),
            decoration: BoxDecoration(
              color: AppThemes.lightSurface,
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppThemes.accentPink,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppThemes.spaceMd),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: AppThemes.textSecondaryLight),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppThemes.accentPink),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppThemes.spaceLg),
          
          // Comments
          CommentSection(animeId: widget.animeId),
        ],
      ),
    );
  }
  
  Widget _buildCommentCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.lightSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppThemes.darkSurface,
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: AppThemes.spaceSm),
              Text(
                'User ${index + 1}',
                style: TextStyle(
                  color: AppThemes.darkBackground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '2h ago',
                style: TextStyle(
                  color: AppThemes.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceSm),
          Text(
            'This is a sample comment from a user. They share their thoughts about the anime.',
            style: TextStyle(
              color: AppThemes.textSecondaryLight,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppThemes.spaceSm),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 16, color: AppThemes.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                '${5 + index}',
                style: TextStyle(
                  color: AppThemes.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: AppThemes.spaceLg),
              Icon(Icons.reply, size: 16, color: AppThemes.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                'Reply',
                style: TextStyle(
                  color: AppThemes.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildListsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to list',
            style: TextStyle(
              color: AppThemes.darkBackground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          Wrap(
            spacing: AppThemes.spaceSm,
            runSpacing: AppThemes.spaceSm,
            children: [
              _buildListChip('Watching', true),
              _buildListChip('Plan to Watch', false),
              _buildListChip('Completed', false),
              _buildListChip('On Hold', false),
              _buildListChip('Dropped', false),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildListChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemes.spaceLg,
          vertical: AppThemes.spaceMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppThemes.accentPink : AppThemes.lightSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusXXLarge),
          border: isSelected
              ? null
              : Border.all(color: AppThemes.textSecondaryLight.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppThemes.textSecondaryLight,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
