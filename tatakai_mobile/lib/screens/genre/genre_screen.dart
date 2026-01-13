import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/services/api_service.dart';
import 'package:tatakai_mobile/models/anime.dart';
import 'package:tatakai_mobile/providers/anime_provider.dart';

class GenreScreen extends ConsumerStatefulWidget {
  final String genre;
  
  const GenreScreen({super.key, required this.genre});
  
  @override
  ConsumerState<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends ConsumerState<GenreScreen> {
  String _sortBy = 'Popularity';
  bool _isLoading = true;
  String? _error;
  List<AnimeCard> _animes = [];
  int _currentPage = 1;
  bool _hasNextPage = false;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _fetchGenreAnimes();
  }
  
  Future<void> _fetchGenreAnimes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.fetchGenreAnimes(widget.genre, page: _currentPage);
      
      // Attempt to parse response. Assuming structure is similar to SearchResult or contains 'animes'
      List<AnimeCard> newAnimes = [];
      
      if (response.containsKey('animes')) {
         final list = response['animes'] as List;
         newAnimes = list.map((e) => AnimeCard.fromJson(e)).toList();
      }
      
      if (response.containsKey('hasNextPage')) {
        _hasNextPage = response['hasNextPage'] as bool; 
      }
      
      setState(() {
        _animes = newAnimes;
        _isLoading = false;
      });
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      appBar: AppBar(
        backgroundColor: AppThemes.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.genre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () => _showSortOptions(),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppThemes.accentPink));
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading genre',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _fetchGenreAnimes,
              child: const Text('Retry', style: TextStyle(color: AppThemes.accentPink)),
            ),
          ],
        ),
      );
    }
    
    if (_animes.isEmpty) {
      return const Center(
        child: Text(
          'No animes found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: AppThemes.spaceMd,
        mainAxisSpacing: AppThemes.spaceMd,
      ),
      itemCount: _animes.length,
      itemBuilder: (context, index) => _buildAnimeCard(_animes[index]),
    );
  }
  
  Widget _buildAnimeCard(AnimeCard anime) {
    final apiService = ref.read(apiServiceProvider);
    return GestureDetector(
      onTap: () {
        context.push('/anime/${anime.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      imageUrl: apiService.getProxiedImageUrl(anime.poster),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Container(
                        color: AppThemes.darkSurface,
                        child: const Icon(Icons.broken_image, color: Colors.white24),
                      ),
                    ),
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
                              anime.rating ?? 'N/A', // Assuming rating might be in new model or fallback
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Also show episode count if available
                             const SizedBox(width: 4),
                             const Text('•', style: TextStyle(color: Colors.white54, fontSize: 10)),
                              const SizedBox(width: 4),
                             Text(
                               '${anime.episodes.sub}',
                               style: const TextStyle(color: Colors.white, fontSize: 11),
                             ),
                              const SizedBox(width: 2),
                              const Icon(Icons.subtitles, size: 10, color: Colors.white),
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
          Text(
            anime.name,
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
              ...['Popularity', 'Rating', 'Latest', 'A-Z'].map((sort) {
                final isSelected = _sortBy == sort;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppThemes.accentPink : Colors.white.withOpacity(0.5),
                  ),
                  title: Text(
                    sort,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    ),
                  ),
                  onTap: () {
                    setState(() => _sortBy = sort);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: AppThemes.spaceMd),
            ],
          ),
        );
      },
    );
  }
}

