import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/config/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildStats(),
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceXl),
      child: Column(
        children: [
          // Profile picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppThemes.accentPink, AppThemes.accentPinkLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppThemes.radiusXXLarge),
              boxShadow: [
                BoxShadow(
                  color: AppThemes.accentPink.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: AppThemes.spaceLg),
          
          // Name
          const Text(
            'Anime Lover',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppThemes.spaceXs),
          
          // Username
          Text(
            '@animelover123',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppThemes.spaceLg),
          
          // Edit profile button
          OutlinedButton.icon(
            onPressed: () {},
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
        ],
      ),
    );
  }
  
  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppThemes.spaceLg),
      padding: const EdgeInsets.all(AppThemes.spaceLg),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Watching', '12'),
          _buildStatDivider(),
          _buildStatItem('Completed', '48'),
          _buildStatDivider(),
          _buildStatItem('Hours', '256'),
          _buildStatDivider(),
          _buildStatItem('Reviews', '8'),
        ],
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
            onTap: () {},
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
            onTap: () {
              _showLogoutDialog();
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
