# 🚀 CÁCH SỬ DỤNG CLEAN ARCHITECTURE

## 📋 **SETUP TRONG MAIN.DART**

```dart
import 'package:flutter/material.dart';
import 'core/app_registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize toàn bộ hệ thống
  await AppRegistry.I.initialize();
  
  // Optional: Run system tests
  await AppRegistry.I.runSystemTests();
  
  runApp(MyApp());
}
```

## 🎯 **SỬ DỤNG TRONG UI (BLoC/CUBIT)**

### **1. Ride Management**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_registry.dart';
import '../data/models/ride/entities/ride_entity.dart';

class RideCubit extends Cubit<RideState> {
  RideCubit() : super(RideInitial());

  /// Tạo chuyến đi mới
  Future<void> createRide({
    required String departure,
    required String destination,
    required DateTime startTime,
    required double pricePerSeat,
    required int totalSeats,
  }) async {
    emit(RideLoading());
    
    try {
      final result = await AppRegistry.I.rideUseCases.createRide(
        departure: departure,
        destination: destination,
        startLat: 21.0285, // From location picker
        startLng: 105.8542,
        startAddress: 'Hà Nội',
        startWard: 'Phường 1',
        startDistrict: 'Quận Ba Đình',
        startProvince: 'Hà Nội',
        endLat: 10.8231,
        endLng: 106.6297,
        endAddress: 'TP.HCM',
        endWard: 'Phường 1',
        endDistrict: 'Quận 1',
        endProvince: 'TP.HCM',
        startTime: startTime,
        pricePerSeat: pricePerSeat,
        totalSeats: totalSeats,
        driverName: 'Current User Name',
        driverEmail: 'user@email.com',
      );
      
      if (result.success && result.data != null) {
        emit(RideCreated(result.data!));
      } else {
        emit(RideError(result.message));
      }
    } catch (e) {
      emit(RideError('Lỗi tạo chuyến đi: $e'));
    }
  }

  /// Tìm kiếm chuyến đi
  Future<void> searchRides({
    String? departure,
    String? destination,
    int? minSeats,
    double? maxPrice,
  }) async {
    emit(RideLoading());
    
    try {
      final result = await AppRegistry.I.rideUseCases.searchRides(
        departure: departure,
        destination: destination,
        minSeats: minSeats,
        maxPrice: maxPrice,
      );
      
      if (result.success) {
        emit(RideSearchResults(result.data ?? []));
      } else {
        emit(RideError(result.message));
      }
    } catch (e) {
      emit(RideError('Lỗi tìm kiếm: $e'));
    }
  }

  /// Lấy chuyến đi gợi ý
  Future<void> getRecommendedRides() async {
    emit(RideLoading());
    
    try {
      final result = await AppRegistry.I.rideUseCases.getRecommendedRides(
        userLocation: 'Hà Nội',
        requiredSeats: 1,
      );
      
      if (result.success) {
        emit(RideRecommendations(result.data ?? []));
      } else {
        emit(RideError(result.message));
      }
    } catch (e) {
      emit(RideError('Lỗi lấy gợi ý: $e'));
    }
  }
}

// States
abstract class RideState {}
class RideInitial extends RideState {}
class RideLoading extends RideState {}
class RideCreated extends RideState {
  final RideEntity ride;
  RideCreated(this.ride);
}
class RideSearchResults extends RideState {
  final List<RideEntity> rides;
  RideSearchResults(this.rides);
}
class RideRecommendations extends RideState {
  final List<RideEntity> rides;
  RideRecommendations(this.rides);
}
class RideError extends RideState {
  final String message;
  RideError(this.message);
}
```

### **2. Booking Management**

```dart
class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingInitial());

  /// Đặt chỗ
  Future<void> createBooking({
    required int rideId,
    required int seats,
  }) async {
    emit(BookingLoading());
    
    try {
      final result = await AppRegistry.I.bookingUseCases.createBooking(
        rideId: rideId,
        seats: seats,
        passengerId: 1, // Current user ID
      );
      
      if (result.success && result.data != null) {
        emit(BookingCreated(result.data!));
      } else {
        emit(BookingError(result.message));
      }
    } catch (e) {
      emit(BookingError('Lỗi đặt chỗ: $e'));
    }
  }

  /// Hủy đặt chỗ
  Future<void> cancelBooking({
    required int bookingId,
    required int rideId,
  }) async {
    emit(BookingLoading());
    
    try {
      final result = await AppRegistry.I.bookingUseCases.cancelBooking(
        bookingId: bookingId,
        rideId: rideId,
      );
      
      if (result.success) {
        emit(BookingCancelled());
      } else {
        emit(BookingError(result.message));
      }
    } catch (e) {
      emit(BookingError('Lỗi hủy đặt chỗ: $e'));
    }
  }

  /// Lấy lịch sử đặt chỗ
  Future<void> getBookingHistory() async {
    emit(BookingLoading());
    
    try {
      final result = await AppRegistry.I.bookingUseCases.getBookingHistory();
      
      if (result.success) {
        final stats = AppRegistry.I.bookingUseCases.calculateBookingStats(
          result.data ?? []
        );
        emit(BookingHistory(result.data ?? [], stats));
      } else {
        emit(BookingError(result.message));
      }
    } catch (e) {
      emit(BookingError('Lỗi lấy lịch sử: $e'));
    }
  }
}
```

### **3. User Management**

```dart
class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  /// Cập nhật thông tin cá nhân
  Future<void> updateProfile({
    required String phone,
    required String fullName,
    required String licensePlate,
    required String brand,
    required String model,
    required String color,
    required int numberOfSeats,
  }) async {
    emit(UserLoading());
    
    try {
      final result = await AppRegistry.I.userUseCases.updateProfile(
        phone: phone,
        fullName: fullName,
        licensePlate: licensePlate,
        brand: brand,
        model: model,
        color: color,
        numberOfSeats: numberOfSeats,
      );
      
      if (result.success) {
        emit(UserProfileUpdated());
      } else {
        emit(UserError(result.message));
      }
    } catch (e) {
      emit(UserError('Lỗi cập nhật: $e'));
    }
  }

  /// Thay đổi mật khẩu
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(UserLoading());
    
    try {
      final result = await AppRegistry.I.userUseCases.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (result.success) {
        emit(UserPasswordChanged());
      } else {
        emit(UserError(result.message));
      }
    } catch (e) {
      emit(UserError('Lỗi thay đổi mật khẩu: $e'));
    }
  }
}
```

## 🧪 **TESTING**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/core/app_registry.dart';

void main() {
  group('Ride Use Cases Tests', () {
    test('should create ride with valid data', () async {
      // Arrange
      await AppRegistry.I.initialize();
      
      // Act
      final result = await AppRegistry.I.rideUseCases.createRide(
        departure: 'Hà Nội',
        destination: 'TP.HCM',
        startLat: 21.0285,
        startLng: 105.8542,
        // ... other params
      );
      
      // Assert
      expect(result.success, true);
      expect(result.data, isNotNull);
    });
  });
}
```

## 📊 **SYSTEM STATUS**

```dart
// Kiểm tra trạng thái hệ thống
final status = AppRegistry.I.getSystemStatus();
print('System Status: $status');

// Output:
// {
//   'initialized': true,
//   'services': { 'apiClient': true, ... },
//   'repositories': { 'rideRepository': 'available', ... },
//   'useCases': { 'rideUseCases': 'available', ... }
// }
```

## 🎯 **BENEFITS**

- ✅ **Type-safe**: Tất cả entities có type checking
- ✅ **Business logic centralized**: Validation & rules trong Use Cases
- ✅ **Easy testing**: Mock repositories dễ dàng
- ✅ **Clean separation**: UI không biết về DTOs/APIs
- ✅ **Scalable**: Dễ thêm features mới
