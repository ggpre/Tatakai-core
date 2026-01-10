import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/widgets/common/anime_cards.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const GradientIcon(icon: Icons.favorite, size: 28),
                  const SizedBox(width: 12),
                  GradientText(
                    'Favorites',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab(context, 'All', true),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Watching', false),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Completed', false),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Plan to Watch', false),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: _buildFavoritesList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle tab change
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primaryGradient : null,
          color: isSelected ? null : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context) {
    // Mock data - replace with actual favorites
    final hasFavorites = true;

    if (!hasFavorites) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GradientIcon(
              icon: Icons.favorite_border,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding anime to your favorites!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

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
          subtitle: 'Episode ${index + 1}',
          onTap: () {
            // Navigate to anime detail
          },
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}
