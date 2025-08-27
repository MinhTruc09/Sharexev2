import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/notification/notification_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  /// Lấy tất cả notifications
  Future<ApiResponse<List<NotificationDto>>> getNotifications() async {
    final res = await _api.client.get(AppConfig.I.notifications.all);
    return ApiResponse.listFromJson<NotificationDto>(res.data as Map<String, dynamic>, (e) {
      return NotificationDto.fromJson(e as Map<String, dynamic>);
    });
  }

  /// Lấy số lượng notifications chưa đọc
  Future<ApiResponse<int>> getUnreadCount() async {
    final res = await _api.client.get(AppConfig.I.notifications.unreadCount);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) {
      return data as int;
    });
  }

  /// Đánh dấu notification đã đọc
  Future<ApiResponse<dynamic>> markAsRead(String notificationId) async {
    final res = await _api.client.put('${AppConfig.I.notifications.markRead}$notificationId');
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
  }

  /// Đánh dấu tất cả notifications đã đọc
  Future<ApiResponse<dynamic>> markAllAsRead() async {
    final res = await _api.client.put(AppConfig.I.notifications.markAllRead);
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (data) => data);
  }

  /// Tạo notification mới (cho admin hoặc system)
  Future<bool> createNotification({
    required String userEmail,
    required String title,
    required String content,
    required String type,
    int? referenceId,
  }) async {
    try {
      // TODO: Implement API call to create notification
      // For now, just return success
      return true;
    } catch (e) {
      print('Error creating notification: $e');
      return false;
    }
  }

  /// Gửi push notification qua FCM
  Future<bool> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // TODO: Implement FCM server call
      // For now, just return success
      print('Sending push notification to: $fcmToken');
      print('Title: $title, Body: $body');
      return true;
    } catch (e) {
      print('Error sending push notification: $e');
      return false;
    }
  }

  /// Subscribe user to notification topics
  Future<bool> subscribeToTopics(String userId, List<String> topics) async {
    try {
      // TODO: Implement topic subscription
      for (String topic in topics) {
        print('Subscribing user $userId to topic: $topic');
      }
      return true;
    } catch (e) {
      print('Error subscribing to topics: $e');
      return false;
    }
  }

  /// Unsubscribe user from notification topics
  Future<bool> unsubscribeFromTopics(String userId, List<String> topics) async {
    try {
      // TODO: Implement topic unsubscription
      for (String topic in topics) {
        print('Unsubscribing user $userId from topic: $topic');
      }
      return true;
    } catch (e) {
      print('Error unsubscribing from topics: $e');
      return false;
    }
  }

  /// Get notification settings for user
  Future<Map<String, dynamic>> getNotificationSettings(String userId) async {
    try {
      // TODO: Implement API call to get notification settings
      // For now, return default settings
      return {
        'pushEnabled': true,
        'emailEnabled': true,
        'smsEnabled': false,
        'chatNotifications': true,
        'tripUpdates': true,
        'promotional': false,
      };
    } catch (e) {
      print('Error getting notification settings: $e');
      return {};
    }
  }

  /// Update notification settings for user
  Future<bool> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      // TODO: Implement API call to update notification settings
      print('Updating notification settings for user $userId: $settings');
      return true;
    } catch (e) {
      print('Error updating notification settings: $e');
      return false;
    }
  }
}
