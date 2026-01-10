import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/widgets/common/anime_cards.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _featuredPageController = PageController();
  int _currentFeaturedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _featuredPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh home data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with Tabs
            _buildAppBar(),
            
            // Content based on selected tab
            SliverToBoxAdapter(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildForYouTab(),
                  _buildDiscoverTab(),
                  _buildBrowseTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            GradientText(
              'Tatakai',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Show notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            context.push('/settings');
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: const BorderSide(width: 3),
              borderRadius: BorderRadius.circular(2),
            ),
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'For You'),
              Tab(text: 'Discover'),
              Tab(text: 'Browse'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForYouTab() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Featured Carousel
            _buildFeaturedCarousel(),
            
            const SizedBox(height: 24),
            
            // Continue Watching
            _buildSection(
              'Continue Watching',
              Icons.play_circle_outline,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Trending Now
            _buildSection(
              'Trending Now',
              Icons.trending_up,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Latest Episodes
            _buildSection(
              'Latest Episodes',
              Icons.fiber_new,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Popular This Season
            _buildSection(
              'Popular This Season',
              Icons.local_fire_department,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Top Rated
            _buildSection(
              'Top Rated',
              Icons.star,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Genres
            _buildGenresSection(),
            
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseTab() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // All Anime
            _buildSection(
              'All Anime',
              Icons.grid_view,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 24),
            
            // Recently Added
            _buildSection(
              'Recently Added',
              Icons.new_releases,
              onSeeAll: () {},
            ),
            
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 450,
      child: Stack(
        children: [
          PageView.builder(
            controller: _featuredPageController,
            itemCount: 5,
            onPageChanged: (index) {
              setState(() {
                _currentFeaturedIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return FeaturedAnimeCard(
                title: 'Featured Anime ${index + 1}',
                description: 'This is an amazing anime series that you should watch right now.',
                onWatchPressed: () {
                  // Navigate to watch screen
                },
                onInfoPressed: () {
                  // Navigate to anime detail
                },
              );
            },
          ),
          
          // Page indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  width: _currentFeaturedIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: _currentFeaturedIndex == index
                        ? AppGradients.primaryGradient
                        : null,
                    color: _currentFeaturedIndex == index
                        ? null
                        : Colors.white.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(
    String title,
    IconData icon, {
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GradientIcon(icon: icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSeeAll,
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      AppGradients.primaryGradient.createShader(bounds),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return AnimeCard(
                title: 'Anime Title ${index + 1}',
                subtitle: 'Episode ${index + 1}',
                onTap: () {
                  // Navigate to anime detail
                },
                height: 230,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenresSection() {
    final genres = [
      'Action', 'Adventure', 'Comedy', 'Drama',
      'Fantasy', 'Horror', 'Mystery', 'Romance',
      'Sci-Fi', 'Slice of Life', 'Sports', 'Thriller',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const GradientIcon(icon: Icons.category, size: 24),
              const SizedBox(width: 8),
              Text(
                'Genres',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: genres.map((genre) {
              return GestureDetector(
                onTap: () {
                  context.push('/genre/$genre');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    genre,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
