import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tatakai_mobile/config/env.dart';
import 'package:tatakai_mobile/config/theme.dart';
import 'package:tatakai_mobile/config/router.dart';
import 'package:tatakai_mobile/services/supabase_service.dart';
import 'package:tatakai_mobile/services/notification_service.dart';
import 'package:tatakai_mobile/providers/auth_provider.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // System UI configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('app_data');
  await Hive.openBox('watch_history');
  await Hive.openBox('downloads');
  await Hive.openBox('preferences');
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize Supabase
  final supabaseService = await SupabaseService.getInstance();
  
  // Initialize Notifications
  await NotificationService().initialize();
  
  runApp(ProviderScope(
    overrides: [
      supabaseServiceProvider.overrideWithValue(supabaseService),
    ],
    child: const TatakaiApp(),
  ));
}

class TatakaiApp extends ConsumerWidget {
  const TatakaiApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current theme from preferences (will be implemented with provider)
    final currentTheme = 'wakuwaku_dark'; // Using the new WakuWaku theme
    
    // Create auth-aware router
    final router = createRouter(ref);
    
    return MaterialApp.router(
      title: Config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.getTheme(currentTheme),
      routerConfig: router,
      builder: (context, child) {
        // Add error boundary
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Config.enableCrashReporting 
                          ? errorDetails.exceptionAsString()
                          : 'An unexpected error occurred',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}

// Backwards-compatible alias for tests
class MyApp extends TatakaiApp {
  const MyApp({super.key});
}
