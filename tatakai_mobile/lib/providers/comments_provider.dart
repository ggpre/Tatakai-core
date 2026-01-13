import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tatakai_mobile/models/comment.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final SupabaseService _supabaseService;
  final String animeId;

  CommentsNotifier(this._supabaseService, this.animeId) : super(const CommentsState()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final comments = await _supabaseService.getComments(animeId);
      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> postComment(String content, String username) async {
    final user = _supabaseService.currentUser;
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _supabaseService.postComment(
        userId: user.id,
        username: username,
        animeId: animeId,
        content: content,
      );
      await loadComments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final commentsProvider = StateNotifierProvider.family<CommentsNotifier, CommentsState, String>((ref, animeId) {
  final supabase = ref.watch(supabaseServiceProvider);
  return CommentsNotifier(supabase, animeId);
});