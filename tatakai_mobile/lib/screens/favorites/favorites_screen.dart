import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});
  
  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  
  final List<String> _tabs = ['All', 'Watching', 'Completed', 'Plan to Watch', 'On Hold'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildWatchlist(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Watchlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.sort, color: Colors.white),
                onPressed: () {
                  _showSortOptions();
                },
              ),
            ],
          ),
          const SizedBox(height: AppThemes.spaceMd),
          
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: AppThemes.darkSurface,
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search in watchlist...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppThemes.spaceLg,
                  vertical: AppThemes.spaceMd,
                ),
              ),
            ),
          ),
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
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
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
  
  Widget _buildWatchlist() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      itemCount: 15,
      itemBuilder: (context, index) {
        return _buildWatchlistItem(index);
      },
    );
  }
  
  Widget _buildWatchlistItem(int index) {
    final progress = (index * 0.1).clamp(0.0, 1.0);
    final currentEp = (index * 2 + 1).clamp(1, 24);
    final totalEps = 24;
    
    return GestureDetector(
      onTap: () {
        context.push('/anime/watchlist-$index');
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
            // Poster with progress indicator
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppThemes.darkBackground,
                    borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie, size: 32, color: Colors.white24),
                  ),
                ),
                // Progress bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppThemes.radiusSmall),
                        bottomRight: Radius.circular(AppThemes.radiusSmall),
                      ),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppThemes.accentPink, AppThemes.accentPinkLight],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(AppThemes.radiusSmall),
                          ),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppThemes.spaceXs),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppThemes.ratingGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${8.0 + (index * 0.1).clamp(0, 0.9)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: AppThemes.spaceMd),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppThemes.spaceSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemes.accentPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          index % 2 == 0 ? 'SUB' : 'DUB',
                          style: const TextStyle(
                            color: AppThemes.accentPink,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceSm),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Episode $currentEp / $totalEps',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppThemes.spaceSm),
                  
                  // Continue watching button
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/watch/ep-$currentEp?animeId=watchlist-$index&episodeNumber=$currentEp');
                    },
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.accentPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemes.spaceMd,
                        vertical: AppThemes.spaceXs,
                      ),
                      minimumSize: const Size(0, 32),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // More options
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withOpacity(0.5),
              ),
              onPressed: () {
                _showItemOptions(index);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSortOptions() {
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
                  'Sort by',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildSortOption('Recently Updated', true),
              _buildSortOption('Recently Added', false),
              _buildSortOption('Title (A-Z)', false),
              _buildSortOption('Title (Z-A)', false),
              _buildSortOption('Rating', false),
              const SizedBox(height: AppThemes.spaceLg),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSortOption(String label, bool isSelected) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
  
  void _showItemOptions(int index) {
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
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  'View Details',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/anime/watchlist-$index');
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Change Status',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: const Text(
                  'Download Episodes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Remove from Watchlist',
                  style: TextStyle(color: Colors.red),
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
