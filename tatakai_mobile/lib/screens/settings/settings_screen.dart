import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/widgets/common/gradient_widgets.dart';
import 'package:tatakai_mobile/config/gradients.dart';
import 'package:tatakai_mobile/config/theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedTheme = 'default_dark';
  bool _autoPlay = true;
  bool _downloadWifiOnly = true;
  String _videoQuality = '1080p';
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Row(
                children: [
                  const GradientIcon(icon: Icons.settings, size: 24),
                  const SizedBox(width: 12),
                  const Text('Settings'),
                ],
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance Section
                    _buildSectionHeader('Appearance'),
                    const SizedBox(height: 12),
                    
                    GradientCard(
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.palette_outlined,
                            title: 'Theme',
                            subtitle: _getThemeDisplayName(_selectedTheme),
                            onTap: () => _showThemeSelector(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Playback Section
                    _buildSectionHeader('Playback'),
                    const SizedBox(height: 12),
                    
                    GradientCard(
                      child: Column(
                        children: [
                          _buildSwitchItem(
                            icon: Icons.play_circle_outlined,
                            title: 'Auto Play Next Episode',
                            subtitle: 'Automatically play the next episode',
                            value: _autoPlay,
                            onChanged: (value) {
                              setState(() {
                                _autoPlay = value;
                              });
                            },
                          ),
                          const Divider(height: 24),
                          _buildSettingItem(
                            icon: Icons.high_quality_outlined,
                            title: 'Video Quality',
                            subtitle: _videoQuality,
                            onTap: () => _showQualitySelector(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Downloads Section
                    _buildSectionHeader('Downloads'),
                    const SizedBox(height: 12),
                    
                    GradientCard(
                      child: Column(
                        children: [
                          _buildSwitchItem(
                            icon: Icons.wifi,
                            title: 'Download via WiFi Only',
                            subtitle: 'Save mobile data',
                            value: _downloadWifiOnly,
                            onChanged: (value) {
                              setState(() {
                                _downloadWifiOnly = value;
                              });
                            },
                          ),
                          const Divider(height: 24),
                          _buildSettingItem(
                            icon: Icons.folder_outlined,
                            title: 'Download Location',
                            subtitle: 'Internal Storage',
                            onTap: () {},
                          ),
                          const Divider(height: 24),
                          _buildSettingItem(
                            icon: Icons.delete_outlined,
                            title: 'Clear Download Cache',
                            subtitle: '2.5 GB',
                            onTap: () => _showClearCacheDialog(),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notifications Section
                    _buildSectionHeader('Notifications'),
                    const SizedBox(height: 12),
                    
                    GradientCard(
                      child: Column(
                        children: [
                          _buildSwitchItem(
                            icon: Icons.notifications_outlined,
                            title: 'Push Notifications',
                            subtitle: 'Get notified about new episodes',
                            value: _notifications,
                            onChanged: (value) {
                              setState(() {
                                _notifications = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // About Section
                    _buildSectionHeader('About'),
                    const SizedBox(height: 12),
                    
                    GradientCard(
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: Icons.info_outlined,
                            title: 'App Version',
                            subtitle: '1.0.0',
                            onTap: () {},
                            showArrow: false,
                          ),
                          const Divider(height: 24),
                          _buildSettingItem(
                            icon: Icons.description_outlined,
                            title: 'Terms of Service',
                            onTap: () {},
                          ),
                          const Divider(height: 24),
                          _buildSettingItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        GradientText(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GradientIcon(icon: icon, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GradientIcon(icon: icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String themeName) {
    return AppThemes.getThemeDisplayName(themeName);
  }

  void _showThemeSelector() {
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
                  const GradientIcon(icon: Icons.palette, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Choose Theme',
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
              SizedBox(
                height: 300,
                child: ListView(
                  children: AppThemes.themeNames.map((themeName) {
                    final isSelected = _selectedTheme == themeName;
                    return ListTile(
                      title: Text(_getThemeDisplayName(themeName)),
                      trailing: isSelected
                          ? const GradientIcon(icon: Icons.check, size: 24)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedTheme = themeName;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQualitySelector() {
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
                  const GradientIcon(icon: Icons.high_quality, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Video Quality',
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
              ...['Auto', '1080p', '720p', '480p', '360p'].map((quality) {
                final isSelected = _videoQuality == quality;
                return ListTile(
                  title: Text(quality),
                  trailing: isSelected
                      ? const GradientIcon(icon: Icons.check, size: 24)
                      : null,
                  onTap: () {
                    setState(() {
                      _videoQuality = quality;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const GradientIcon(icon: Icons.delete_outline, size: 24),
            const SizedBox(width: 12),
            Text(
              'Clear Cache',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to clear 2.5 GB of cached data?',
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
            text: 'Clear',
            onPressed: () {
              Navigator.pop(context);
              // Clear cache logic
            },
          ),
        ],
      ),
    );
  }
}
