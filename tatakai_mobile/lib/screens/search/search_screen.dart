import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';
import 'package:tatakai_mobile/models/anime.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  String _searchQuery = '';
  
  final List<String> _recentSearches = [
    'Attack on Titan',
    'Demon Slayer',
    'One Piece',
    'Jujutsu Kaisen',
  ];
  
  final List<String> _popularGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Romance',
    'Sci-Fi',
  ];
  
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
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _isSearching = value.isNotEmpty;
    });
    
    // Trigger search if query is long enough
    if (value.length >= 3) {
      ref.read(searchProvider.notifier).search(value);
    } else if (value.isEmpty) {
      ref.read(searchProvider.notifier).clearSearch();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(),
            
            // Content
            Expanded(
              child: _isSearching 
                  ? _buildSearchResults(searchState)
                  : _buildDiscoverContent(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppThemes.darkSurface,
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search anime...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppThemes.spaceLg,
                    vertical: AppThemes.spaceMd,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppThemes.spaceMd),
          Container(
            decoration: BoxDecoration(
              color: AppThemes.darkSurface,
              borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                _showFilterSheet();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDiscoverContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
              child: Row(
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _recentSearches.clear();
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: AppThemes.accentPink,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppThemes.spaceMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
              child: Wrap(
                spacing: AppThemes.spaceSm,
                runSpacing: AppThemes.spaceSm,
                children: _recentSearches.map((search) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = search;
                      _onSearchChanged(search);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppThemes.spaceMd,
                        vertical: AppThemes.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.darkSurface,
                        borderRadius: BorderRadius.circular(AppThemes.radiusLarge),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: AppThemes.spaceSm),
                          Text(
                            search,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppThemes.spaceXl),
          ],
          
          // Popular genres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
            child: Text(
              'Popular Genres',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
            child: Wrap(
              spacing: AppThemes.spaceSm,
              runSpacing: AppThemes.spaceSm,
              children: _popularGenres.map((genre) {
                return GestureDetector(
                  onTap: () {
                    context.push('/genre/$genre');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppThemes.spaceLg,
                      vertical: AppThemes.spaceMd,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppThemes.accentPink.withOpacity(0.3),
                          AppThemes.accentPinkLight.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                      border: Border.all(
                        color: AppThemes.accentPink.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      genre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppThemes.spaceXl),
          
          // Trending
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
            child: Text(
              'Trending Searches',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildTrendingItem(index);
            },
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildTrendingItem(int index) {
    return GestureDetector(
      onTap: () {
        context.push('/anime/trending-$index');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppThemes.spaceLg,
          vertical: AppThemes.spaceXs,
        ),
        padding: const EdgeInsets.all(AppThemes.spaceMd),
        decoration: BoxDecoration(
          color: AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: index < 3 
                    ? AppThemes.accentPink.withOpacity(0.2) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index < 3 ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppThemes.spaceMd),
            
            // Poster
            Container(
              width: 45,
              height: 60,
              decoration: BoxDecoration(
                color: AppThemes.darkBackground,
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
              ),
              child: const Center(
                child: Icon(Icons.movie, size: 20, color: Colors.white24),
              ),
            ),
            const SizedBox(width: AppThemes.spaceMd),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trending Anime ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: AppThemes.ratingGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${100 - index * 5} searches',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchResults(SearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Search failed: ${searchState.error}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_searchQuery.length >= 3) {
                  ref.read(searchProvider.notifier).search(_searchQuery);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final results = searchState.results;
    
    if (results.isEmpty && !searchState.isLoading) {
      if (_searchQuery.length >= 3) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'No results found for "${_searchQuery}"',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      return Container(); // Should not happen if isSearching is true
    }
    
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!searchState.isLoadingMore && 
            searchState.hasNextPage &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(searchProvider.notifier).loadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: AppThemes.spaceMd,
          mainAxisSpacing: AppThemes.spaceMd,
        ),
        // Add one more item for the loading indicator if loading more
        itemCount: results.length + (searchState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == results.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: AppThemes.accentPink),
              ),
            );
          }
          return _buildSearchResultCard(results[index]);
        },
      ),
    );
  }
  
  Widget _buildSearchResultCard(AnimeCard result) {
    final apiService = ref.watch(apiServiceProvider);
    
    return GestureDetector(
      onTap: () {
        context.push('/anime/${result.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster
          Expanded(
            child: Container(
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
                    CachedNetworkImage(
                      imageUrl: apiService.getProxiedImageUrl(result.poster),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.white24),
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
                              result.rating ?? 'N/A',
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
          ),
          const SizedBox(height: AppThemes.spaceSm),
          
          // Title
          Text(
            result.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppThemes.radiusXLarge),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: AppThemes.spaceMd),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Title
                  const Padding(
                    padding: EdgeInsets.all(AppThemes.spaceLg),
                    child: Text(
                      'Filter & Sort',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Sort by
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
                    child: Text(
                      'Sort by',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
                    child: Wrap(
                      spacing: AppThemes.spaceSm,
                      runSpacing: AppThemes.spaceSm,
                      children: ['Popularity', 'Rating', 'Latest', 'A-Z'].map((sort) {
                        return _buildFilterChip(sort, sort == 'Popularity');
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: AppThemes.spaceXl),
                  
                  // Type
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
                    child: Text(
                      'Type',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
                    child: Wrap(
                      spacing: AppThemes.spaceSm,
                      runSpacing: AppThemes.spaceSm,
                      children: ['All', 'TV', 'Movie', 'OVA', 'ONA'].map((type) {
                        return _buildFilterChip(type, type == 'All');
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: AppThemes.spaceXl),
                  
                  // Status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
                    child: Text(
                      'Status',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppThemes.spaceMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
                    child: Wrap(
                      spacing: AppThemes.spaceSm,
                      runSpacing: AppThemes.spaceSm,
                      children: ['All', 'Airing', 'Completed', 'Upcoming'].map((status) {
                        return _buildFilterChip(status, status == 'All');
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: AppThemes.spaceXxl),
                  
                  // Apply button
                  Padding(
                    padding: const EdgeInsets.all(AppThemes.spaceLg),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppThemes.accentPink,
                          padding: const EdgeInsets.symmetric(vertical: AppThemes.spaceLg),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppThemes.spaceLg,
          vertical: AppThemes.spaceMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppThemes.accentPink : Colors.transparent,
          borderRadius: BorderRadius.circular(AppThemes.radiusXXLarge),
          border: isSelected
              ? null
              : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
