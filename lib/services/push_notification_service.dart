import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/models/notification/entities/notification_entity.dart';
import '../core/network/api_client.dart';

/// Service for handling push notifications
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  String? _fcmToken;
  Function(NotificationEntity)? _onNotificationReceived;
  Function(String)? _onNotificationTapped;

  /// Initialize the notification service
  Future<void> initialize({
    Function(NotificationEntity)? onNotificationReceived,
    Function(String)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    _onNotificationReceived = onNotificationReceived;
    _onNotificationTapped = onNotificationTapped;

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _setupNotificationHandlers();

    _isInitialized = true;
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _onNotificationTapped?.call(response.payload!);
        }
      },
    );

    // Create notification channels for Android
    if (!kIsWeb) {
      await _createNotificationChannels();
    }
  }

  /// Create notification channels for different types
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'booking_updates',
        'Booking Updates',
        description: 'Notifications about booking status changes',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      AndroidNotificationChannel(
        'ride_updates',
        'Ride Updates',
        description: 'Notifications about ride status and location',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      AndroidNotificationChannel(
        'chat_messages',
        'Chat Messages',
        description: 'New chat messages',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('message_sound'),
      ),
      AndroidNotificationChannel(
        'general',
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission for notifications');
    } else {
      debugPrint('User declined or has not accepted permission for notifications');
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $_fcmToken');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
      // Send updated token to server
      _sendTokenToServer(token);
    });
  }

  /// Setup notification handlers
  Future<void> _setupNotificationHandlers() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    final notification = _createNotificationEntity(message);
    _onNotificationReceived?.call(notification);
    
    // Show local notification
    _showLocalNotification(message);
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    final data = message.data;
    final type = data['type'] ?? 'general';
    final referenceId = data['referenceId'];
    
    // Navigate based on notification type
    switch (type) {
      case 'booking_update':
        _onNotificationTapped?.call('/passenger/bookings/$referenceId');
        break;
      case 'ride_update':
        _onNotificationTapped?.call('/tracking/$referenceId');
        break;
      case 'chat_message':
        _onNotificationTapped?.call('/chat/$referenceId');
        break;
      case 'driver_request':
        _onNotificationTapped?.call('/driver/bookings');
        break;
      default:
        _onNotificationTapped?.call('/notifications');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] ?? 'general';
    final channelId = _getChannelId(type);
    
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  /// Create notification entity from remote message
  NotificationEntity _createNotificationEntity(RemoteMessage message) {
    final data = message.data;
    
    return NotificationEntity(
      id: message.hashCode,
      title: message.notification?.title ?? 'Thông báo mới',
      message: message.notification?.body ?? '',
      type: data['type'] ?? 'general',
      isRead: false,
      createdAt: DateTime.now(),
      data: data,
    );
  }

  /// Get channel ID based on notification type
  String _getChannelId(String type) {
    switch (type) {
      case 'booking_update':
      case 'driver_request':
        return 'booking_updates';
      case 'ride_update':
      case 'tracking':
        return 'ride_updates';
      case 'chat_message':
        return 'chat_messages';
      default:
        return 'general';
    }
  }

  /// Send notification to specific user
  Future<void> sendNotificationToUser({
    required String userToken,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    try {
      // Implement server-side notification sending
      debugPrint('Sending notification to user: $title');
      
      // Call backend API to send FCM messages
      final response = await _sendNotificationToBackend({
        'userToken': userToken,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
      });
      
      if (response['success'] == true) {
        debugPrint('Notification sent successfully');
      } else {
        debugPrint('Failed to send notification: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  /// Send notification to multiple users
  Future<void> sendNotificationToMultipleUsers({
    required List<String> userTokens,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    try {
      // Implement server-side notification sending to multiple users
      debugPrint('Sending notification to ${userTokens.length} users: $title');
      
      // Call backend API to send bulk FCM messages
      final response = await _sendBulkNotificationToBackend({
        'userTokens': userTokens,
        'title': title,
        'body': body,
        'type': type,
        'data': data ?? {},
      });
      
      if (response['success'] == true) {
        debugPrint('Bulk notification sent successfully');
      } else {
        debugPrint('Failed to send bulk notification: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error sending bulk notification: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Schedule local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Send notification data to backend API
  Future<Map<String, dynamic>> _sendNotificationToBackend(Map<String, dynamic> data) async {
    try {
      // Real API implementation - send notification to backend
      final apiClient = ApiClient();
      final response = await apiClient.client.post('/api/send-notification', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Failed to send notification: $e'};
    }
  }

  /// Send bulk notification data to backend API
  Future<Map<String, dynamic>> _sendBulkNotificationToBackend(Map<String, dynamic> data) async {
    try {
      // Real API implementation - send bulk notification to backend
      final apiClient = ApiClient();
      final response = await apiClient.client.post('/api/send-notification-bulk', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Failed to send bulk notification: $e'};
    }
  }

  /// Send FCM token to backend API
  Future<Map<String, dynamic>> _sendTokenToBackend(Map<String, dynamic> data) async {
    try {
      // Real API implementation - register FCM token with backend
      final apiClient = ApiClient();
      final response = await apiClient.client.post('/api/fcm-token', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Failed to register FCM token: $e'};
    }
  }

  /// Send FCM token to server
  Future<void> _sendTokenToServer(String token) async {
    try {
      // Implement API call to send token to server
      debugPrint('Sending FCM token to server: ${token.substring(0, 10)}...');
      
      // Call backend API to register the FCM token
      final response = await _sendTokenToBackend({
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });
      
      if (response['success'] == true) {
        debugPrint('FCM token sent to server successfully');
      } else {
        debugPrint('Failed to send FCM token to server: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token to server: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
}
