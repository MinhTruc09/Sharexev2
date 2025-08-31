import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/notification/dtos/notification_dto.dart';
import 'package:sharexev2/config/app_config.dart';

class NotificationService {
  final ApiClient _api;

  NotificationService(this._api);

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
  // Server-side creation may be admin-only; implement when backend exposes it

  /// Gửi push notification qua FCM
  // Push notification sending is usually done by backend; keep client FCM in FCMService

  /// Subscribe user to notification topics
  // Topic subscription handled locally by FCMService

  /// Unsubscribe user from notification topics
  // Topic unsubscription handled locally by FCMService

  /// Get notification settings for user
  // Settings endpoints are not defined in API docs; omit until backend supports

  /// Update notification settings for user
  // Update settings omitted (no API in docs)
}
