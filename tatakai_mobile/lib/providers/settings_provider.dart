import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatakai_mobile/models/user.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';

class SettingsNotifier extends StateNotifier<UserPreferences> {
  final SupabaseService _supabaseService;
  late SharedPreferences _prefs;
  bool _initialized = false;

  SettingsNotifier(this._supabaseService) 
      : super(UserPreferences(
          theme: 'wakuwaku_dark',
          videoQuality: 'Auto',
          playbackSpeed: 1.0,
          autoSkipIntro: true,
          autoSkipOutro: true,
          autoPlayNext: true,
          subtitleLanguage: 'English',
          subtitleSize: 16.0,
          subtitleColor: 'White',
          enableAnalytics: true,
          enableNotifications: true,
          downloadOnWifiOnly: true,
        )) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load local prefs
    final jsonString = _prefs.getString('user_preferences');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        state = UserPreferences.fromJson(json);
      } catch (e) {
        print('Error loading settings: $e');
      }
    }
    
    _initialized = true;

    // Sync with Supabase if logged in
    final user = _supabaseService.currentUser;
    if (user != null) {
      await _fetchRemotePreferences(user.id);
    }
  }

  Future<void> _fetchRemotePreferences(String userId) async {
    try {
      final profile = await _supabaseService.getUserProfile(userId);
      if (profile != null && profile.preferences != null) {
        final remotePrefs = UserPreferences.fromJson(profile.preferences!);
        // Merge strategy: Remote wins if newer? Or just overwrite local.
        // For simplicity, overwrite local with remote on init.
        state = remotePrefs;
        _saveLocal();
      }
    } catch (e) {
      print('Error fetching remote preferences: $e');
    }
  }

  Future<void> _saveLocal() async {
    if (!_initialized) return;
    await _prefs.setString('user_preferences', jsonEncode(state.toJson()));
  }

  Future<void> _syncRemote() async {
    final user = _supabaseService.currentUser;
    if (user != null) {
      try {
        await _supabaseService.updateUserProfile(user.id, {
          'preferences': state.toJson(),
        });
      } catch (e) {
        print('Error syncing preferences: $e');
      }
    }
  }

  Future<void> updateSettings(UserPreferences newSettings) async {
    state = newSettings;
    await _saveLocal();
    _syncRemote(); // Fire and forget
  }

  void setTheme(String theme) {
    // Only 'wakuwaku_dark' supported fully for now, but keeping field
    updateSettings(state.copyWith(theme: theme));
  }
  
  void setVideoQuality(String quality) {
    updateSettings(state.copyWith(videoQuality: quality));
  }
  
  void setPlaybackSpeed(double speed) {
    updateSettings(state.copyWith(playbackSpeed: speed));
  }

  void toggleAutoSkipIntro(bool value) {
    updateSettings(state.copyWith(autoSkipIntro: value));
  }
  
  void toggleAutoSkipOutro(bool value) {
    updateSettings(state.copyWith(autoSkipOutro: value));
  }

  void toggleAutoPlayNext(bool value) {
    updateSettings(state.copyWith(autoPlayNext: value));
  }
  
  void setSubtitleLanguage(String language) {
    updateSettings(state.copyWith(subtitleLanguage: language));
  }

  void toggleNotifications(bool value) {
    updateSettings(state.copyWith(enableNotifications: value));
  }
  
  void toggleDownloadOnWifiOnly(bool value) {
    updateSettings(state.copyWith(downloadOnWifiOnly: value));
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserPreferences>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SettingsNotifier(supabaseService);
});
