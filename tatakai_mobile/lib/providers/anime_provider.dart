import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tatakai_mobile/services/api_service.dart';
import 'package:tatakai_mobile/models/anime.dart';
import 'package:tatakai_mobile/models/episode_model.dart';

// Home data state
class HomeDataState {
  final HomeData? data;
  final bool isLoading;
  final String? error;

  const HomeDataState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  HomeDataState copyWith({
    HomeData? data,
    bool? isLoading,
    String? error,
  }) {
    return HomeDataState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Anime detail state
class AnimeDetailState {
  final AnimeInfoResponse? data;
  final bool isLoading;
  final String? error;

  const AnimeDetailState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  AnimeDetailState copyWith({
    AnimeInfoResponse? data,
    bool? isLoading,
    String? error,
  }) {
    return AnimeDetailState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Search state
class SearchState {
  final SearchResult? data;
  final List<AnimeCard> results;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String query;
  final int currentPage;
  final bool hasNextPage;

  const SearchState({
    this.data,
    this.results = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.query = '',
    this.currentPage = 1,
    this.hasNextPage = true,
  });

  SearchState copyWith({
    SearchResult? data,
    List<AnimeCard>? results,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? query,
    int? currentPage,
    bool? hasNextPage,
  }) {
    return SearchState(
      data: data ?? this.data,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

// Home data notifier
class HomeDataNotifier extends StateNotifier<HomeDataState> {
  final ApiService _apiService;

  HomeDataNotifier(this._apiService) : super(const HomeDataState()) {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.fetchHome();
      // Log summary of data for debugging
      print('[HomeDataNotifier] fetchHomeData success: spotlight=${data.spotlightAnimes.length} top10=${data.top10Animes.today.length} trending=${data.trendingAnimes.length}');
      if (data.spotlightAnimes.isNotEmpty) {
        print('[HomeDataNotifier] first spotlight: ${data.spotlightAnimes.first.name}');
      }
      state = state.copyWith(data: data, isLoading: false);
    } catch (e, st) {
      // Make fetch errors visible in logs for debugging
      print('[HomeDataNotifier] fetchHomeData failed: $e\n$st');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Anime detail notifier
class AnimeDetailNotifier extends StateNotifier<AnimeDetailState> {
  final ApiService _apiService;

  AnimeDetailNotifier(this._apiService) : super(const AnimeDetailState());

  Future<void> fetchAnimeDetail(String animeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.fetchAnimeInfo(animeId);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Search notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final ApiService _apiService;

  SearchNotifier(this._apiService) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true, 
      error: null, 
      query: query,
      results: [],
      currentPage: 1,
      hasNextPage: true,
    );
    
    try {
      final data = await _apiService.searchAnime(query, page: 1);
      state = state.copyWith(
        data: data, 
        results: data.animes,
        isLoading: false,
        hasNextPage: data.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasNextPage) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      final data = await _apiService.searchAnime(state.query, page: nextPage);
      state = state.copyWith(
        data: data,
        results: [...state.results, ...data.animes],
        currentPage: nextPage,
        isLoadingMore: false,
        hasNextPage: data.hasNextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void clearSearch() {
    state = const SearchState();
  }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final homeDataProvider = StateNotifierProvider<HomeDataNotifier, HomeDataState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return HomeDataNotifier(apiService);
});

final animeDetailProvider = StateNotifierProvider<AnimeDetailNotifier, AnimeDetailState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AnimeDetailNotifier(apiService);
});

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SearchNotifier(apiService);
});

// Convenience providers
final homeDataDataProvider = Provider<HomeData?>((ref) {
  return ref.watch(homeDataProvider).data;
});

final animeDetailDataProvider = Provider<AnimeInfoResponse?>((ref) {
  return ref.watch(animeDetailProvider).data;
});

final searchDataProvider = Provider<SearchResult?>((ref) {
  return ref.watch(searchProvider).data;
});

// Episodes state
class EpisodesState {
  final EpisodeList? data;
  final bool isLoading;
  final String? error;

  const EpisodesState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  EpisodesState copyWith({
    EpisodeList? data,
    bool? isLoading,
    String? error,
  }) {
    return EpisodesState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Episodes notifier
class EpisodesNotifier extends StateNotifier<EpisodesState> {
  final ApiService _apiService;
  final String animeId;

  EpisodesNotifier(this._apiService, this.animeId) : super(const EpisodesState()) {
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _apiService.fetchEpisodes(animeId);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Family provider for episodes
final episodesProvider = StateNotifierProvider.family<EpisodesNotifier, EpisodesState, String>((ref, animeId) {
  final apiService = ref.watch(apiServiceProvider);
  return EpisodesNotifier(apiService, animeId);
});