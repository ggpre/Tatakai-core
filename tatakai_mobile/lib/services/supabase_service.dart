import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotrue/gotrue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tatakai_mobile/models/comment.dart';
import 'package:tatakai_mobile/models/playlist.dart';
import 'package:tatakai_mobile/config/env.dart';
import 'package:tatakai_mobile/models/user.dart';

class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;
  
  SupabaseService._();
  
  static SupabaseService get instance {
    if (_instance == null) {
      throw Exception('SupabaseService not initialized. Call getInstance() first.');
    }
    return _instance!;
  }
  
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
  
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(provider);
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
        .eq('user_id', userId)
        .maybeSingle();
    
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
  
  Future<void> saveFCMToken(String userId, String token) async {
    await _client
        .from('profiles')
        .update({
          'fcm_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  Future<void> updateProfileAvatar(String userId, String avatarUrl) async {
    await _client.from('profiles').update({
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }

  Future<void> updateProfileBanner(String userId, String bannerUrl) async {
    await _client.from('profiles').update({
      'banner_url': bannerUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
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

  Future<void> removeWatchHistory(String userId, String animeId, String episodeId) async {
    await _client
        .from('watch_history')
        .delete()
        .eq('user_id', userId)
        .eq('anime_id', animeId)
        .eq('episode_id', episodeId);
  }

  // Comments
  Future<List<Comment>> getComments(String animeId, {int limit = 50}) async {
    final response = await _client
      .from('comments')
      .select()
      .eq('anime_id', animeId)
      .order('created_at', ascending: false)
      .limit(limit);

    return (response as List).map((c) => Comment.fromJson(c)).toList();
  }

  Future<void> postComment({
    required String userId,
    required String username,
    required String animeId,
    required String content,
  }) async {
    await _client.from('comments').insert({
      'user_id': userId,
      'username': username,
      'anime_id': animeId,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Recent comments (feed for community)
  Future<List<Comment>> getRecentComments({int limit = 25}) async {
    final response = await _client
        .from('comments')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((c) => Comment.fromJson(c)).toList();
  }

  // Playlists
  Future<List<Playlist>> getPlaylists(String userId) async {
    final response = await _client
        .from('playlists')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((p) => Playlist.fromJson(p)).toList();
  }

  Future<void> createPlaylist(String userId, String name, {String? description}) async {
    await _client.from('playlists').insert({
      'user_id': userId,
      'name': name,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _client.from('playlists').delete().eq('id', playlistId);
  }

  Future<List<PlaylistItem>> getPlaylistItems(String playlistId) async {
    final response = await _client
        .from('playlist_items')
        .select()
        .eq('playlist_id', playlistId)
        .order('added_at', ascending: false);

    return (response as List).map((i) => PlaylistItem.fromJson(i)).toList();
  }

  Future<void> addToPlaylist(String playlistId, String animeId, String animeName, {String? animePoster}) async {
    await _client.from('playlist_items').insert({
      'playlist_id': playlistId,
      'anime_id': animeId,
      'anime_name': animeName,
      'anime_poster': animePoster,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFromPlaylist(String playlistId, String animeId) async {
    await _client
        .from('playlist_items')
        .delete()
        .eq('playlist_id', playlistId)
        .eq('anime_id', animeId);
  }  
  Future<WatchHistory?> getLastWatchedEpisode(String userId, String animeId) async {
    final response = await _client
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .eq('anime_id', animeId)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response != null) {
      return WatchHistory.fromJson(response);
    }
    return null;
  }
  
  // Favorites
  // Watchlist (formerly Favorites)
  Future<void> addToFavorites({
    required String userId,
    required String animeId,
    required String animeName,
    String? animePoster,
  }) async {
    // Map 'Add to Favorites' to 'Plan to Watch' in watchlist
    await _client.from('watchlist').upsert({
      'user_id': userId,
      'anime_id': animeId,
      'anime_name': animeName,
      'anime_poster': animePoster,
      'status': 'plan_to_watch',
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id, anime_id');
  }
  
  Future<void> removeFromFavorites(String userId, String animeId) async {
    await _client
        .from('watchlist')
        .delete()
        .eq('user_id', userId)
        .eq('anime_id', animeId);
  }
  
  Future<List<Favorite>> getFavorites(String userId) async {
    final response = await _client
        .from('watchlist')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    
    return (response as List)
        .map((item) => Favorite.fromWatchlist(WatchlistItem.fromJson(item)))
        .toList();
  }
  
  Future<bool> isFavorite(String userId, String animeId) async {
    final response = await _client
        .from('watchlist')
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
          table: 'watchlist', // Fixed: use watchlist
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Only notify if status is 'plan_to_watch' (mapped to Favorites)
            // or if it was just deleted? 
            // For simplicity, we might just reload the list on any change
            // But here we try to map it.
            if (payload.newRecord != null) {
              final item = WatchlistItem.fromJson(payload.newRecord!);
              // Logic check: if we consider "Favorites" as "Plan to Watch"
              if (item.status == 'plan_to_watch') {
                 onUpdate(Favorite.fromWatchlist(item));
              }
            }
          },
        )
        .subscribe();
  }

  Future<Map<String, int>> getProfileStats(String userId) async {
    final response = await _client
        .from('watchlist')
        .select('status');
        // .eq('user_id', userId); // filtered by RLS usually, but explicit is better
        // Wait, .select('status').eq...
    
    // Supabase count is better
    // But doing it in one query:
    final data = await _client
        .from('watchlist')
        .select('status')
        .eq('user_id', userId);
        
    final stats = <String, int>{
      'watching': 0,
      'completed': 0,
      'on_hold': 0,
      'dropped': 0,
      'plan_to_watch': 0,
    };
    
    for (var item in data as List) {
      final status = item['status'] as String? ?? 'plan_to_watch';
      stats[status] = (stats[status] ?? 0) + 1;
    }
    
    return stats;
  }

  Future<Map<String, int>> getAnimeStats(String animeId) async {
    // Parallel fetching for performance
    final watchlistCountFuture = _client
        .from('watchlist')
        .count(CountOption.exact)
        .eq('anime_id', animeId);

    // Comments
    final commentsCountFuture = _client
        .from('comments')
        .count(CountOption.exact)
        .eq('anime_id', animeId);

    final results = await Future.wait([
      watchlistCountFuture,
      commentsCountFuture,
    ]);

    return {
      'saved': results[0], // Using watchlist count as "Saved"
      'comments': results[1],
      'likes': 0, 
      'views': 0, 
      'lists': 0,
    };
  }
}


final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});
