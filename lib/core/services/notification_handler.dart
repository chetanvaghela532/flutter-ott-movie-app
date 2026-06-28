import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../../features/movies/presentation/screens/movie_details_screen.dart';
import '../../../features/movies/presentation/screens/tv_show_details_screen.dart';
import '../../../features/movies/presentation/screens/main_navigation_screen.dart';
import '../../../features/movies/presentation/screens/search_screen.dart';

/// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  static Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permission for Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final String? payload = response.payload;
    if (payload != null) {
      _handleNavigation(payload);
    }
  }

  /// Download and save file for notification image
  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/$fileName';
    final Dio dio = Dio();
    await dio.download(url, filePath);
    return filePath;
  }

  /// Show local notification when app is in foreground
  static Future<void> showNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    if (notification == null) return;

    // Extract navigation data from message
    final String? movieId = message.data['movie_id'];
    final String? tvShowId = message.data['tv_show_id'];
    final String? type = message.data['type']; // 'movie', 'tv_show', 'screen', 'route'
    final String? isPlayAvailable = message.data['is_play_available'];
    final String? screen = message.data['screen']; // 'home', 'search', 'movies', 'web_series'
    final String? route = message.data['route']; // Alternative to 'screen'
    final String? videoUrl = message.data['video_url']; // Video URL for direct playback

    // Extract image URL from notification or data
    final String? imageUrl = notification.android?.imageUrl ??
        message.data['image'] ??
        message.data['image_url'];

    // Create payload for navigation (include video_url)
    String? payload;
    if (screen != null || route != null) {
      // Navigate to specific screen
      payload = 'screen:${screen ?? route}';
    } else if (movieId != null && type == 'movie') {
      payload = 'movie:$movieId:${isPlayAvailable ?? 'false'}:${videoUrl ?? ''}';
    } else if (tvShowId != null && (type == 'tv_show' || type == 'Series')) {
      payload = 'tv_show:$tvShowId:${isPlayAvailable ?? 'false'}:${videoUrl ?? ''}';
    } else if (type == 'screen' || type == 'route') {
      // Direct screen navigation
      final String? screenName = screen ?? route ?? message.data['screen_name'];
      if (screenName != null) {
        payload = 'screen:$screenName';
      }
    }

    // Handle Image Support
    BigPictureStyleInformation? bigPictureStyleInformation;
    String? largeIconPath;
    List<DarwinNotificationAttachment>? iosAttachments;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final String fileName = 'notification_img_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = await _downloadAndSaveFile(imageUrl, fileName);

        // Android Style
        bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath),
          hideExpandedLargeIcon: true,
          contentTitle: notification.title,
          summaryText: notification.body,
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
        );

        // iOS Attachments
        iosAttachments = [DarwinNotificationAttachment(filePath)];
      } catch (e) {
        debugPrint('Error downloading notification image: $e');
      }
    }

    final AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: bigPictureStyleInformation,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: iosAttachments,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: payload,
    );
  }

  /// Handle navigation based on notification data
  static void _handleNavigation(String payload) {
    print('payload == > $payload');
    final List<String> parts = payload.split(':');
    if (parts.isEmpty) return;

    final String type = parts[0];
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) return;

    // Handle screen/route navigation
    if (type == 'screen' || type == 'route') {
      final String? screenName = parts.length > 1 ? parts[1] : null;
      if (screenName != null) {
        _navigateToScreen(context, screenName);
        return;
      }
    }

    // Handle movie/TV show navigation
    if (parts.length < 2) return;

    final String? idString = parts.length > 1 ? parts[1] : null;
    final bool isPlayAvailable = parts.length > 2 ? parts[2] == 'true' : false;
    final String? videoUrl = parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null;

    if (idString == null) return;

    final int? id = int.tryParse(idString);
    if (id == null) return;

    if (type == 'movie') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MovieDetailsScreen(
            movieId: id,
            isPlayAvailable: isPlayAvailable,
            videoUrl: videoUrl,
          ),
        ),
      );
    } else if (type == 'tv_show') {
      print('type ==>>> $type');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TvShowDetailsScreen(
            tvShowId: id,
            isPlayAvailable: isPlayAvailable,
            videoUrl: videoUrl,
          ),
        ),
      );
    }
  }

  /// Navigate to a specific screen
  static void _navigateToScreen(BuildContext context, String screenName) {
    switch (screenName.toLowerCase()) {
      case 'home':
      // Navigate to home screen (root)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              (route) => false, // Remove all previous routes
        );
        break;
      case 'search':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
        break;
      case 'movies':
      // Navigate to home and set tab to movies (index 1)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
              (route) => false,
        );
        // Note: To set specific tab, you might need to pass parameters
        // For now, it navigates to home screen
        break;
      case 'web_series':
      case 'series':
      // Navigate to home and set tab to web series (index 2)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(),
          ),
              (route) => false,
        );
        break;
      default:
      // Default: navigate to home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              (route) => false,
        );
    }
  }

  /// Handle navigation from RemoteMessage data
  static void handleMessageNavigation(RemoteMessage message) {
    final String? movieId = message.data['movie_id'];
    final String? tvShowId = message.data['tv_show_id'];
    final String? type = message.data['type'];
    final String? isPlayAvailableStr = message.data['is_play_available'];
    final bool isPlayAvailable = isPlayAvailableStr == 'true';
    final String? screen = message.data['screen'];
    final String? route = message.data['route'];
    final String? screenName = message.data['screen_name'];
    final String? videoUrl = message.data['video_url']; // Video URL for direct playback

    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      // If context is not available, wait a bit and try again
      Future.delayed(const Duration(milliseconds: 300), () {
        handleMessageNavigation(message);
      });
      return;
    }

    // Priority 1: Screen/Route navigation
    if (screen != null || route != null || screenName != null) {
      _navigateToScreen(context, screen ?? route ?? screenName ?? 'home');
      return;
    }

    // Priority 2: Type-based navigation (screen/route)
    if (type == 'screen' || type == 'route') {
      final String targetScreen = screen ?? route ?? screenName ?? 'home';
      _navigateToScreen(context, targetScreen);
      return;
    }

    // Priority 3: Movie navigation
    if (movieId != null && (type == 'movie' || type == null)) {
      final int? id = int.tryParse(movieId);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(
              movieId: id,
              isPlayAvailable: isPlayAvailable,
              videoUrl: videoUrl,
            ),
          ),
        );
        return;
      }
    }

    // Priority 4: TV Show navigation
    if (tvShowId != null && (type == 'Series' || type == 'tv_show' || type == null)) {
      final int? id = int.tryParse(tvShowId);
      if (id != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TvShowDetailsScreen(
              tvShowId: id,
              isPlayAvailable: isPlayAvailable,
              videoUrl: videoUrl,
            ),
          ),
        );
        return;
      }
    }

    // Default: Navigate to home if no specific navigation data
    if (type == null && movieId == null && tvShowId == null) {
      _navigateToScreen(context, 'home');
    }
  }
}