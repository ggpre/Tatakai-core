import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/models/user.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

// Favorites state
class FavoritesState {
  final List<Favorite> items;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    List<Favorite>? items,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final SupabaseService _supabaseService;

  FavoritesNotifier(this._supabaseService) : super(const FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _supabaseService.getFavorites(user.id);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToFavorites({
    required String animeId,
    required String animeName,
    required String animePoster,
  }) async {
    if (!_supabaseService.isAuthenticated) return;

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      await _supabaseService.addToFavorites(
        userId: user.id,
        animeId: animeId,
        animeName: animeName,
        animePoster: animePoster,
      );
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromFavorites(String animeId) async {
    if (!_supabaseService.isAuthenticated) return;

    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      await _supabaseService.removeFromFavorites(user.id, animeId);
      await loadFavorites();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  bool isFavorite(String animeId) {
    return state.items.any((item) => item.animeId == animeId);
  }

  Future<void> toggleFavorite(String animeId, String animeName, String? animePoster) async {
    if (isFavorite(animeId)) {
      await removeFromFavorites(animeId);
    } else {
      await addToFavorites(
        animeId: animeId,
        animeName: animeName,
        animePoster: animePoster ?? '',
      );
    }
  }
}

// Providers
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return FavoritesNotifier(supabaseService);
});

final favoritesItemsProvider = Provider<List<Favorite>>((ref) {
  return ref.watch(favoritesProvider).items;
});