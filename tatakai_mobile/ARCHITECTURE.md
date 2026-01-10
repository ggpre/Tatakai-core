# Tatakai Mobile - Architecture Documentation

## 📐 Architecture Overview

The Tatakai mobile app follows **Clean Architecture** principles with a **feature-first** folder structure, using **Riverpod** for state management and **Go Router** for navigation.

## 🏗️ Architecture Layers

### 1. Presentation Layer
- **Screens**: UI pages/routes
- **Widgets**: Reusable UI components
- **Providers**: State management (Riverpod)

### 2. Domain Layer
- **Models**: Data classes and entities
- **Use Cases**: Business logic (handled by providers)

### 3. Data Layer
- **Services**: API clients, database access
- **Repositories**: Data source abstraction (implicit in services)

## 📊 Data Flow

```
User Interaction → Screen → Provider → Service → API/Database
                                ↓
                            State Update
                                ↓
                            UI Re-render
```

## 🔧 Core Technologies

### State Management: Riverpod
- **Provider**: Immutable state
- **StateNotifier**: Mutable state with actions
- **FutureProvider**: Async data fetching
- **StreamProvider**: Real-time updates

### Navigation: Go Router
- Declarative routing
- Deep linking support
- Type-safe navigation
- Shell routes for bottom navigation

### Local Storage
- **Hive**: Fast NoSQL database for offline storage
- **SharedPreferences**: Simple key-value storage
- **SQLite**: Complex queries and relationships

### Networking
- **Dio**: HTTP client with interceptors
- **Retrofit**: Type-safe REST client (code generation)

### Supabase Integration
- **Auth**: User authentication and session management
- **Database**: PostgreSQL with real-time subscriptions
- **Storage**: File uploads (profile pictures, etc.)
- **Edge Functions**: Video proxy, scrapers

### Firebase
- **Cloud Messaging**: Push notifications
- **Analytics**: User behavior tracking (optional)
- **Crashlytics**: Crash reporting

## 📁 Folder Structure Deep Dive

### `/lib/config/`
Configuration files that don't change at runtime:
- `env.dart`: API URLs, keys, feature flags
- `theme.dart`: 15+ theme definitions
- `router.dart`: Route definitions and navigation

### `/lib/models/`
Data models with JSON serialization:
- `anime.dart`: Anime-related models
- `episode_model.dart`: Episode and streaming data
- `user.dart`: User profile and preferences
- `download.dart`: Download tracking models

All models use `json_serializable` for automatic JSON parsing.

### `/lib/providers/`
Riverpod providers for state management:
- `auth_provider.dart`: Authentication state
- `anime_provider.dart`: Anime data fetching
- `watch_history_provider.dart`: Watch progress tracking
- `downloads_provider.dart`: Download queue management
- `notifications_provider.dart`: Notification handling
- `sync_provider.dart`: Cross-device synchronization

### `/lib/services/`
External integrations and data sources:
- `api_service.dart`: HiAnime API client
- `supabase_service.dart`: Supabase integration
- `download_service.dart`: File download logic
- `notification_service.dart`: FCM and local notifications
- `sync_service.dart`: Cloud sync orchestration

### `/lib/widgets/`
Reusable UI components:

**Common Widgets:**
- `anime_card.dart`: Anime thumbnail card
- `episode_list.dart`: Episode list item
- `video_player.dart`: Custom video player with controls
- `search_bar.dart`: Search input with suggestions

**Layout Widgets:**
- `main_scaffold.dart`: Bottom navigation wrapper
- `app_bar.dart`: Custom app bar with actions
- `bottom_nav.dart`: Bottom navigation bar

### `/lib/screens/`
Feature-based screen organization:

Each screen follows this pattern:
```dart
class ScreenName extends ConsumerStatefulWidget {
  // Constructor with required parameters
  
  @override
  ConsumerState<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends ConsumerState<ScreenName> {
  // State variables
  
  @override
  void initState() {
    super.initState();
    // Initialize data fetching
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for state
    final data = ref.watch(dataProvider);
    
    // Build UI
    return Scaffold(...);
  }
}
```

## 🔄 State Management Patterns

### 1. Authentication State
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(supabaseServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._supabase) : super(AuthState.initial());
  
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _supabase.signInWithEmail(email: email, password: password);
      state = state.copyWith(isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
```

### 2. Data Fetching
```dart
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.fetchHome();
});

// In screen:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final homeData = ref.watch(homeDataProvider);
  
  return homeData.when(
    data: (data) => _buildContent(data),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(error),
  );
}
```

### 3. Real-time Updates
```dart
final watchHistoryStreamProvider = StreamProvider<List<WatchHistory>>((ref) {
  final supabase = ref.read(supabaseServiceProvider);
  final userId = ref.read(authProvider).user?.id;
  
  return supabase.client
      .from('watch_history')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((data) => data.map((e) => WatchHistory.fromJson(e)).toList());
});
```

## 🎥 Video Playback Architecture

### Video Source Resolution
1. **Fetch Episode Sources**: Call HiAnime API
2. **Get Quality Options**: 480p, 720p, 1080p, auto
3. **Fetch AniSkip Data**: Intro/outro timestamps
4. **Multi-source Fallback**: Primary → Secondary → Tertiary

### Proxy Integration
```dart
// 1. Get raw video URL from source
final sources = await api.fetchStreamingSources(episodeId);
final videoUrl = sources.sources.first.url;

// 2. Proxy through Supabase Edge Function
final proxiedUrl = api.getProxiedVideoUrl(
  videoUrl,
  referer: sources.headers.referer,
);

// 3. Initialize video player
_videoController = VideoPlayerController.networkUrl(
  Uri.parse(proxiedUrl),
  httpHeaders: {
    'Referer': sources.headers.referer,
    'User-Agent': sources.headers.userAgent,
  },
);

// 4. Track playback progress
_videoController.addListener(() {
  final position = _videoController.value.position;
  _saveProgress(position.inSeconds);
});
```

### Subtitle Handling
```dart
// Proxy subtitle URLs
final subtitles = sources.subtitles.map((sub) {
  return Subtitle(
    lang: sub.lang,
    url: api.getProxiedSubtitleUrl(sub.url),
    label: sub.label,
  );
}).toList();

// Load subtitles in player
_chewieController = ChewieController(
  videoPlayerController: _videoController,
  subtitle: Subtitles(subtitles),
  subtitleBuilder: (context, subtitle) => Container(
    padding: EdgeInsets.all(8),
    color: Colors.black54,
    child: Text(subtitle, style: TextStyle(color: Colors.white)),
  ),
);
```

## 📥 Download Architecture

### Download Flow
1. **Request Permission**: Storage access
2. **Fetch Video URL**: Get proxied stream URL
3. **Queue Download**: Add to download queue
4. **Background Download**: Use WorkManager/BackgroundFetch
5. **Save Metadata**: Store in local database
6. **Sync to Cloud**: Update Supabase with download record

### Download Service Pattern
```dart
class DownloadService {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  
  Future<Download> startDownload({
    required Download download,
    required Function(double) onProgress,
  }) async {
    final cancelToken = CancelToken();
    _cancelTokens[download.id] = cancelToken;
    
    await _dio.download(
      download.videoUrl,
      download.localPath,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        onProgress(received / total);
      },
    );
  }
  
  void pauseDownload(String downloadId) {
    _cancelTokens[downloadId]?.cancel();
  }
}
```

## 🔔 Notification Architecture

### Push Notifications Flow
1. **App Launch**: Initialize Firebase, get FCM token
2. **Token Registration**: Send token to Supabase
3. **Subscribe to Topics**: `all_users`, `anime_updates`, etc.
4. **Receive Notification**: FCM delivers payload
5. **Handle Tap**: Navigate to specific screen via deep link

### Admin-Triggered Notifications
```
Web Admin Dashboard → Firebase Admin SDK → FCM → User Devices
```

### Automated Notifications
```
Database Trigger → Supabase Function → FCM API → User Devices
```

Example: New episode released
```sql
CREATE OR REPLACE FUNCTION notify_new_episode()
RETURNS TRIGGER AS $$
BEGIN
  -- Check which users are watching this anime
  -- Send notification via Supabase Edge Function to FCM
  PERFORM net.http_post(
    url := 'https://fcm.googleapis.com/v1/projects/tatakai/messages:send',
    headers := jsonb_build_object('Authorization', 'Bearer ' || fcm_token),
    body := jsonb_build_object(
      'message', jsonb_build_object(
        'topic', 'anime_' || NEW.anime_id,
        'notification', jsonb_build_object(
          'title', 'New Episode Released!',
          'body', NEW.anime_name || ' Episode ' || NEW.episode_number
        ),
        'data', jsonb_build_object(
          'screen', 'anime_detail',
          'animeId', NEW.anime_id
        )
      )
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 🔄 Synchronization Architecture

### Sync Strategy: Last-Write-Wins
- Every record has `updated_at` timestamp
- Conflict resolution based on latest timestamp
- Local changes uploaded when online
- Remote changes downloaded and merged

### Sync Triggers
1. **On App Launch**: Full sync
2. **On Network Reconnect**: Incremental sync
3. **On Data Change**: Immediate sync (if online)
4. **Periodic**: Every 5 minutes (background)

### Sync Service Pattern
```dart
class SyncService {
  Future<void> syncWatchHistory() async {
    // 1. Get local changes since last sync
    final localChanges = await _getLocalChanges();
    
    // 2. Upload to Supabase
    await _uploadChanges(localChanges);
    
    // 3. Download remote changes
    final remoteChanges = await _downloadRemoteChanges();
    
    // 4. Merge with local data (last-write-wins)
    await _mergeChanges(remoteChanges);
    
    // 5. Update last sync timestamp
    await _updateLastSyncTime();
  }
}
```

## 🧪 Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Service API calls (mocked)
- Business logic in providers

### Widget Tests
- Individual widget rendering
- User interaction (tap, scroll)
- State changes

### Integration Tests
- End-to-end user flows
- Authentication flow
- Video playback
- Download and offline playback

## 🚀 Performance Optimizations

### 1. Image Caching
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  cacheKey: imageUrl,
  maxHeightDiskCache: 1000,
  memCacheHeight: 500,
  placeholder: (context, url) => Shimmer.fromColors(...),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. List Virtualization
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => AnimeCard(items[index]),
  cacheExtent: 1000, // Pre-render items outside viewport
)
```

### 3. Lazy Loading
```dart
final animeListProvider = StateNotifierProvider<AnimeListNotifier, AnimeListState>((ref) {
  return AnimeListNotifier(ref.read(apiServiceProvider));
});

class AnimeListNotifier extends StateNotifier<AnimeListState> {
  int _page = 1;
  
  Future<void> loadMore() async {
    _page++;
    final newItems = await _api.fetchAnimes(page: _page);
    state = state.copyWith(
      items: [...state.items, ...newItems],
      hasMore: newItems.isNotEmpty,
    );
  }
}
```

### 4. Background Tasks
- Use `WorkManager` for scheduled tasks
- Download in background with progress notification
- Sync data periodically

## 🔒 Security Considerations

### 1. Secure Storage
- Use `flutter_secure_storage` for tokens
- Encrypt sensitive data in Hive
- Never log sensitive information

### 2. API Security
- All requests through Supabase proxy
- API keys stored in environment variables
- Row-level security (RLS) on Supabase tables

### 3. Certificate Pinning
```dart
SecurityContext context = SecurityContext.defaultContext;
context.setTrustedCertificates('assets/certificates/cert.pem');
```

## 📈 Analytics Implementation

### Event Tracking
```dart
Future<void> trackEvent(String eventName, Map<String, dynamic> params) async {
  if (!Config.enableAnalytics) return;
  
  await supabase.from('analytics_events').insert({
    'user_id': currentUser.id,
    'event_name': eventName,
    'params': params,
    'created_at': DateTime.now().toIso8601String(),
  });
}
```

### Screen Tracking
```dart
class ScreenTracker extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      trackPageView(route.settings.name!);
    }
  }
}
```

## 🎯 Future Enhancements

1. **GraphQL Integration**: Replace REST with GraphQL for flexible queries
2. **Offline-First Architecture**: Better offline support with sync queue
3. **Background Playback**: Audio-only mode for bandwidth saving
4. **Chromecast Support**: Cast to TV devices
5. **Apple TV & Android TV**: Optimize for TV platforms
6. **Picture-in-Picture**: Continue watching while using other apps
7. **Smart Downloads**: Auto-download next episodes
8. **Watch Party**: Sync playback with friends

---

For implementation details, see the code in `/lib/` directory.
