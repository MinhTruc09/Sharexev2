import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:sharexev2/main.dart';

class FirebaseApi {
  // Create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Function to initialize notifications
  Future<void> initNotification() async {
    // Request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    // Fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    // Print the token (send this to your backend)
    debugPrint("FCM Token: $fCMToken");
    
    // Initialize push notifications
    initPushNotifications();
  }

  // Function to handle received messages
  void handleMessage(RemoteMessage? message) {
    // If the message is null do nothing
    if (message == null) return;

    // Navigate to appropriate screen based on notification type
    final data = message.data;
    
    if (data['type'] == 'chat_message') {
      // Navigate to chat room
      navigationService.navigatorKey.currentState?.pushNamed(
        '/chat',
        arguments: {
          'roomId': data['roomId'],
          'participantName': data['senderName'] ?? 'Unknown',
          'participantEmail': data['senderEmail'],
        },
      );
    } else if (data['type'] == 'trip_update') {
      // Navigate to trip details
      navigationService.navigatorKey.currentState?.pushNamed(
        '/trip-details',
        arguments: data['tripId'],
      );
    } else if (data['type'] == 'booking_request') {
      // Navigate to booking details
      navigationService.navigatorKey.currentState?.pushNamed(
        '/booking-details',
        arguments: data['bookingId'],
      );
    } else {
      // Default notification page
      navigationService.navigatorKey.currentState?.pushNamed(
        '/notification-details',
        arguments: message,
      );
    }
  }

  // Function to initialize foreground and background settings
  Future<void> initPushNotifications() async {
    // Handle notification when app is terminated and opened via notification
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Attach event listeners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');
      
      // You can show local notification here or update UI
      // For now, just handle the message
      handleMessage(message);
    });
  }

  // Send FCM token to backend
  Future<void> sendTokenToBackend(String token, String userId) async {
    try {
      // TODO: Implement API call to send token to backend
      // await ApiService.updateFCMToken(userId, token);
      debugPrint('Token sent to backend: $token for user: $userId');
    } catch (e) {
      debugPrint('Error sending token to backend: $e');
    }
  }

  // Subscribe to topic (for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  // Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}
