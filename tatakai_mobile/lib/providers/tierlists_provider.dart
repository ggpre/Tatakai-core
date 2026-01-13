import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';

// Tier List Model
class TierList {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isPublic;
  final Map<String, List<TierItem>> tiers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatar;
  final int likes;

  TierList({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isPublic = false,
    required this.tiers,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
    this.likes = 0,
  });

  factory TierList.fromJson(Map<String, dynamic> json) {
    // Parse tiers data
    Map<String, List<TierItem>> parsedTiers = {};
    if (json['tiers'] != null) {
      final tiersData = json['tiers'] as Map<String, dynamic>;
      tiersData.forEach((key, value) {
        if (value is List) {
          parsedTiers[key] = value
              .map((item) => TierItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      });
    }

    return TierList(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      tiers: parsedTiers,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
      authorName: json['profiles']?['display_name'] as String? ?? json['profiles']?['username'] as String?,
      authorAvatar: json['profiles']?['avatar_url'] as String?,
      likes: json['likes_count'] as int? ?? 0,
    );
  }
}

class TierItem {
  final String animeId;
  final String animeName;
  final String animePoster;

  TierItem({
    required this.animeId,
    required this.animeName,
    required this.animePoster,
  });

  factory TierItem.fromJson(Map<String, dynamic> json) {
    return TierItem(
      animeId: json['anime_id'] as String? ?? '',
      animeName: json['anime_name'] as String? ?? '',
      animePoster: json['anime_poster'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'anime_id': animeId,
    'anime_name': animeName,
    'anime_poster': animePoster,
  };
}

// State
class TierListsState {
  final List<TierList> publicTierLists;
  final List<TierList> myTierLists;
  final bool isLoading;
  final String? error;

  TierListsState({
    this.publicTierLists = const [],
    this.myTierLists = const [],
    this.isLoading = false,
    this.error,
  });

  TierListsState copyWith({
    List<TierList>? publicTierLists,
    List<TierList>? myTierLists,
    bool? isLoading,
    String? error,
  }) {
    return TierListsState(
      publicTierLists: publicTierLists ?? this.publicTierLists,
      myTierLists: myTierLists ?? this.myTierLists,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class TierListsNotifier extends StateNotifier<TierListsState> {
  final SupabaseService _supabase;

  TierListsNotifier(this._supabase) : super(TierListsState()) {
    fetchTierLists();
  }

  Future<void> fetchTierLists() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Fetch public tier lists
      final publicResponse = await _supabase.client
          .from('tier_lists')
          .select('*')
          .eq('is_public', true)
          .order('updated_at', ascending: false)
          .limit(20);

      List<TierList> publicLists = [];
      if (publicResponse is List) {
        // Collect user IDs to fetch profiles
        final userIds = publicResponse.map((json) => json['user_id'] as String).toSet().toList();
        
        // Fetch profiles
        Map<String, Map<String, dynamic>> profileMap = {};
        if (userIds.isNotEmpty) {
          final profilesResponse = await _supabase.client
              .from('profiles')
              .select('user_id, display_name, username, avatar_url')
              .filter('user_id', 'in', userIds); // Web uses user_id
              
          if (profilesResponse is List) {
           for (var p in profilesResponse) {
             profileMap[p['user_id'] as String] = p as Map<String, dynamic>;
           }
          }
        }

        // Merge profiles into tier lists
        publicLists = publicResponse.map((json) {
          final userId = json['user_id'] as String;
          final profile = profileMap[userId];
          // Manually inject profile data for fromJson
          if (profile != null) {
            json['profiles'] = profile;
          }
          return TierList.fromJson(json as Map<String, dynamic>);
        }).toList();
      }

      // Fetch my tier lists if logged in
      List<TierList> myLists = [];
      final user = _supabase.currentUser;
      if (user != null) {
        final myResponse = await _supabase.client
            .from('tier_lists')
            .select('*')
            .eq('user_id', user.id)
            .order('updated_at', ascending: false);

        if (myResponse is List) {
           // Fetch my profile once
           final myProfileResponse = await _supabase.client
               .from('profiles')
               .select('user_id, display_name, username, avatar_url')
               .eq('user_id', user.id)
               .maybeSingle();

            final myProfile = myProfileResponse as Map<String, dynamic>?;

            myLists = myResponse.map((json) {
              if (myProfile != null) {
                json['profiles'] = myProfile;
              }
              return TierList.fromJson(json as Map<String, dynamic>);
            }).toList();
        }
      }

      state = state.copyWith(
        publicTierLists: publicLists,
        myTierLists: myLists,
        isLoading: false,
      );
    } catch (e) {
      print('Error fetching tier lists: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tier lists: $e',
      );
    }
  }

  Future<void> createTierList(String title, {String? description}) async {
    final user = _supabase.currentUser;
    if (user == null) return;

    try {
      await _supabase.client.from('tier_lists').insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'is_public': false,
        'tiers': {'S': [], 'A': [], 'B': [], 'C': [], 'D': []},
      });
      await fetchTierLists();
    } catch (e) {
      print('Error creating tier list: $e');
    }
  }

  Future<void> deleteTierList(String tierListId) async {
    try {
      await _supabase.client
          .from('tier_lists')
          .delete()
          .eq('id', tierListId);
      await fetchTierLists();
    } catch (e) {
      print('Error deleting tier list: $e');
    }
  }
}

// Provider
final tierListsProvider = StateNotifierProvider<TierListsNotifier, TierListsState>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return TierListsNotifier(supabase);
});
