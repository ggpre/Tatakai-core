import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tatakai_mobile/widgets/common/anime_cards.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';

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
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image with gradient overlay
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.pink : Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image placeholder
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.movie,
                        size: 64,
                        color: Colors.white24,
                      ),
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
                          Colors.black.withOpacity(0.5),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  GradientText(
                    'Anime Title',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Metadata chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(context, 'TV', Icons.tv),
                      _buildChip(context, '24 Episodes', Icons.movie),
                      _buildChip(context, '⭐ 8.5', null),
                      _buildChip(context, 'Fall 2024', Icons.calendar_today),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'An epic tale of adventure and courage. Follow the journey of our heroes as they battle against evil forces to save their world. Experience stunning animation and compelling storytelling in this action-packed series.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.87),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GradientButton(
                          text: 'Watch Now',
                          icon: Icons.play_arrow,
                          onPressed: () {
                            context.push('/watch/episode-1?animeId=${widget.animeId}');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlineGradientButton(
                          text: 'Trailer',
                          icon: Icons.play_circle_outline,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withOpacity(0.6),
                      tabs: const [
                        Tab(text: 'Episodes'),
                        Tab(text: 'Details'),
                        Tab(text: 'Related'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEpisodesList(),
                _buildDetailsTab(),
                _buildRelatedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEpisodesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 24,
      itemBuilder: (context, index) {
        return EpisodeCard(
          episodeNumber: '${index + 1}',
          title: 'Episode Title ${index + 1}',
          duration: '24:00',
          onTap: () {
            context.push('/watch/episode-${index + 1}?animeId=${widget.animeId}&episodeNumber=${index + 1}');
          },
        );
      },
    );
  }
  
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientCard(
            child: Column(
              children: [
                _buildDetailRow('Status', 'Ongoing'),
                const Divider(height: 24),
                _buildDetailRow('Genres', 'Action, Adventure, Fantasy'),
                const Divider(height: 24),
                _buildDetailRow('Studio', 'Ufotable'),
                const Divider(height: 24),
                _buildDetailRow('Season', 'Fall 2024'),
                const Divider(height: 24),
                _buildDetailRow('Duration', '24 min per ep'),
                const Divider(height: 24),
                _buildDetailRow('Rating', 'PG-13'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              const GradientIcon(icon: Icons.people, size: 20),
              const SizedBox(width: 8),
              Text(
                'Staff',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          GradientCard(
            child: Column(
              children: [
                _buildDetailRow('Director', 'John Doe'),
                const Divider(height: 24),
                _buildDetailRow('Writer', 'Jane Smith'),
                const Divider(height: 24),
                _buildDetailRow('Music', 'Composer Name'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRelatedTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.55,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return AnimeCard(
          title: 'Related Anime ${index + 1}',
          subtitle: 'TV Series',
          onTap: () {
            // Navigate to related anime detail
          },
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}
