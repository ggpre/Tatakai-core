import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/models/user.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

// Watch history state
class WatchHistoryState {
  final List<WatchHistory> items;
  final bool isLoading;
  final String? error;

  const WatchHistoryState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  WatchHistoryState copyWith({
    List<WatchHistory>? items,
    bool? isLoading,
    String? error,
  }) {
    return WatchHistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Watch history notifier
class WatchHistoryNotifier extends StateNotifier<WatchHistoryState> {
  final SupabaseService _supabaseService;

  WatchHistoryNotifier(this._supabaseService) : super(const WatchHistoryState()) {
    loadWatchHistory();
  }

  Future<void> loadWatchHistory() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _supabaseService.getWatchHistory(user.id);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToWatchHistory({
    required String animeId,
    required String episodeId,
    required int episodeNumber,
    required int progress,
    required int duration,
  }) async {
    if (!_supabaseService.isAuthenticated) return;

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      await _supabaseService.saveWatchHistory(
        userId: user.id,
        animeId: animeId,
        animeName: '',
        episodeId: episodeId,
        episodeNumber: episodeNumber,
        progress: progress,
        duration: duration,
      );

      // Reload history to get updated data
      await loadWatchHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromWatchHistory(String animeId, String episodeId) async {
    if (!_supabaseService.isAuthenticated) return;

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      await _supabaseService.removeWatchHistory(user.id, animeId, episodeId);
      await loadWatchHistory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  WatchHistory? getWatchProgress(String animeId, String episodeId) {
    try {
      return state.items.firstWhere((item) => item.animeId == animeId && item.episodeId == episodeId);
    } catch (e) {
      return null;
    }
  }
}

// Providers
final watchHistoryProvider = StateNotifierProvider<WatchHistoryNotifier, WatchHistoryState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return WatchHistoryNotifier(supabaseService);
});

final watchHistoryItemsProvider = Provider<List<WatchHistory>>((ref) {
  return ref.watch(watchHistoryProvider).items;
});

final continueWatchingProvider = Provider<List<WatchHistory>>((ref) {
  final items = ref.watch(watchHistoryItemsProvider);
  // Return items with progress > 0 and < 90% (not completed)
  return items.where((item) {
    if (item.duration == 0) return false;
    final progressPercent = (item.progress / item.duration) * 100;
    return progressPercent > 5 && progressPercent < 90;
  }).toList();
});