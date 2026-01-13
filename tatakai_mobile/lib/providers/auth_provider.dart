import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/services/notification_service.dart';
import 'package:tatakai_mobile/models/user.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(const AuthState()) {
    _initialize();
  }

  void _initialize() {
    // Listen to auth state changes
    _supabaseService.client.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session?.user != null) {
        final user = UserModel.fromSupabaseUser(session!.user!);
        state = state.copyWith(user: user, isLoading: false, error: null);
        // Sync FCM token on auth change
        await _syncFCMToken(user.id);
      } else {
        state = const AuthState();
      }
    });
  }
  
  Future<void> _syncFCMToken(String userId) async {
    // FCM token sync disabled - 'fcm_token' column needs to be added to Supabase profiles table
    // To enable: ALTER TABLE profiles ADD COLUMN fcm_token TEXT;
    /*
    try {
      final token = NotificationService().fcmToken;
      if (token != null) {
        await _supabaseService.saveFCMToken(userId, token);
        print('FCM token synced to Supabase');
      }
    } catch (e) {
      print('Failed to sync FCM token: $e');
    }
    */
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final user = UserModel.fromSupabaseUser(response.user!);
        state = state.copyWith(user: user, isLoading: false);
        await _syncFCMToken(user.id);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password, {String? username}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      if (response.user != null) {
        final user = UserModel.fromSupabaseUser(response.user!);
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Future<void> signInWithGoogle() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   try {
  //     await _supabaseService.signInWithOAuth(OAuthProvider.google);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }

  // Future<void> signInWithApple() async {
  //   state = state.copyWith(isLoading: true, error: null);
  //   try {
  //     await _supabaseService.signInWithOAuth(OAuthProvider.apple);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _supabaseService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Providers


final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).user != null;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});