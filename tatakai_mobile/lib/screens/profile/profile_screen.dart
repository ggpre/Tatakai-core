import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';
import 'package:tatakai_mobile/providers/watch_history_provider.dart';
import 'package:tatakai_mobile/providers/favorites_provider.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/models/user.dart';
import 'package:tatakai_mobile/screens/profile/widgets/avatar_picker.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final supabase = ref.read(supabaseServiceProvider);
    final user = supabase.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      final profile = await supabase.getUserProfile(user.id);
      setState(() {
        _profile = profile;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _updateAvatar(String imageUrl) async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    try {
      await ref.read(supabaseServiceProvider).updateProfileAvatar(user.id, imageUrl);
      _loadProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update avatar: $e')),
      );
    }
  }

  Future<void> _updateBanner(String imageUrl) async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) return;

    try {
      await ref.read(supabaseServiceProvider).updateProfileBanner(user.id, imageUrl);
      _loadProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update banner: $e')),
      );
    }
  }

  void _showAvatarPicker(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarPicker(
        type: type,
        onImageSelected: type == 'avatar' ? _updateAvatar : _updateBanner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(currentUserProvider);
    final watchHistory = ref.watch(watchHistoryItemsProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.items;

    final displayName = _profile?.displayName ?? authUser?.displayName ?? authUser?.email ?? 'User';
    final username = _profile?.username ?? authUser?.username ?? '';
    final avatar = _profile?.avatarUrl ?? authUser?.avatarUrl;
    final banner = _profile?.bannerUrl; // Add bannerUrl to UserProfile model if missing

    return Scaffold(
      backgroundColor: AppThemes.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(displayName, username, avatar, banner),
              const SizedBox(height: AppThemes.spaceLg),
              
              // Edit profile button
              OutlinedButton.icon(
                onPressed: () => _showEditProfileSheet(),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemes.accentPink,
                  side: const BorderSide(color: AppThemes.accentPink, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemes.spaceXl,
                    vertical: AppThemes.spaceMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppThemes.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppThemes.spaceLg),
              _buildStats(),
              _buildActivitySection(watchHistory, favorites),
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(String displayName, String username, String? avatarUrl, String? bannerUrl) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Banner
        GestureDetector(
          onTap: () => _showAvatarPicker('banner'),
          child: Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              color: AppThemes.darkSurface,
              image: bannerUrl != null ? DecorationImage(
                image: NetworkImage(bannerUrl),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: bannerUrl == null 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 4),
                        Text('Add Banner', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
                      ],
                    ),
                  )
                : null,
          ),
        ),
        
        // Avatar
        Positioned(
          bottom: 0,
          left: 16, // AppThemes.spaceLg
          child: GestureDetector(
            onTap: () => _showAvatarPicker('avatar'),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppThemes.darkBackground, width: 4),
                color: AppThemes.darkSurface,
                image: avatarUrl != null ? DecorationImage(
                  image: NetworkImage(avatarUrl),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
        ),
        
        // Edit Profile Button
        Positioned(
          bottom: 16,
          right: 16,
          child: OutlinedButton.icon(
            onPressed: _showEditProfileSheet,
            icon: const Icon(Icons.edit, size: 16, color: AppThemes.accentPink),
            label: const Text('Edit Profile', style: TextStyle(color: AppThemes.accentPink)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppThemes.accentPink, width: 1.5),
              backgroundColor: AppThemes.darkSurface.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppThemes.radiusPill),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStats() {
    final supabase = ref.watch(supabaseServiceProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: FutureBuilder<Map<String, int>>(
        future: supabase.getProfileStats(_profile?.id ?? ref.read(currentUserProvider)?.id ?? ''),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {};
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Watching', '${stats['watching'] ?? 0}'),
              _buildStatDivider(),
              _buildStatItem('Completed', '${stats['completed'] ?? 0}'),
              _buildStatDivider(),
              _buildStatItem('On Hold', '${stats['on_hold'] ?? 0}'), // Replaced Hours with On Hold
              _buildStatDivider(),
              _buildStatItem('Dropped', '${stats['dropped'] ?? 0}'), // Replaced Reviews with Dropped
            ],
          );
        }
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppThemes.accentPink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppThemes.spaceXs),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildActivitySection(List<WatchHistory> history, List<Favorite> favorites) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppThemes.spaceLg, AppThemes.spaceLg, AppThemes.spaceLg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: AppThemes.spaceSm),
          if (history.isEmpty && favorites.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppThemes.spaceLg),
              decoration: BoxDecoration(
                color: AppThemes.darkSurface,
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
              ),
              child: Center(
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
            )
          else
            Column(
              children: [
                if (history.isNotEmpty) ...[
                  for (var item in history.take(3))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppThemes.darkSurface,
                          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                        ),
                        child: item.animePoster != null
                            ? Image.network(item.animePoster!, fit: BoxFit.cover)
                            : const Icon(Icons.movie, color: Colors.white24),
                      ),
                      title: Text(
                        item.animeName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Episode ${item.episodeNumber} • ${item.watchedAt.toLocal()}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                      onTap: () => context.push('/anime/${item.animeId}'),
                    ),
                ],
                if (favorites.isNotEmpty) ...[
                  const SizedBox(height: AppThemes.spaceSm),
                  _buildSectionTitle('Favorites'),
                  const SizedBox(height: AppThemes.spaceSm),
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      itemBuilder: (context, i) {
                        final f = favorites[i];
                        return GestureDetector(
                          onTap: () => context.push('/anime/${f.animeId}'),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: AppThemes.spaceSm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppThemes.darkSurface,
                                    borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
                                  ),
                                  child: f.animePoster != null
                                      ? Image.network(f.animePoster!, fit: BoxFit.cover)
                                      : const Icon(Icons.movie, color: Colors.white24),
                                ),
                                const SizedBox(height: AppThemes.spaceXs),
                                Text(
                                  f.animeName,
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: AppThemes.spaceLg),
        ],
      ),
    );
  }

  void _showEditProfileSheet() {
    final displayController = TextEditingController(text: _profile?.displayName ?? '');
    final bioController = TextEditingController(text: _profile?.bio ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemes.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppThemes.radiusXLarge)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
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
                Padding(
                  padding: const EdgeInsets.all(AppThemes.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppThemes.spaceSm),
                      TextField(
                        controller: displayController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: 'Display name', labelStyle: TextStyle(color: Colors.white.withOpacity(0.6))),
                      ),
                      const SizedBox(height: AppThemes.spaceSm),
                      TextField(
                        controller: bioController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: 'Bio', labelStyle: TextStyle(color: Colors.white.withOpacity(0.6))),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppThemes.spaceMd),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                // Save profile
                                final supabase = ref.read(supabaseServiceProvider);
                                final user = supabase.currentUser;
                                if (user == null) return;
                                await supabase.updateUserProfile(user.id, {
                                  'display_name': displayController.text,
                                  'bio': bioController.text,
                                });
                                await _loadProfile();
                                Navigator.pop(context);
                              },
                              child: const Text('Save'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppThemes.accentPink,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppThemes.spaceLg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity section
          _buildSectionTitle('Activity'),
          _buildMenuItem(
            Icons.history,
            'Watch History',
            'View your recently watched',
            onTap: () => context.push('/watch-history'),
          ),
          _buildMenuItem(
            Icons.download_outlined,
            'Downloads',
            'Manage downloaded content',
            onTap: () => context.push('/downloads'),
          ),
          _buildMenuItem(
            Icons.playlist_play,
            'Playlists',
            'Your custom playlists',
            onTap: () => context.push('/playlists'),
          ),
          _buildMenuItem(
            Icons.leaderboard_outlined,
            'Tier Lists',
            'Your anime rankings',
            onTap: () => context.push('/tierlists'),
          ),
          
          const SizedBox(height: AppThemes.spaceXl),
          
          // Settings section
          _buildSectionTitle('Settings'),
          _buildMenuItem(
            Icons.notifications_outlined,
            'Notifications',
            'Manage push notifications',
            onTap: () {},
          ),
          _buildMenuItem(
            Icons.palette_outlined,
            'Appearance',
            'Theme and display settings',
            onTap: () => context.push('/settings'),
          ),
          _buildMenuItem(
            Icons.language,
            'Language',
            'English',
            onTap: () {},
          ),
          _buildMenuItem(
            Icons.play_circle_outline,
            'Playback',
            'Video quality and playback settings',
            onTap: () {},
          ),
          
          const SizedBox(height: AppThemes.spaceXl),
          
          // Support section
          _buildSectionTitle('Support'),
          _buildMenuItem(
            Icons.help_outline,
            'Help Center',
            'FAQ and support',
            onTap: () {},
          ),
          _buildMenuItem(
            Icons.bug_report_outlined,
            'Report a Bug',
            'Help us improve',
            onTap: () {},
          ),
          _buildMenuItem(
            Icons.info_outline,
            'About',
            'Version 1.0.0',
            onTap: () {},
          ),
          
          const SizedBox(height: AppThemes.spaceXl),
          
          // Logout
          _buildMenuItem(
            Icons.logout,
            'Log Out',
            '',
            isDestructive: true,
            onTap: () async {
              // sign out via auth provider
              await ref.read(authProvider.notifier).signOut();
              context.go('/auth');
            },
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppThemes.spaceMd),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppThemes.spaceSm),
        padding: const EdgeInsets.all(AppThemes.spaceMd),
        decoration: BoxDecoration(
          color: AppThemes.darkSurface,
          borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : AppThemes.accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppThemes.accentPink,
                size: 22,
              ),
            ),
            const SizedBox(width: AppThemes.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/auth');
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
