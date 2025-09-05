import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/notification/notification_repository_interface.dart';
import 'package:sharexev2/data/models/notification/entities/notification_entity.dart';
import 'package:sharexev2/data/models/notification/mappers/notification_mapper.dart';
import 'package:sharexev2/data/models/notification/dtos/notification_dto.dart';
// import 'package:sharexev2/core/network/api_response.dart'; // Unused

part 'notification_state.dart';

/// NotificationCubit - Quản lý thông báo real-time
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepositoryInterface? _notificationRepository;

  NotificationCubit({
    required NotificationRepositoryInterface? notificationRepository,
  }) : _notificationRepository = notificationRepository,
       super(const NotificationState());

  /// Load notifications from repository
  Future<void> loadNotifications() async {
    emit(state.copyWith(status: NotificationStatus.loading));

    try {
      if (_notificationRepository != null) {
        final response = await _notificationRepository.getNotifications();
        
        if (response.success && response.data != null) {
          // Convert DTO to Entity using mapper
          final notifications = NotificationMapper.fromDtoList(response.data!);
          final unreadCount = notifications.where((n) => !n.isRead).length;
          
          emit(state.copyWith(
            status: NotificationStatus.loaded,
            notifications: notifications,
            unreadCount: unreadCount,
          ));
        } else {
          emit(state.copyWith(
            status: NotificationStatus.error,
            error: response.message.isEmpty ? 'Failed to load notifications' : response.message,
          ));
        }
      } else {
        // Repository not available - show error instead of mock data
        emit(state.copyWith(
          status: NotificationStatus.error,
          error: 'Notification service is not available. Please check your connection.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      if (_notificationRepository != null) {
        final response = await _notificationRepository.markAsRead(notificationId.toString());
        
        if (response.success) {
          final updatedNotifications = state.notifications.map((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(isRead: true);
            }
            return notification;
          }).toList();
          
          emit(state.copyWith(
            notifications: updatedNotifications,
            unreadCount: updatedNotifications.where((n) => !n.isRead).length,
          ));
        }
      } else {
        // Repository not available - show error
        emit(state.copyWith(
          status: NotificationStatus.error,
          error: 'Cannot mark notification as read. Service unavailable.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      if (_notificationRepository != null) {
        final response = await _notificationRepository.markAllAsRead();
        
        if (response.success) {
          final updatedNotifications = state.notifications.map((notification) {
            return notification.copyWith(isRead: true);
          }).toList();
          
          emit(state.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ));
        }
      } else {
        // Repository not available - show error
        emit(state.copyWith(
          status: NotificationStatus.error,
          error: 'Cannot mark all notifications as read. Service unavailable.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      if (_notificationRepository != null) {
        final response = await _notificationRepository.deleteNotification(notificationId.toString());
        
        if (response.success) {
          final updatedNotifications = state.notifications
              .where((notification) => notification.id != notificationId)
              .toList();
          
          emit(state.copyWith(
            notifications: updatedNotifications,
            unreadCount: updatedNotifications.where((n) => !n.isRead).length,
          ));
        }
      } else {
        // Repository not available - show error
        emit(state.copyWith(
          status: NotificationStatus.error,
          error: 'Cannot delete notification. Service unavailable.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    try {
      if (_notificationRepository != null) {
        final response = await _notificationRepository.deleteAllNotifications();
        
        if (response.success) {
          emit(state.copyWith(
            notifications: [],
            unreadCount: 0,
          ));
        }
      } else {
        // Repository not available - show error
        emit(state.copyWith(
          status: NotificationStatus.error,
          error: 'Cannot clear all notifications. Service unavailable.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Send notification (for testing)
  Future<void> sendNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      if (_notificationRepository != null) {
        final notificationDto = NotificationDto(
          id: 0, // Will be assigned by backend
          userEmail: 'current_user@example.com',
          title: title,
          content: message,
          type: type,
          referenceId: 0,
          createdAt: DateTime.now(),
          read: false,
        );
        
        final response = await _notificationRepository.sendNotification(notificationDto);
        
        if (response.success) {
          // Refresh notifications after sending
          await loadNotifications();
        }
      } else {
        // Repository not available - show error  
        emit(state.copyWith(
          status: NotificationStatus.error,
          error: 'Cannot send notification. Service unavailable.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

}
