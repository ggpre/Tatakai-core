import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tatakai_mobile/models/playlist.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

class PlaylistsState {
  final List<Playlist> playlists;
  final bool isLoading;
  final String? error;

  const PlaylistsState({
    this.playlists = const [],
    this.isLoading = false,
    this.error,
  });

  PlaylistsState copyWith({
    List<Playlist>? playlists,
    bool? isLoading,
    String? error,
  }) {
    return PlaylistsState(
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class PlaylistsNotifier extends StateNotifier<PlaylistsState> {
  final SupabaseService _supabaseService;

  PlaylistsNotifier(this._supabaseService) : super(const PlaylistsState()) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _supabaseService.getPlaylists(user.id);
      state = state.copyWith(playlists: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseService.createPlaylist(user.id, name, description: description);
      await loadPlaylists();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseService.deletePlaylist(playlistId);
      await loadPlaylists();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<PlaylistItem>> getPlaylistItems(String playlistId) async {
    try {
      return await _supabaseService.getPlaylistItems(playlistId);
    } catch (e) {
      return [];
    }
  }

  Future<void> addToPlaylist(String playlistId, String animeId, String animeName, {String? animePoster}) async {
    try {
      await _supabaseService.addToPlaylist(playlistId, animeId, animeName, animePoster: animePoster);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String animeId) async {
    try {
      await _supabaseService.removeFromPlaylist(playlistId, animeId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final playlistsProvider = StateNotifierProvider<PlaylistsNotifier, PlaylistsState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return PlaylistsNotifier(supabaseService);
});

final playlistsItemsProvider = Provider<List<Playlist>>((ref) {
  return ref.watch(playlistsProvider).playlists;
});