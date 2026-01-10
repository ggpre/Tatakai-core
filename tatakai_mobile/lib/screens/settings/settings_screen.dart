import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/config/theme.dart';

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
            _buildThemeSelector(),
            const SizedBox(height: AppThemes.spaceMd),
            _buildSwitchItem(
              'Dark Mode',
              'Use dark theme throughout the app',
              _darkMode,
              (value) {
                setState(() => _darkMode = value);
              },
            ),
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Playback section
            _buildSectionTitle('Playback'),
            _buildSwitchItem(
              'Auto-Play',
              'Automatically play next episode',
              _autoPlay,
              (value) {
                setState(() => _autoPlay = value);
              },
            ),
            _buildSwitchItem(
              'Skip Intro',
              'Automatically skip opening theme',
              _skipIntro,
              (value) {
                setState(() => _skipIntro = value);
              },
            ),
            _buildDropdownItem(
              'Video Quality',
              _videoQuality,
              ['Auto', '1080p', '720p', '480p', '360p'],
              (value) {
                setState(() => _videoQuality = value!);
              },
            ),
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Storage section
            _buildSectionTitle('Storage'),
            _buildMenuItem(
              'Clear Cache',
              'Free up space by clearing cached data',
              onTap: () => _showClearCacheDialog(),
            ),
            _buildMenuItem(
              'Download Location',
              'Internal Storage',
              onTap: () {},
            ),
            
            const SizedBox(height: AppThemes.spaceXl),
            
            // Privacy section
            _buildSectionTitle('Privacy'),
            _buildMenuItem(
              'Clear Watch History',
              'Remove all watch history',
              onTap: () => _showClearHistoryDialog(),
            ),
            _buildMenuItem(
              'Clear Search History',
              'Remove all search queries',
              onTap: () {},
            ),
            
            const SizedBox(height: AppThemes.spaceXxl),
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
    final themes = [
      ('wakuwaku_dark', 'WakuWaku Dark', const Color(0xFF1B1919)),
      ('wakuwaku_light', 'WakuWaku Light', const Color(0xFFEFECEC)),
      ('cyberpunk', 'Cyberpunk', const Color(0xFFFF00FF)),
      ('ocean', 'Ocean', const Color(0xFF0EA5E9)),
      ('forest', 'Forest', const Color(0xFF10B981)),
      ('sunset', 'Sunset', const Color(0xFFF97316)),
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
              final isSelected = _selectedTheme == theme.$1;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTheme = theme.$1);
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppThemes.spaceMd,
              vertical: AppThemes.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppThemes.darkBackground,
              borderRadius: BorderRadius.circular(AppThemes.radiusSmall),
            ),
            child: DropdownButton<String>(
              value: value,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              dropdownColor: AppThemes.darkSurface,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withOpacity(0.5),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
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
