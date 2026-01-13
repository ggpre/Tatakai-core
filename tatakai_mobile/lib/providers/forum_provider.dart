import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';

// Forum Post Model
class ForumPost {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? imageUrl;
  final String? animeId;
  final String? animeName;
  final String? animePoster;
  final String? flair;
  final bool isSpoiler;
  final bool isPinned;
  final bool? isApproved;
  final int upvotes;
  final int downvotes;
  final int views;
  final int commentsCount;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatar;
  final int userVote; // 1 (up), -1 (down), 0 (none)

  ForumPost({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.animeId,
    this.animeName,
    this.animePoster,
    this.flair,
    this.isSpoiler = false,
    this.isPinned = false,
    this.isApproved,
    this.upvotes = 0,
    this.downvotes = 0,
    this.views = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.authorName,
    this.authorAvatar,
    this.userVote = 0,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      animeId: json['anime_id'] as String?,
      animeName: json['anime_name'] as String?,
      animePoster: json['anime_poster'] as String?,
      flair: json['flair'] as String?,
      isSpoiler: json['is_spoiler'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      isApproved: json['is_approved'] as bool?,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      views: json['views_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      authorName: json['profiles']?['display_name'] as String? ?? json['profiles']?['username'] as String?,
      authorAvatar: json['profiles']?['avatar_url'] as String?,
      userVote: 0, // Need separate join/query to get this if needed
    );
  }
}

// Forum State
class ForumState {
  final List<ForumPost> posts;
  final bool isLoading;
  final String? error;
  final String sort; // 'hot', 'new', 'top'

  ForumState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.sort = 'hot',
  });

  ForumState copyWith({
    List<ForumPost>? posts,
    bool? isLoading,
    String? error,
    String? sort,
  }) {
    return ForumState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sort: sort ?? this.sort,
    );
  }
}

// Forum Notifier
class ForumNotifier extends StateNotifier<ForumState> {
  final SupabaseService _supabase;

  ForumNotifier(this._supabase) : super(ForumState()) {
    fetchPosts();
  }

  Future<void> fetchPosts({String? sortBy}) async {
    final sort = sortBy ?? state.sort;
    state = state.copyWith(isLoading: true, error: null, sort: sort);

    try {
      var query = _supabase.client
          .from('forum_posts')
          .select('*')
          .eq('is_approved', true);

      // Apply sorting
      if (sort == 'new') {
        query = query.order('created_at', ascending: false);
      } else if (sort == 'top') {
        query = query.order('upvotes', ascending: false);
      } else {
        // Hot sorting logic would be more complex, falling back to recent for now or handling custom logic
        // Ideally DB function, but for now just use created_at desc
        query = query.order('created_at', ascending: false);
      }

      final response = await query.limit(20);

      List<ForumPost> posts = [];
      if (response is List) {
        // Collect user IDs
        final userIds = response.map((json) => json['user_id'] as String).toSet().toList();
        
        // Fetch profiles
        Map<String, Map<String, dynamic>> profileMap = {};
        if (userIds.isNotEmpty) {
          final profilesResponse = await _supabase.client
              .from('profiles')
              .select('user_id, display_name, username, avatar_url')
              .filter('user_id', 'in', userIds);
              
          if (profilesResponse is List) {
             for (var p in profilesResponse) {
               profileMap[p['user_id'] as String] = p as Map<String, dynamic>;
             }
          }
        }

        posts = response.map((json) {
          final userId = json['user_id'] as String;
          final profile = profileMap[userId];
          
          if (profile != null) {
            json['profiles'] = profile;
          }
          
          // Web schema has comments_count column
          // If comments_count is not in response, default to 0
          
          return ForumPost.fromJson(json as Map<String, dynamic>);
        }).toList();
      }

      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      print('Error fetching forum posts: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to load posts: $e');
    }
  }

  Future<void> createPost(String title, String content, {String? animeId, String? animeName, String? animePoster, String? flair, bool isSpoiler = false}) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    try {
      await _supabase.client.from('forum_posts').insert({
        'user_id': user.id,
        'title': title,
        'content': content,
        'anime_id': animeId,
        'anime_name': animeName,
        'anime_poster': animePoster,
        'flair': flair,
        'is_spoiler': isSpoiler,
        // is_approved usually defaults to false/null depending on RLS. Assumed auto-approve or pending.
      });
      fetchPosts();
    } catch (e) {
      print('Error creating post: $e');
      throw e;
    }
  }
}

// Provider
final forumProvider = StateNotifierProvider<ForumNotifier, ForumState>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return ForumNotifier(supabase);
});
