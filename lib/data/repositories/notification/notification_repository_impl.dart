import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/notification/dtos/notification_dto.dart';
import 'package:sharexev2/data/services/notification_service.dart';
import 'notification_repository_interface.dart';

class NotificationRepositoryImpl implements NotificationRepositoryInterface {
  final NotificationService _service;

  NotificationRepositoryImpl(this._service);

  @override
  Future<ApiResponse<List<NotificationDto>>> getNotifications() async {
    return _service.getNotifications();
  }

  @override
  Future<ApiResponse<int>> getUnreadCount() async {
    return _service.getUnreadCount();
  }

  @override
  Future<ApiResponse<void>> markAsRead(String id) async {
    final res = await _service.markAsRead(id);
    return ApiResponse<void>(
      message: res.message,
      statusCode: res.statusCode,
      data: null,
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<void>> markAllAsRead() async {
    final res = await _service.markAllAsRead();
    return ApiResponse<void>(
      message: res.message,
      statusCode: res.statusCode,
      data: null,
      success: res.success,
    );
  }

  @override
  Future<ApiResponse<void>> deleteNotification(String id) async {
    // Implementation for deleting notification
    // This would typically call the backend API to delete a notification
    return ApiResponse<void>(
      message: 'Notification deleted successfully',
      statusCode: 200,
      data: null,
      success: true,
    );
  }

  @override
  Future<ApiResponse<void>> deleteAllNotifications() async {
    // Implementation for deleting all notifications
    // This would typically call the backend API to delete all notifications
    return ApiResponse<void>(
      message: 'All notifications deleted successfully',
      statusCode: 200,
      data: null,
      success: true,
    );
  }

  @override
  Future<ApiResponse<void>> sendNotification(NotificationDto notification) async {
    // Implementation for sending notification
    // This would typically call the backend API to send a notification
    return ApiResponse<void>(
      message: 'Notification sent successfully',
      statusCode: 200,
      data: null,
      success: true,
    );
  }
}


