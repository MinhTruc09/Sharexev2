import 'package:sharexev2/core/network/api_response.dart';
import 'package:sharexev2/data/models/notification/dtos/notification_dto.dart';
import 'notification_repository_interface.dart';
import 'notification_repository_impl.dart';
import 'package:sharexev2/data/services/notification_service.dart';
import 'package:sharexev2/core/di/service_locator.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final NotificationRepositoryImpl _impl;

  NotificationRepository({NotificationService? service})
      : _impl = NotificationRepositoryImpl(
          service ?? ServiceLocator.get<NotificationService>(),
        );

  @override
  Future<ApiResponse<List<NotificationDto>>> getNotifications() =>
      _impl.getNotifications();

  @override
  Future<ApiResponse<int>> getUnreadCount() => _impl.getUnreadCount();

  @override
  Future<ApiResponse<void>> markAsRead(String id) => _impl.markAsRead(id);

  @override
  Future<ApiResponse<void>> markAllAsRead() => _impl.markAllAsRead();

  @override
  Future<ApiResponse<void>> deleteNotification(String id) => _impl.deleteNotification(id);

  @override
  Future<ApiResponse<void>> deleteAllNotifications() => _impl.deleteAllNotifications();

  @override
  Future<ApiResponse<void>> sendNotification(NotificationDto notification) => _impl.sendNotification(notification);
}


