import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with profile info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppGradients.cardGradient,
                ),
                child: Column(
                  children: [
                    // Profile picture
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.primaryGradient,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 3,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Username
                    GradientText(
                      'Anime Fan',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'anime.fan@tatakai.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(context, '127', 'Watching'),
                        _buildDivider(),
                        _buildStat(context, '543', 'Completed'),
                        _buildDivider(),
                        _buildStat(context, '89', 'Favorites'),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Menu items
              _buildMenuItem(
                context,
                Icons.account_circle_outlined,
                'Account Settings',
                () {
                  // Navigate to account settings
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.palette_outlined,
                'Theme',
                () {
                  context.push('/settings');
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.notifications_outlined,
                'Notifications',
                () {
                  // Navigate to notification settings
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.download_outlined,
                'Download Settings',
                () {
                  // Navigate to download settings
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.security_outlined,
                'Privacy & Security',
                () {
                  // Navigate to privacy settings
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.language_outlined,
                'Language',
                () {
                  // Navigate to language settings
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.help_outline,
                'Help & Support',
                () {
                  // Navigate to help
                },
              ),
              
              _buildMenuItem(
                context,
                Icons.info_outline,
                'About',
                () {
                  // Navigate to about
                },
              ),
              
              const SizedBox(height: 24),
              
              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlineGradientButton(
                  text: 'Logout',
                  icon: Icons.logout,
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  width: double.infinity,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Version info
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        GradientText(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppGradients.cardGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                GradientIcon(icon: icon, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const GradientIcon(icon: Icons.logout, size: 24),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          GradientButton(
            text: 'Logout',
            onPressed: () {
              Navigator.pop(context);
              // Perform logout
              context.go('/auth');
            },
          ),
        ],
      ),
    );
  }
}
