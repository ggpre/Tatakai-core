import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});
  
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
                  const GradientIcon(icon: Icons.download, size: 28),
                  const SizedBox(width: 12),
                  GradientText(
                    'Downloads',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      // Show download settings
                    },
                  ),
                ],
              ),
            ),
            
            // Storage info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GradientCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storage,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Storage Used',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '2.5 GB / 10 GB',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GradientText(
                      '25%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab(context, 'All', true),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Downloading', false),
                  const SizedBox(width: 8),
                  _buildTab(context, 'Completed', false),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Downloads list
            Expanded(
              child: _buildDownloadsList(context),
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

  Widget _buildDownloadsList(BuildContext context) {
    // Mock data - replace with actual downloads
    final hasDownloads = true;

    if (!hasDownloads) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GradientIcon(
              icon: Icons.download_outlined,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Download episodes to watch offline!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildDownloadItem(context, index);
      },
    );
  }

  Widget _buildDownloadItem(BuildContext context, int index) {
    final isDownloading = index % 3 == 0;
    final progress = isDownloading ? 0.65 : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppGradients.cardGradient,
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white24,
                    size: 32,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anime Title ${index + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Episode ${index + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress bar
                  if (isDownloading) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% • 2.5 MB / 4 MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '150 MB • 720p',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Action button
            IconButton(
              icon: Icon(
                isDownloading ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                // Play or pause download
              },
            ),
            
            // Delete button
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white54,
                size: 24,
              ),
              onPressed: () {
                // Delete download
              },
            ),
          ],
        ),
      ),
    );
  }
}
