import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/playlists_provider.dart';
import 'package:tatakai_mobile/models/playlist.dart';

class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});
  
  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
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
        title: const Text(
          'Playlists',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreatePlaylistDialog(),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(playlistsProvider);
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.error}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: AppThemes.spaceMd),
                  ElevatedButton(
                    onPressed: () => ref.read(playlistsProvider.notifier).loadPlaylists(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          final playlists = state.playlists;
          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.playlist_play, color: Colors.white54, size: 48),
                  SizedBox(height: AppThemes.spaceSm),
                  Text('No playlists yet', style: TextStyle(color: Colors.white54)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppThemes.spaceLg),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return _buildPlaylistCardFor(playlist);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildPlaylistCardFor(Playlist playlist) {
    return GestureDetector(
      onTap: () {
        // TODO: open playlist view
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemes.spaceMd),
        decoration: BoxDecoration(
          color: AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
        ),
        child: Row(
          children: [
            // Playlist cover (stack or single cover)
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.all(AppThemes.spaceMd),
              decoration: BoxDecoration(
                color: AppThemes.darkBackground.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                image: playlist.coverImage != null
                    ? DecorationImage(
                        image: NetworkImage(playlist.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: playlist.coverImage == null
                  ? const Center(
                      child: Icon(Icons.playlist_play, color: Colors.white, size: 32),
                    )
                  : null,
            ),

            // Playlist info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppThemes.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppThemes.spaceXs),
                    Text(
                      '${playlist.itemsCount} anime',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppThemes.spaceSm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppThemes.spaceSm,
                            vertical: AppThemes.spaceXs,
                          ),
                          decoration: BoxDecoration(
                            color: AppThemes.accentPink.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            playlist.isPublic ? 'Public' : 'Private',
                            style: const TextStyle(
                              color: AppThemes.accentPink,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // More options
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withOpacity(0.5),
              ),
              onPressed: () => _showPlaylistOptionsFor(playlist),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showCreatePlaylistDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text(
            'Create Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              filled: true,
              fillColor: AppThemes.darkBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(context);
                await ref.read(playlistsProvider.notifier).createPlaylist(name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.accentPink,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  void _showPlaylistOptionsFor(Playlist playlist) {
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
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Rename',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              if (!playlist.isPublic)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(playlistsProvider.notifier).deletePlaylist(playlist.id);
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
