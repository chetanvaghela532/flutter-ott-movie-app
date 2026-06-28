import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'notification_handler.dart';

/// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
    print('Background message data: ${message.data}');
  }
  // Handle navigation if app was opened from notification
  NotificationHandler.handleMessageNavigation(message);
}

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize local notifications
      await NotificationHandler.initialize();

      if (kDebugMode) {
        print('Firebase initialized successfully');
      }

      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Subscribe to 'all' topic for broadcast notifications
      await _messaging.subscribeToTopic('all');
      if (kDebugMode) {
        print('Subscribed to topic: all');
      }

      // Get FCM token
      String? token = await _messaging.getToken();
      if (kDebugMode && token != null) {
        print('FCM Token: $token');
      }

      // Handle foreground messages - show local notification
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground message: ${message.messageId}');
          print('Message data: ${message.data}');
          print('Message notification: ${message.notification?.title}');
        }
        // Show local notification when app is in foreground
        NotificationHandler.showNotification(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification opened app: ${message.messageId}');
          print('Message data: ${message.data}');
        }
        // Handle navigation based on message data
        NotificationHandler.handleMessageNavigation(message);
      });

      // Check if app was opened from a notification (app was terminated)
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('App opened from notification: ${initialMessage.messageId}');
          print('Initial message data: ${initialMessage.data}');
        }
        // Handle navigation based on initial message
        // Use a small delay to ensure navigator is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          NotificationHandler.handleMessageNavigation(initialMessage);
        });
      }

      // Token refresh listener
      _messaging.onTokenRefresh.listen((String newToken) {
        if (kDebugMode) {
          print('FCM Token refreshed: $newToken');
        }
        // Update token on your server
      });
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
        print('Note: Make sure google-services.json is added to android/app/');
        print('For iOS, add GoogleService-Info.plist to ios/Runner/');
      }
      // Don't throw error - allow app to continue without Firebase
      // Firebase features will simply not work until properly configured
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
    }
  }
}

