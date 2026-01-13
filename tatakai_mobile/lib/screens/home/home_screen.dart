import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';
import 'package:tatakai_mobile/models/anime.dart';
import 'package:tatakai_mobile/models/user.dart';
import 'package:tatakai_mobile/providers/watch_history_provider.dart';
import 'dart:async';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// Wrapped in valid execution block


class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _featuredController = PageController(viewportFraction: 0.85);
  final ScrollController _scrollController = ScrollController();
  Timer? _spotlightTimer;
  int _currentFeaturedIndex = 0;
  
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
    _scrollController.addListener(_onScroll);
    
    // Start auto-scroll timer for spotlight
    _spotlightTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_featuredController.hasClients) {
        final home = ref.read(homeDataProvider).data; // Access data from AsyncValue
        if (home != null && home.spotlightAnimes.isNotEmpty) {
           final nextPage = (_currentFeaturedIndex + 1) % home.spotlightAnimes.length;
           _featuredController.animateToPage(
             nextPage,
             duration: const Duration(milliseconds: 800),
             curve: Curves.fastOutSlowIn,
           );
        }
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _featuredController.dispose();
    _spotlightTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // This method can be used for other scroll-related logic if needed
    // For now, it's just a placeholder as per the snippet's inclusion of _scrollController
  }
  
  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeDataProvider);
    final HomeData? home = homeState.data;
    final continueWatching = ref.watch(continueWatchingProvider);

    // Debug: log current home state to verify data flow
    print('[HomeScreen] isLoading=${homeState.isLoading} error=${homeState.error} homePresent=${home != null} spotlight=${home?.spotlightAnimes.length ?? 0}');

    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppThemes.accentPink,
          onRefresh: () async {
            // Refresh home data
            await ref.read(homeDataProvider.notifier).fetchHomeData();
          },
          child: CustomScrollView(
            slivers: [
              // Error banner
              if (homeState.error != null)
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.all(AppThemes.spaceMd),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: AppThemes.spaceMd),
                        Expanded(
                          child: Text(
                            homeState.error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref.read(homeDataProvider.notifier).fetchHomeData(),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ),
              // Custom App Bar
              SliverToBoxAdapter(
                child: _buildAppBar(),
              ),
              
              // Watch Today Section (spotlight)
              SliverToBoxAdapter(
                child: (homeState.isLoading && home == null)
                    ? _buildLoadingWatchToday()
                    : _buildWatchTodaySection(home?.spotlightAnimes ?? []),
              ),
               
              // Top Rated Section (top10 today)
              SliverToBoxAdapter(
                child: (homeState.isLoading && home == null)
                    ? _buildLoadingSection()
                    : _buildSection(
                        'Top Rated',
                        Icons.trending_up,
                        home?.top10Animes.today ?? [],
                      ),
              ),
               
              // Continue Watching Section
              SliverToBoxAdapter(
                child: (homeState.isLoading && home == null)
                    ? _buildLoadingSection()
                    : _buildSection(
                        'Continue Watching',
                        Icons.play_circle_outline,
                        continueWatching,
                      ),
              ),
               
              // Trending Now Section
              SliverToBoxAdapter(
                child: (homeState.isLoading && home == null)
                    ? _buildLoadingSection()
                    : _buildSection(
                        'Trending Now',
                        Icons.trending_up,
                        home?.trendingAnimes ?? [],
                      ),
              ),
               
              // Latest Episodes Section
              SliverToBoxAdapter(
                child: (homeState.isLoading && home == null)
                    ? _buildLoadingSection()
                    : _buildSection(
                        'Latest Episodes',
                        Icons.fiber_new,
                        home?.latestEpisodeAnimes ?? [],
                      ),
              ),
              // Bottom spacing for navigation bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppThemes.spaceLg,
        vertical: AppThemes.spaceMd,
      ),
      child: Row(
        children: [
          // Search icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppThemes.darkSurface,
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 22),
              onPressed: () {
                context.go('/search');
              },
            ),
          ),
          
          const Spacer(),
          
          // Tatakai Logo (center)
          Image.asset(
            'assets/images/tatakai-logo.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to text if image fails
              return Text(
                'Tatakai',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          
          const Spacer(),
          
          // Profile avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppThemes.accentPink, AppThemes.accentPinkLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWatchTodaySection(List<SpotlightAnime> spotlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppThemes.spaceLg,
            vertical: AppThemes.spaceMd,
          ),
          child: Text(
            'Watch today',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _featuredController,
            onPageChanged: (index) {
              setState(() {
                _currentFeaturedIndex = index;
              });
            },
            itemCount: spotlight.isNotEmpty ? spotlight.length : 5,
            itemBuilder: (context, index) {
              final item = spotlight.isNotEmpty ? spotlight[index] : null;
              return _buildFeaturedCard(item, index);
            },
          ),
        ),
        
        // Page indicators
        Padding(
          padding: const EdgeInsets.only(top: AppThemes.spaceMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(spotlight.isNotEmpty ? spotlight.length : 5, (index) {
              return Container(
                width: _currentFeaturedIndex == index ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _currentFeaturedIndex == index
                      ? AppThemes.accentPink
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeaturedCard(SpotlightAnime? item, int index) {
    final apiService = ref.watch(apiServiceProvider);
    
    return GestureDetector(
      onTap: () {
        final id = item?.id ?? 'featured-$index';
        context.push('/anime/$id');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppThemes.spaceSm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppThemes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppThemes.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster image
              Container(
                color: AppThemes.darkSurface,
                child: item != null && item.poster.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: apiService.getProxiedImageUrl(item.poster),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 64, color: Colors.white24),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.movie, size: 64, color: Colors.white24),
                      ),
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: AppThemes.spaceLg,
                left: AppThemes.spaceLg,
                right: AppThemes.spaceLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Up on your watchlist" label
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemes.spaceMd,
                        vertical: AppThemes.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.accentPink.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                      ),
                      child: const Text(
                        'Up on your watchlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppThemes.spaceMd),
                    
                    // Title
                    Text(
                      item?.name ?? 'Featured Anime ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppThemes.spaceSm),
                    
                    // Description
                    Text(
                      item?.description ?? 'No description available.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppThemes.spaceMd),

                    // Action Buttons (Watch Now)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            final id = item?.id ?? 'featured-$index';
                            // Navigate to Anime Detail first, or Watch if smart
                            context.push('/anime/$id');
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Watch Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                         // Add to list button could go here
                      ],
                    ),
                    
                    // Year + Rating (best-effort)
                    Row(
                      children: [
                        Text(
                          item != null && item.otherInfo.isNotEmpty ? item.otherInfo.first : '—',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: AppThemes.spaceMd),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppThemes.ratingGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '—',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingWatchToday() {
    return SizedBox(
      height: 420,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemes.spaceLg,
            AppThemes.spaceXl,
            AppThemes.spaceLg,
            AppThemes.spaceMd,
          ),
          child: Row(
            children: [
              Icon(Icons.fiber_new, size: 20, color: AppThemes.accentPink),
              const SizedBox(width: AppThemes.spaceSm),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _buildTopRatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemes.spaceLg,
            AppThemes.spaceXl,
            AppThemes.spaceLg,
            AppThemes.spaceMd,
          ),
          child: Row(
            children: [
              Text(
                'Top Rated',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppThemes.accentPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildTopRatedCard(index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTopRatedCard(int index) {
    return GestureDetector(
      onTap: () {
        context.push('/anime/top-rated-$index');
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppThemes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: AppThemes.darkSurface,
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder
                    Container(
                      color: AppThemes.darkSurface,
                      child: const Center(
                        child: Icon(Icons.movie, size: 32, color: Colors.white24),
                      ),
                    ),
                    
                    // Rating badge
                    Positioned(
                      top: AppThemes.spaceSm,
                      right: AppThemes.spaceSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppThemes.spaceSm,
                          vertical: AppThemes.spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppThemes.ratingGreen,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${8.0 + (index * 0.1).clamp(0, 0.9)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppThemes.spaceSm),
            
            // Title
            Text(
              'Anime Title ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, IconData icon, List items) {
    final count = items.isNotEmpty ? items.length : 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppThemes.spaceLg,
            AppThemes.spaceXl,
            AppThemes.spaceLg,
            AppThemes.spaceMd,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppThemes.accentPink),
              const SizedBox(width: AppThemes.spaceSm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppThemes.accentPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
            itemCount: count,
            itemBuilder: (context, index) {
              final item = items.isNotEmpty ? items[index] : null;
              return _buildAnimeCard(item: item, index: index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnimeCard({dynamic item, int? index}) {
    final apiService = ref.watch(apiServiceProvider);
    
    final String id;
    final String title;
    final String poster;

    if (item == null) {
      id = 'anime-${index ?? 0}';
      title = 'Anime Title ${index != null ? index + 1 : ''}';
      poster = '';
    } else if (item is AnimeCard) {
      id = item.id;
      title = item.name;
      poster = item.poster;
    } else if (item is SpotlightAnime) {
      id = item.id;
      title = item.name;
      poster = item.poster;
    } else if (item is TrendingAnime) {
      id = item.id;
      title = item.name;
      poster = item.poster;
    } else if (item is TopAnime) {
      id = item.id;
      title = item.name;
      poster = item.poster;
    } else if (item is WatchHistory) {
      id = item.animeId;
      title = item.animeName;
      poster = item.animePoster ?? '';
    } else {
      id = item['id']?.toString() ?? 'anime-${index ?? 0}';
      title = item['name']?.toString() ?? 'Anime ${index ?? 0}';
      poster = item['poster']?.toString() ?? '';
    }

    return GestureDetector(
      onTap: () {
        context.push('/anime/$id');
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: AppThemes.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
              child: Container(
                height: 170,
                width: 130,
                color: AppThemes.darkSurface,
                child: poster.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: apiService.getProxiedImageUrl(poster),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, size: 32, color: Colors.white24),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.movie, size: 32, color: Colors.white24),
                      ),
              ),
            ),
            const SizedBox(height: AppThemes.spaceSm),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
