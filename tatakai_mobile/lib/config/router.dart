import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/screens/home/home_screen.dart';
import 'package:tatakai_mobile/screens/anime/anime_detail_screen.dart';
import 'package:tatakai_mobile/screens/anime/episodes_screen.dart';
import 'package:tatakai_mobile/screens/watch/watch_screen.dart';
import 'package:tatakai_mobile/screens/search/search_screen.dart';
import 'package:tatakai_mobile/screens/genre/genre_screen.dart';
import 'package:tatakai_mobile/screens/favorites/favorites_screen.dart';
import 'package:tatakai_mobile/screens/auth/auth_screen.dart';
import 'package:tatakai_mobile/screens/profile/profile_screen.dart';
import 'package:tatakai_mobile/screens/settings/settings_screen.dart';
import 'package:tatakai_mobile/screens/downloads/downloads_screen.dart';
import 'package:tatakai_mobile/screens/playlists/playlists_screen.dart';
import 'package:tatakai_mobile/screens/tierlists/tierlists_screen.dart';
import 'package:tatakai_mobile/screens/community/community_screen.dart';
import 'package:tatakai_mobile/screens/status/status_screen.dart';
import 'package:tatakai_mobile/screens/error_screens/notfound_screen.dart';
import 'package:tatakai_mobile/screens/error_screens/maintenance_screen.dart';
import 'package:tatakai_mobile/screens/error_screens/banned_screen.dart';
import 'package:tatakai_mobile/screens/error_screens/error_screen.dart';
import 'package:tatakai_mobile/screens/admin/admin_screen.dart';
import 'package:tatakai_mobile/screens/auth/reset_password_screen.dart';
import 'package:tatakai_mobile/screens/static/terms_screen.dart';
import 'package:tatakai_mobile/screens/static/privacy_screen.dart';
import 'package:tatakai_mobile/screens/static/dmca_screen.dart';
import 'package:tatakai_mobile/screens/onboarding/onboarding_screen.dart';
import 'package:tatakai_mobile/widgets/layout/main_scaffold.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

// Auth-aware router
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final isLoggedIn = ref.read(isAuthenticatedProvider);
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isAuth = state.matchedLocation == '/auth';
      final isResetPassword = state.matchedLocation == '/reset-password';
      
      // Public routes that don't require auth
      final publicPaths = ['/', '/search', '/anime', '/genre', '/watch'];
      final isPublicRoute = publicPaths.any((p) => state.matchedLocation.startsWith(p));
      
      // Protected routes
      final protectedPaths = ['/profile', '/downloads', '/favorites', '/playlists', '/tierlists', '/admin', '/settings'];
      final isProtectedRoute = protectedPaths.any((p) => state.matchedLocation.startsWith(p));
      
      // If not logged in and trying to access protected route, go to onboarding
      if (!isLoggedIn && isProtectedRoute) {
        return '/onboarding';
      }
      
      // If logged in and on onboarding/auth, redirect to home
      if (isLoggedIn && (isOnboarding || isAuth)) {
        return '/';
      }
      
      return null; // No redirect
    },
    routes: [
      // Onboarding route (no shell)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: '/downloads',
            name: 'downloads',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DownloadsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      
      // Routes without bottom navigation
      GoRoute(
        path: '/anime/:id',
        name: 'anime_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AnimeDetailScreen(animeId: id);
        },
      ),
      GoRoute(
        path: '/anime/:id/episodes',
        name: 'anime_episodes',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EpisodesScreen(animeId: id);
        },
      ),
      GoRoute(
        path: '/watch/:episodeId',
        name: 'watch',
        builder: (context, state) {
          final episodeId = state.pathParameters['episodeId']!;
          final animeId = state.uri.queryParameters['animeId'];
          final episodeNumber = state.uri.queryParameters['episodeNumber'];
          return WatchScreen(
            episodeId: episodeId,
            animeId: animeId,
            episodeNumber: episodeNumber != null 
                ? int.tryParse(episodeNumber) 
                : null,
          );
        },
      ),
      GoRoute(
        path: '/genre/:genre',
        name: 'genre',
        builder: (context, state) {
          final genre = state.pathParameters['genre']!;
          return GenreScreen(genre: genre);
        },
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/playlists',
        name: 'playlists',
        builder: (context, state) => const PlaylistsScreen(),
      ),
      GoRoute(
        path: '/tierlists',
        name: 'tierlists',
        builder: (context, state) => const TierListsScreen(),
      ),
      GoRoute(
        path: '/community',
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: '/status',
        name: 'status',
        builder: (context, state) => const StatusScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/dmca',
        name: 'dmca',
        builder: (context, state) => const DMCAScreen(),
      ),
      
      // Error screens
      GoRoute(
        path: '/maintenance',
        name: 'maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/banned',
        name: 'banned',
        builder: (context, state) => const BannedScreen(),
      ),
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) {
          final message = state.uri.queryParameters['message'];
          return ErrorScreen(message: message);
        },
      ),
    ],
  );
}
