import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tatakai_mobile/config/theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _featuredController = PageController(viewportFraction: 0.85);
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
  }
  
  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppThemes.accentPink,
          onRefresh: () async {
            // Refresh home data
          },
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverToBoxAdapter(
                child: _buildAppBar(),
              ),
              
              // Watch Today Section
              SliverToBoxAdapter(
                child: _buildWatchTodaySection(),
              ),
              
              // Top Rated Section
              SliverToBoxAdapter(
                child: _buildTopRatedSection(),
              ),
              
              // Continue Watching Section
              SliverToBoxAdapter(
                child: _buildSection(
                  'Continue Watching',
                  Icons.play_circle_outline,
                  [],
                ),
              ),
              
              // Trending Now Section
              SliverToBoxAdapter(
                child: _buildSection(
                  'Trending Now',
                  Icons.trending_up,
                  [],
                ),
              ),
              
              // Latest Episodes Section
              SliverToBoxAdapter(
                child: _buildSection(
                  'Latest Episodes',
                  Icons.fiber_new,
                  [],
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
          
          // WakuWaku Logo (center)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red bars icon
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppThemes.accentPink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Container(
                        width: 4,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppThemes.accentPink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppThemes.accentPink,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                'Tatakai',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
  
  Widget _buildWatchTodaySection() {
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
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildFeaturedCard(index);
            },
          ),
        ),
        
        // Page indicators
        Padding(
          padding: const EdgeInsets.only(top: AppThemes.spaceMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
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
  
  Widget _buildFeaturedCard(int index) {
    return GestureDetector(
      onTap: () {
        context.push('/anime/featured-$index');
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
              // Background image placeholder
              Container(
                color: AppThemes.darkSurface,
                child: const Center(
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
                      'Featured Anime ${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppThemes.spaceSm),
                    
                    // Year + Rating
                    Row(
                      children: [
                        Text(
                          '2024',
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
                              '8.5',
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
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildAnimeCard(index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnimeCard(int index) {
    return GestureDetector(
      onTap: () {
        context.push('/anime/anime-$index');
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
                child: const Center(
                  child: Icon(Icons.movie, size: 32, color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: AppThemes.spaceSm),
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
}
