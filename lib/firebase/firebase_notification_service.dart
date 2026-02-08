import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:denz_sen/firebase/notification_handler.dart';
import 'package:denz_sen/firebase/fcm_token_api.dart';
import 'package:denz_sen/main.dart';

/// Firebase Cloud Messaging service to handle push notifications
class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialize Firebase Cloud Messaging
  static Future<void> initialize() async {
    print('🚀 Starting Firebase initialization...');
    print('📱 Initializing FCM...');

    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('🔔 Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');

      // Get FCM token
      await _getFCMToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token refreshed: $newToken');
        _saveTokenLocally(newToken);
        // Backend এ নতুন token পাঠান
        FcmTokenApi.updateToken(newToken);
      });

      // Setup foreground notification handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📬 Foreground notification received');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');

        // Show custom dialog
        final context = navigatorKey.currentContext;
        if (context != null) {
          NotificationHandler.showDispatchAlert(context);
        }
      });

      // Handle notification when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 App opened from notification (Background)');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');

        // Show custom dialog
        final context = navigatorKey.currentContext;
        if (context != null) {
          NotificationHandler.showDispatchAlert(context);
        }
      });

      // Check if app was opened from a terminated state via notification
      _checkInitialMessage();

      print('✅ Firebase initialization completed');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ User granted provisional notification permission');
    } else {
      print('❌ User declined notification permission');
    }

    // Set foreground notification presentation options for iOS
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Get FCM Token and save it
  static Future<void> _getFCMToken() async {
    try {
      print('🔑 Requesting FCM token...');
      print('⏳ Fetching FCM token from Firebase...');

      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        print('\n${'=' * 80}');
        print('🔑 FCM TOKEN (Share this with your backend developer):');
        print('=' * 80);
        print(token);
        print('=' * 80);
        print('\n✅ Token successfully retrieved!');

        // Save token locally
        await _saveTokenLocally(token);

        // Check if user is logged in before sending to backend
        final prefs = await SharedPreferences.getInstance();
        final authToken = prefs.getString('token');

        if (authToken != null && authToken.isNotEmpty) {
          // Backend এ token পাঠান
          final sent = await FcmTokenApi.sendTokenToBackend(token);
          if (sent) {
            print('✅ Token sent to backend successfully');
          } else {
            print('⚠️ Failed to send token to backend');
          }
        } else {
          print('ℹ️ User not logged in. Token will be sent after login.');
        }

        print('✅ FCM token request completed');
      } else {
        print('❌ Failed to get FCM token');
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Save token to local storage
  static Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('💾 FCM token saved locally');
  }

  /// Get saved token from local storage
  static Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  /// Send saved token to backend (call after login)
  static Future<void> sendSavedTokenToBackend() async {
    final token = await getSavedToken();
    if (token != null) {
      final sent = await FcmTokenApi.sendTokenToBackend(token);
      if (sent) {
        print('✅ Saved token sent to backend after login');
      } else {
        print('⚠️ Failed to send saved token to backend');
      }
    } else {
      print('⚠️ No saved FCM token found');
    }
  }

  /// Get current FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Delete FCM token (useful for logout)
  static Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    print('🗑️ FCM token deleted from Firebase');
  }

  /// Check if app was launched from a terminated state via notification
  static Future<void> _checkInitialMessage() async {
    try {
      print('🔍 Checking if app was opened from notification...');
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();

      if (initialMessage != null) {
        print('📱 App launched from notification (Terminated state)');
        print('Title: ${initialMessage.notification?.title}');
        print('Body: ${initialMessage.notification?.body}');
        print('Data: ${initialMessage.data}');

        // Show dialog after a short delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 1000), () {
          final context = navigatorKey.currentContext;
          if (context != null) {
            print('✅ Showing notification dialog');
            NotificationHandler.showDispatchAlert(context);
          } else {
            print('⚠️ Context not available yet, will retry...');
            // Retry after another delay
            Future.delayed(const Duration(milliseconds: 1500), () {
              final retryContext = navigatorKey.currentContext;
              if (retryContext != null) {
                print('✅ Showing notification dialog (retry)');
                NotificationHandler.showDispatchAlert(retryContext);
              }
            });
          }
        });
      } else {
        print('ℹ️ App not launched from notification');
      }
    } catch (e) {
      print('❌ Error checking initial message: $e');
    }
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('❌ Unsubscribed from topic: $topic');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🌙 Background notification received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}
