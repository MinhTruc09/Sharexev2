# 🔄 CUBIT INTEGRATION ANALYSIS

## 📊 **PHÂN TÍCH LUỒNG NGHIỆP VỤ HIỆN TẠI**

### 🎯 **TỔNG QUAN CUBITS**

| Cubit | Trạng thái | Service/Repo hiện tại | Có thể integrate |
|-------|------------|----------------------|------------------|
| `AuthCubit` | ✅ Hoàn chỉnh | `AuthService` | ✅ `AuthRepository` + `UserUseCases` |
| `HomePassengerCubit` | ⚠️ Mock data | `RideService` (mock) | ✅ `RideUseCases` + `BookingUseCases` |
| `HomeDriverCubit` | ❌ Empty | Không có | ✅ `DriverUseCases` + `RideUseCases` |
| `BookingCubit` | ⚠️ UI only | Không có | ✅ `BookingUseCases` |
| `RideCubit` | ❌ Empty | Không có | ✅ `RideUseCases` |
| `ProfileCubit` | ⚠️ Mock data | Không có | ✅ `UserUseCases` |
| `ChatCubit` | ✅ Hoàn chỉnh | `ChatRepository` | ✅ Đã tốt |
| `TripDetailCubit` | ⚠️ Mock data | Không có | ✅ `BookingUseCases` |

### 🔍 **CHI TIẾT TỪNG CUBIT**

#### **1. AuthCubit** ✅ **Sẵn sàng integrate**
```dart
// Hiện tại
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  
  Future<void> loginWithEmail(String email, String password, String role) async {
    final authResponse = await _authService.loginWithEmail(email, password, role);
    // ...
  }
}

// Có thể integrate với
- AuthRepository (đã có)
- UserUseCases (mới tạo)
```

#### **2. HomePassengerCubit** ⚠️ **Cần refactor**
```dart
// Hiện tại - sử dụng mock data
Future<void> init() async {
  final rideHistory = await _rideService.getRideHistory(); // Mock
  final nearbyTrips = await _loadNearbyTrips(); // Mock data
}

// Có thể integrate với
- RideUseCases.getRecommendedRides()
- BookingUseCases.getBookingHistory()
- UserUseCases.getPassengerProfile()
```

#### **3. HomeDriverCubit** ❌ **Cần implement hoàn toàn**
```dart
// Hiện tại - chỉ có skeleton
class HomeDriverCubit extends Cubit<HomeDriverState> {
  Future<void> init() async {
    // TODO: load driver profile, available rides, location
  }
}

// Cần integrate với
- DriverUseCases.getProfile()
- RideUseCases.getDriverRides()
- BookingUseCases.getDriverBookings()
```

#### **4. BookingCubit** ⚠️ **Chỉ có UI logic**
```dart
// Hiện tại - chỉ handle seat selection
void confirmBooking() {
  emit(state.copyWith(status: BookingStatus.confirmed));
}

// Cần integrate với
- BookingUseCases.createBooking()
- BookingUseCases.cancelBooking()
- BookingUseCases.getBookingHistory()
```

#### **5. RideCubit** ❌ **Empty - cần implement**
```dart
// Hiện tại - chỉ có skeleton
class RideCubit extends Cubit<RideState> {
  void createRide() {
    // Implementation for creating a ride
  }
}

// Cần integrate với
- RideUseCases.createRide()
- RideUseCases.searchRides()
- RideUseCases.cancelRide()
```

#### **6. ProfileCubit** ⚠️ **Mock data**
```dart
// Hiện tại - mock data
void _loadUserData() {
  emit(state.copyWith(userData: {
    'name': 'Nguyễn Văn A', // Mock
    'email': 'nguyenvana@example.com', // Mock
  }));
}

// Cần integrate với
- UserUseCases.getPassengerProfile()
- UserUseCases.getDriverProfile()
- UserUseCases.updateProfile()
```

### 🚀 **INTEGRATION PLAN**

#### **Phase 1: Core Business Logic (Ưu tiên cao)**

**1. HomePassengerCubit** - Luồng chính của passenger
```dart
class HomePassengerCubit extends Cubit<HomePassengerState> {
  final RideUseCases _rideUseCases;
  final BookingUseCases _bookingUseCases;
  final UserUseCases _userUseCases;

  Future<void> init() async {
    emit(state.copyWith(status: HomePassengerStatus.loading));
    
    try {
      // Load real data thay vì mock
      final [rideHistory, profile, recommendedRides] = await Future.wait([
        _bookingUseCases.getBookingHistory(),
        _userUseCases.getPassengerProfile(),
        _rideUseCases.getRecommendedRides(userLocation: 'current_location'),
      ]);
      
      emit(state.copyWith(
        status: HomePassengerStatus.ready,
        rideHistory: rideHistory.data ?? [],
        profile: profile.data,
        nearbyTrips: recommendedRides.data ?? [],
      ));
    } catch (e) {
      emit(state.copyWith(status: HomePassengerStatus.error, error: e.toString()));
    }
  }

  Future<void> searchRides({
    required String departure,
    required String destination,
    DateTime? startTime,
    int? seats,
  }) async {
    emit(state.copyWith(isSearching: true));
    
    try {
      final result = await _rideUseCases.searchRides(
        departure: departure,
        destination: destination,
        startDate: startTime,
        minSeats: seats,
      );
      
      emit(state.copyWith(
        isSearching: false,
        searchResults: result.data ?? [],
      ));
    } catch (e) {
      emit(state.copyWith(isSearching: false, error: e.toString()));
    }
  }

  Future<void> bookRide(int rideId, int seats) async {
    emit(state.copyWith(status: HomePassengerStatus.booking));
    
    try {
      final result = await _bookingUseCases.createBooking(
        rideId: rideId,
        seats: seats,
        passengerId: state.profile?.id ?? 0,
      );
      
      if (result.success) {
        emit(state.copyWith(
          status: HomePassengerStatus.rideBooked,
          currentBooking: result.data,
        ));
      } else {
        emit(state.copyWith(
          status: HomePassengerStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomePassengerStatus.error,
        error: 'Lỗi đặt chuyến: $e',
      ));
    }
  }
}
```

**2. HomeDriverCubit** - Luồng chính của driver
```dart
class HomeDriverCubit extends Cubit<HomeDriverState> {
  final DriverUseCases _driverUseCases;
  final RideUseCases _rideUseCases;
  final BookingUseCases _bookingUseCases;

  Future<void> init() async {
    emit(state.copyWith(status: HomeDriverStatus.loading));
    
    try {
      final [profile, myRides, bookings] = await Future.wait([
        _driverUseCases.getProfile(),
        _rideUseCases.getDriverRides(),
        _bookingUseCases.getDriverBookings(),
      ]);
      
      emit(state.copyWith(
        status: HomeDriverStatus.ready,
        profile: profile.data,
        myRides: myRides.data ?? [],
        pendingBookings: bookings.data ?? [],
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }

  Future<void> createRide(RideCreateParams params) async {
    emit(state.copyWith(status: HomeDriverStatus.creating));
    
    try {
      final result = await _rideUseCases.createRide(
        departure: params.departure,
        destination: params.destination,
        startTime: params.startTime,
        pricePerSeat: params.pricePerSeat,
        totalSeats: params.totalSeats,
        driverName: state.profile?.fullName ?? '',
        driverEmail: state.profile?.email ?? '',
      );
      
      if (result.success) {
        emit(state.copyWith(
          status: HomeDriverStatus.ready,
          myRides: [...state.myRides, result.data!],
        ));
      } else {
        emit(state.copyWith(
          status: HomeDriverStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomeDriverStatus.error,
        error: 'Lỗi tạo chuyến: $e',
      ));
    }
  }

  Future<void> acceptBooking(int bookingId) async {
    try {
      final result = await _bookingUseCases.acceptBooking(bookingId);
      
      if (result.success) {
        // Update local state
        final updatedBookings = state.pendingBookings
            .where((b) => b.id != bookingId)
            .toList();
        
        emit(state.copyWith(pendingBookings: updatedBookings));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi chấp nhận đặt chỗ: $e'));
    }
  }
}
```

**3. BookingCubit** - Luồng đặt chỗ
```dart
class BookingCubit extends Cubit<BookingState> {
  final BookingUseCases _bookingUseCases;

  Future<void> createBooking({
    required int rideId,
    required List<int> selectedSeats,
  }) async {
    emit(state.copyWith(status: BookingStatus.loading));
    
    try {
      final result = await _bookingUseCases.createBooking(
        rideId: rideId,
        seats: selectedSeats.length,
        passengerId: getCurrentUserId(),
      );
      
      if (result.success) {
        emit(state.copyWith(
          status: BookingStatus.confirmed,
          booking: result.data,
        ));
      } else {
        emit(state.copyWith(
          status: BookingStatus.error,
          error: result.message,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BookingStatus.error,
        error: 'Lỗi đặt chỗ: $e',
      ));
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      final result = await _bookingUseCases.cancelBooking(
        bookingId: bookingId,
        rideId: state.booking?.rideId ?? 0,
      );
      
      if (result.success) {
        emit(state.copyWith(
          status: BookingStatus.cancelled,
          booking: result.data,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Lỗi hủy đặt chỗ: $e'));
    }
  }
}
```

#### **Phase 2: Supporting Features (Ưu tiên trung bình)**

**4. ProfileCubit** - Quản lý profile
**5. RideCubit** - Quản lý rides
**6. TripDetailCubit** - Chi tiết chuyến đi

### 📋 **IMPLEMENTATION CHECKLIST**

#### **Immediate Actions:**
- [ ] Refactor HomePassengerCubit với RideUseCases + BookingUseCases
- [ ] Implement HomeDriverCubit với DriverUseCases
- [ ] Refactor BookingCubit với BookingUseCases
- [ ] Update ProfileCubit với UserUseCases

#### **Next Steps:**
- [ ] Create DriverUseCases (chưa có)
- [ ] Update app.dart với dependency injection
- [ ] Test integration với real APIs
- [ ] Remove mock data từ tất cả cubits

### 🎯 **EXPECTED BENEFITS**

- ✅ **Real data** thay vì mock data
- ✅ **Business logic validation** trong use cases
- ✅ **Error handling** chuẩn
- ✅ **Type-safe entities** trong UI
- ✅ **Testable architecture** với mock repositories
- ✅ **Consistent data flow** across app
