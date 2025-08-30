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
}


