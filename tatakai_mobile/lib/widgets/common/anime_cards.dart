import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tatakai_mobile/config/gradients.dart';

class AnimeCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double width;
  final double height;
  final bool showGradient;

  const AnimeCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.width = 130,
    this.height = 200,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image container
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or placeholder
                    if (imageUrl != null && imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildShimmer(),
                        errorWidget: (context, url, error) => _buildPlaceholder(context),
                      )
                    else
                      _buildPlaceholder(context),
                    
                    // Gradient overlay
                    if (showGradient)
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppGradients.darkOverlay,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Title
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1525),
      highlightColor: const Color(0xFF2A1F35),
      child: Container(
        color: const Color(0xFF1A1525),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: Colors.white24,
        ),
      ),
    );
  }
}

class FeaturedAnimeCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? description;
  final VoidCallback onWatchPressed;
  final VoidCallback onInfoPressed;
  final double height;

  const FeaturedAnimeCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.description,
    required this.onWatchPressed,
    required this.onInfoPressed,
    this.height = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (imageUrl != null && imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildShimmer(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        // Watch button
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppGradients.buttonGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFAB47BC).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onWatchPressed,
                                borderRadius: BorderRadius.circular(12),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Watch Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Info button
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onInfoPressed,
                              borderRadius: BorderRadius.circular(12),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1525),
      highlightColor: const Color(0xFF2A1F35),
      child: Container(
        color: const Color(0xFF1A1525),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.white24,
        ),
      ),
    );
  }
}

class EpisodeCard extends StatelessWidget {
  final String? thumbnailUrl;
  final String episodeNumber;
  final String title;
  final String? duration;
  final VoidCallback onTap;

  const EpisodeCard({
    super.key,
    this.thumbnailUrl,
    required this.episodeNumber,
    required this.title,
    this.duration,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardGradient,
                    ),
                    child: thumbnailUrl != null && thumbnailUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: thumbnailUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildShimmer(),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.white24,
                                size: 32,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white24,
                              size: 32,
                            ),
                          ),
                  ),
                  
                  // Duration badge
                  if (duration != null)
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
                        child: Text(
                          duration!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Episode $episodeNumber',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Play icon
            const Icon(
              Icons.play_circle_outline,
              color: Colors.white54,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1525),
      highlightColor: const Color(0xFF2A1F35),
      child: Container(
        color: const Color(0xFF1A1525),
      ),
    );
  }
}
