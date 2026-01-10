import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tatakai_mobile/screens/home/home_screen.dart';
import 'package:tatakai_mobile/screens/anime/anime_detail_screen.dart';
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
import 'package:tatakai_mobile/widgets/layout/main_scaffold.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
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
