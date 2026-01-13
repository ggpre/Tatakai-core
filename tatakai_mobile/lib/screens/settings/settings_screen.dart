import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedTheme = 'wakuwaku_dark';
  bool _darkMode = true;
  bool _autoPlay = true;
  bool _skipIntro = true;
  String _videoQuality = 'Auto';
  String _maxDownloadStorage = '5 GB';
  bool _syncWatchHistory = true;
  bool _pushNotifications = true;
  bool _messageNotifications = true;
  
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
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

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
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppThemes.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance section
            _buildSectionTitle('Appearance'),
            _buildThemeSelector(), // This can remain as is but should trigger notifier.setTheme
            const SizedBox(height: AppThemes.spaceMd),
            // Dark mode is likely tied to theme or separate. 
            // If theme logic is just string specific, maybe just keep theme selector.
            // But UserPreferences has 'theme'. 
            // Let's assume theme selector handles it using notifier.
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Playback section
            _buildSectionTitle('Playback'),
            _buildSwitchItem(
              'Auto-Play',
              'Automatically play next episode',
              settings.autoPlayNext,
              (value) => notifier.toggleAutoPlayNext(value),
            ),
            _buildSwitchItem(
              'Skip Intro',
              'Automatically skip opening theme',
              settings.autoSkipIntro,
              (value) => notifier.toggleAutoSkipIntro(value),
            ),
             _buildSwitchItem(
              'Skip Outro',
              'Automatically skip ending theme',
              settings.autoSkipOutro,
              (value) => notifier.toggleAutoSkipOutro(value),
            ),
            _buildDropdownItem(
              'Video Quality',
              settings.videoQuality,
              ['Auto', '1080p', '720p', '480p', '360p'],
              (value) => notifier.setVideoQuality(value!),
            ),
            _buildSliderItem(
              'Playback Speed',
              settings.playbackSpeed,
              0.5,
              2.0,
              (value) => notifier.setPlaybackSpeed(value),
            ),
             _buildDropdownItem(
              'Subtitle Language',
              settings.subtitleLanguage,
              ['English', 'Spanish', 'French', 'German', 'Russian', 'Portuguese', 'Italian'], // Add more as needed
              (value) => notifier.setSubtitleLanguage(value!),
            ),
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Downloads section
            _buildSectionTitle('Downloads'),
             _buildSwitchItem(
              'Download on Wi-Fi Only',
              'Only download when connected to Wi-Fi',
              settings.downloadOnWifiOnly,
              (value) => notifier.toggleDownloadOnWifiOnly(value),
            ),
            // Max storage and location could be added later
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Notifications section
            _buildSectionTitle('Notifications'),
            _buildSwitchItem(
              'Enable Notifications',
              'Receive push notifications for updates',
              settings.enableNotifications,
              (value) => notifier.toggleNotifications(value),
            ),
            
             const SizedBox(height: AppThemes.spaceXl),
             
             // Data & Storage section
             _buildSectionTitle('Data & Storage'),
             _buildMenuItem(
               'Clear Cache',
               'Remove all cached images and data',
               onTap: _showClearCacheDialog,
             ),
             _buildMenuItem(
               'Clear Watch History',
               'Remove your entire watch history',
               onTap: _showClearHistoryDialog,
             ),
             
             const SizedBox(height: AppThemes.spaceXl),
             
             // About
             _buildSectionTitle('About'),
             ListTile(
               title: const Text('Version', style: TextStyle(color: Colors.white)),
               subtitle: const Text('1.0.0', style: TextStyle(color: Colors.white54)),
             ),
          ],
        ),
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
  
  Widget _buildThemeSelector() {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    
    final themes = [
      ('wakuwaku_dark', 'Dark', const Color(0xFF1B1919)),
      ('wakuwaku_light', 'Light', const Color(0xFFEFECEC)),
    ];
    
    return Container(
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppThemes.spaceMd),
          Wrap(
            spacing: AppThemes.spaceSm,
            runSpacing: AppThemes.spaceSm,
            children: themes.map((theme) {
              final isSelected = settings.theme == theme.$1;
              return GestureDetector(
                onTap: () {
                  notifier.setTheme(theme.$1);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppThemes.spaceMd,
                    vertical: AppThemes.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppThemes.accentPink.withOpacity(0.2) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
                    border: Border.all(
                      color: isSelected 
                          ? AppThemes.accentPink 
                          : Colors.white.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.$3,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppThemes.spaceSm),
                      Text(
                        theme.$2,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitchItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceSm),
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppThemes.accentPink,
            activeTrackColor: AppThemes.accentPink.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDropdownItem(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppThemes.spaceSm),
      padding: const EdgeInsets.all(AppThemes.spaceMd),
      decoration: BoxDecoration(
        color: AppThemes.darkSurface,
        borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: AppThemes.darkSurface,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
               Text('${value.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white54)),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 6,
          activeColor: AppThemes.accentPink,
          inactiveColor: Colors.white24,
          onChanged: onChanged,
        ),
      ],
    );
  }


  
  Widget _buildMenuItem(
    String title,
    String subtitle, {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text(
            'Clear Cache',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This will clear all cached images and data. Are you sure?',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cache cleared'),
                    backgroundColor: AppThemes.darkSurface,
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: AppThemes.accentPink),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemes.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemes.radiusMedium),
          ),
          title: const Text(
            'Clear Watch History',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'This will remove all your watch history. This action cannot be undone.',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Watch history cleared'),
                    backgroundColor: AppThemes.darkSurface,
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
