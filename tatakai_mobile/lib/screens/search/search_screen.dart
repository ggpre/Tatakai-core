import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/widgets/common/anime_cards.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search anime...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.white54,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _isSearching = false;
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isSearching = value.isNotEmpty;
                          });
                        },
                        onSubmitted: (value) {
                          // Perform search
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Show filters
                          _showFilterBottomSheet();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search results or suggestions
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildSearchSuggestions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        return AnimeCard(
          title: 'Anime ${index + 1}',
          subtitle: 'Sub | Dub',
          onTap: () {
            // Navigate to anime detail
          },
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (_buildRecentSearches().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const GradientIcon(icon: Icons.history, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Clear recent searches
                    },
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ..._buildRecentSearches(),
            const SizedBox(height: 24),
          ],
          
          // Popular searches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const GradientIcon(icon: Icons.trending_up, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Popular Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              children: [
                'Attack on Titan',
                'Demon Slayer',
                'My Hero Academia',
                'One Piece',
                'Naruto',
                'Jujutsu Kaisen',
                'Spy x Family',
                'Chainsaw Man',
              ].map((search) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    setState(() {
                      _isSearching = true;
                    });
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
                      search,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Trending anime
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const GradientIcon(icon: Icons.local_fire_department, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Trending Now',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                  title: 'Trending Anime ${index + 1}',
                  subtitle: 'Episode ${index + 1}',
                  onTap: () {
                    // Navigate to anime detail
                  },
                  height: 230,
                );
              },
            ),
          ),
          
          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }

  List<Widget> _buildRecentSearches() {
    // Mock recent searches - replace with actual data
    final recentSearches = ['One Piece', 'Naruto', 'Bleach'];
    
    return recentSearches.map((search) {
      return ListTile(
        leading: const Icon(Icons.history, color: Colors.white54),
        title: Text(search),
        trailing: IconButton(
          icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
          onPressed: () {
            // Remove from recent searches
          },
        ),
        onTap: () {
          _searchController.text = search;
          setState(() {
            _isSearching = true;
          });
        },
      );
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppGradients.cardGradient,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const GradientIcon(icon: Icons.filter_list, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'TV', 'Movie', 'OVA', 'Special']
                    .map((type) => FilterChip(
                          label: Text(type),
                          onSelected: (selected) {},
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Apply Filters',
                onPressed: () {
                  Navigator.pop(context);
                },
                width: double.infinity,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
