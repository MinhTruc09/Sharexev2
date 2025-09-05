import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/notification/dtos/notification_dto.dart';

abstract class NotificationRepositoryInterface {
  Future<ApiResponse<List<NotificationDto>>> getNotifications();
  Future<ApiResponse<int>> getUnreadCount();
  Future<ApiResponse<void>> markAsRead(String id);
  Future<ApiResponse<void>> markAllAsRead();
  Future<ApiResponse<void>> deleteNotification(String id);
  Future<ApiResponse<void>> deleteAllNotifications();
  Future<ApiResponse<void>> sendNotification(NotificationDto notification);
}


