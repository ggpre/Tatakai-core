import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tatakai_mobile/config/env.dart';
import 'package:tatakai_mobile/models/user.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;
  
  SupabaseService._();
  
  static Future<SupabaseService> getInstance() async {
    if (_instance == null) {
      _instance = SupabaseService._();
      await _instance!._initialize();
    }
    return _instance!;
  }
  
  Future<void> _initialize() async {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      anonKey: Config.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
  
  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  // Authentication
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: username != null ? {'username': username} : null,
    );
    
    // Create user profile
    if (response.user != null) {
      await _createUserProfile(response.user!.id, email, username);
    }
    
    return response;
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  Future<AuthResponse> signInWithOAuth(Provider provider) async {
    return await _client.auth.signInWithOAuth(provider);
  }
  
  // User Profile
  Future<void> _createUserProfile(String userId, String email, String? username) async {
    await _client.from('profiles').insert({
      'id': userId,
      'email': email,
      'username': username,
      'role': 'user',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  
  Future<UserProfile?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    if (response != null) {
      return UserProfile.fromJson(response);
    }
    return null;
  }
  
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    await _client
        .from('profiles')
        .update({
          ...updates,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }
  
  // Watch History
  Future<void> saveWatchHistory({
    required String userId,
    required String animeId,
    required String animeName,
    String? animePoster,
    required int episodeNumber,
    required String episodeId,
    String? episodeTitle,
    required int progress,
    required int duration,
  }) async {
    await _client.from('watch_history').upsert({
      'user_id': userId,
      'anime_id': animeId,
      'anime_name': animeName,
      'anime_poster': animePoster,
      'episode_number': episodeNumber,
      'episode_id': episodeId,
      'episode_title': episodeTitle,
      'progress': progress,
      'duration': duration,
      'watched_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,anime_id,episode_id');
  }
  
  Future<List<WatchHistory>> getWatchHistory(String userId, {int limit = 50}) async {
    final response = await _client
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(limit);
    
    return (response as List)
        .map((item) => WatchHistory.fromJson(item))
        .toList();
  }
  
  Future<WatchHistory?> getLastWatchedEpisode(String userId, String animeId) async {
    final response = await _client
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .eq('anime_id', animeId)
        .order('episode_number', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response != null) {
      return WatchHistory.fromJson(response);
    }
    return null;
  }
  
  // Favorites
  Future<void> addToFavorites({
    required String userId,
    required String animeId,
    required String animeName,
    String? animePoster,
  }) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'anime_id': animeId,
      'anime_name': animeName,
      'anime_poster': animePoster,
      'added_at': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> removeFromFavorites(String userId, String animeId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('anime_id', animeId);
  }
  
  Future<List<Favorite>> getFavorites(String userId) async {
    final response = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .order('added_at', ascending: false);
    
    return (response as List)
        .map((item) => Favorite.fromJson(item))
        .toList();
  }
  
  Future<bool> isFavorite(String userId, String animeId) async {
    final response = await _client
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('anime_id', animeId)
        .maybeSingle();
    
    return response != null;
  }
  
  // Preferences
  Future<void> savePreferences(String userId, UserPreferences preferences) async {
    await _client
        .from('profiles')
        .update({
          'preferences': preferences.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId);
  }
  
  Future<UserPreferences> getPreferences(String userId) async {
    final response = await _client
        .from('profiles')
        .select('preferences')
        .eq('id', userId)
        .single();
    
    if (response != null && response['preferences'] != null) {
      return UserPreferences.fromJson(response['preferences']);
    }
    return UserPreferences();
  }
  
  // Analytics
  Future<void> trackPageView({
    required String userId,
    required String page,
    Map<String, dynamic>? metadata,
  }) async {
    if (!Config.enableAnalytics) return;
    
    await _client.from('analytics_events').insert({
      'user_id': userId,
      'event_type': 'page_view',
      'page': page,
      'metadata': metadata,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> trackWatchSession({
    required String userId,
    required String animeId,
    required String episodeId,
    required int duration,
    Map<String, dynamic>? metadata,
  }) async {
    if (!Config.enableAnalytics) return;
    
    await _client.from('analytics_events').insert({
      'user_id': userId,
      'event_type': 'watch_session',
      'anime_id': animeId,
      'episode_id': episodeId,
      'duration': duration,
      'metadata': metadata,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
  
  // Realtime subscriptions
  RealtimeChannel subscribeToWatchHistory(String userId, void Function(WatchHistory) onUpdate) {
    return _client
        .channel('watch_history:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'watch_history',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(WatchHistory.fromJson(payload.newRecord!));
            }
          },
        )
        .subscribe();
  }
  
  RealtimeChannel subscribeToFavorites(String userId, void Function(Favorite) onUpdate) {
    return _client
        .channel('favorites:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'favorites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord != null) {
              onUpdate(Favorite.fromJson(payload.newRecord!));
            }
          },
        )
        .subscribe();
  }
}
