import '../../core/network/api_response.dart';

// Repository interfaces
import '../../data/repositories/auth/auth_repository_interface.dart';
import '../../data/repositories/booking/booking_repository_interface.dart';
import '../../data/repositories/ride/ride_repository_interface.dart';
import '../../data/repositories/user/user_repository_interface.dart';
import '../../data/repositories/chat/chat_repository_interface.dart';
import '../../data/repositories/location/location_repository_interface.dart';

/// Mock Auth Repository - Simplified implementation
class MockAuthRepository implements AuthRepositoryInterface {
  @override
  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<String?> getStoredToken() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'mock_stored_token';
  }

  @override
  Future<void> clearSession() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // TODO: Implement other methods when needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: true,
      statusCode: 200,
      message: 'Mock implementation',
      data: null,
    ));
  }
}

/// Mock Booking Repository - Simplified implementation
class MockBookingRepository implements BookingRepositoryInterface {
  // TODO: Implement methods when needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: true,
      statusCode: 200,
      message: 'Mock implementation',
      data: [],
    ));
  }
}

/// Mock Ride Repository - Simplified implementation
class MockRideRepository implements RideRepositoryInterface {
  // TODO: Implement methods when needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: true,
      statusCode: 200,
      message: 'Mock implementation',
      data: [],
    ));
  }
}

/// Mock User Repository - Simplified implementation
class MockUserRepository implements UserRepositoryInterface {
  // TODO: Implement methods when needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: true,
      statusCode: 200,
      message: 'Mock implementation',
      data: null,
    ));
  }
}

/// Mock Chat Repository - Simplified implementation
class MockChatRepository implements ChatRepositoryInterface {
  // TODO: Implement methods when needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: true,
      statusCode: 200,
      message: 'Mock implementation',
      data: [],
    ));
  }
}

/// Mock Location Repository - Simplified implementation
class MockLocationRepository implements LocationRepositoryInterface {
  // TODO: Implement methods when needed
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return Future.value(ApiResponse(
      success: true,
      statusCode: 200,
      message: 'Mock implementation',
      data: null,
    ));
  }
}
