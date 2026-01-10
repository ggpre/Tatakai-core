import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tatakai_mobile/config/env.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  
  Future<void> initialize() async {
    // Request permission
    await _requestPermission();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Get FCM token
    _fcmToken = await _fcm.getToken();
    print('FCM Token: $_fcmToken');
    
    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('FCM Token refreshed: $newToken');
    });
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Check if app was opened from a terminated state via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
    
    // Subscribe to topics
    await subscribeToTopics();
  }
  
  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permission: ${settings.authorizationStatus}');
  }
  
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }
  
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message: ${message.messageId}');
    
    // Show local notification
    await showLocalNotification(
      title: message.notification?.title ?? 'Tatakai',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }
  
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');
    final data = message.data;
    
    // Handle deep linking based on notification data
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      final params = data['params'];
      
      // Navigate to screen (will be implemented with router)
      print('Navigate to: $screen with params: $params');
    }
  }
  
  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap
  }
  
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tatakai_channel',
      'Tatakai Notifications',
      channelDescription: 'Notifications for Tatakai app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
  
  Future<void> subscribeToTopics() async {
    if (!Config.enableNotifications) return;
    
    await _fcm.subscribeToTopic(Config.fcmTopicAll);
    await _fcm.subscribeToTopic(Config.fcmTopicAnimeUpdates);
    await _fcm.subscribeToTopic(Config.fcmTopicMaintenanceAlerts);
    
    print('Subscribed to FCM topics');
  }
  
  Future<void> unsubscribeFromTopics() async {
    await _fcm.unsubscribeFromTopic(Config.fcmTopicAll);
    await _fcm.unsubscribeFromTopic(Config.fcmTopicAnimeUpdates);
    await _fcm.unsubscribeFromTopic(Config.fcmTopicMaintenanceAlerts);
    
    print('Unsubscribed from FCM topics');
  }
  
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}
