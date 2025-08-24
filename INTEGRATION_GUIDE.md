# Hướng Dẫn Tích Hợp Widget Demo Vào Ứng Dụng ShareXe

## Tổng Quan

Tài liệu này mô tả cách tích hợp các widget demo vào các trang thực tế của ứng dụng ShareXe, tạo ra trải nghiệm người dùng hoàn chỉnh và chức năng đầy đủ.

## Các Trang Đã Được Tích Hợp

### 1. Trang Chi Tiết Chuyến Đi (`TripDetailPage`)

**Vị trí**: `lib/presentation/pages/trip/trip_detail_page.dart`

**Tính năng tích hợp**:
- **Bản đồ tương tác**: Hiển thị tuyến đường với khả năng zoom in/out
- **Thông tin chuyến đi**: Điểm đi, điểm đến, thời gian, giá vé, số ghế
- **Widget chọn chỗ ngồi**: Sử dụng `VehicleSeatSelection` từ demo
- **Floating button đặt chuyến**: Với trạng thái loading và xác nhận
- **Driver avatar button**: Floating button với avatar tài xế để chat

**Cách sử dụng**:
```dart
Navigator.pushNamed(
  context,
  AppRoute.tripDetail,
  arguments: tripData,
);
```

### 2. Trang Hồ Sơ Cá Nhân (`ProfilePage`)

**Vị trí**: `lib/presentation/pages/profile/profile_page.dart`

**Tính năng tích hợp**:
- **Widget avatar picker**: Sử dụng `ProfileAvatarPicker` từ demo
- **Chỉnh sửa thông tin cá nhân**: Toggle edit mode
- **Cài đặt ứng dụng**: Thông báo, bảo mật, ngôn ngữ, trợ giúp

**Cách sử dụng**:
```dart
Navigator.pushNamed(
  context,
  AppRoute.profile,
  arguments: 'PASSENGER', // hoặc 'DRIVER'
);
```

### 3. Trang Đánh Giá Chuyến Đi (`TripReviewPage`)

**Vị trí**: `lib/presentation/pages/trip/trip_review_page.dart`

**Tính năng tích hợp**:
- **Widget đánh giá**: Sử dụng `TripReviewStepper` từ demo
- **Tóm tắt chuyến đi**: Thông tin chi tiết về chuyến đi đã hoàn thành
- **Xác nhận đánh giá**: Hiển thị kết quả sau khi đánh giá

**Cách sử dụng**:
```dart
Navigator.pushNamed(
  context,
  AppRoute.tripReview,
  arguments: {
    'tripData': tripData,
    'role': 'PASSENGER',
  },
);
```

## Các Widget Demo Đã Được Tích Hợp

### 1. VehicleSeatSelection
- **Sử dụng trong**: `TripDetailPage`
- **Chức năng**: Chọn chỗ ngồi cho xe hơi, xe van, xe bus
- **Tính năng**: Hiển thị ghế đã đặt, tính tổng tiền

### 2. ProfileAvatarPicker
- **Sử dụng trong**: `ProfilePage`
- **Chức năng**: Chọn và cập nhật ảnh đại diện
- **Tính năng**: Hỗ trợ upload ảnh, hiển thị initials

### 3. TripReviewStepper
- **Sử dụng trong**: `TripReviewPage`
- **Chức năng**: Đánh giá chuyến đi theo từng bước
- **Tính năng**: Rating, tags, comment, recommend

## Cách Tích Hợp Vào Trang Chủ

### 1. Cập Nhật TripCard
Trong `new_home_passenger_page.dart`, các card chuyến đi giờ có thể bấm vào để xem chi tiết:

```dart
TripCard(
  tripData: _nearbyTrips[index],
  role: 'PASSENGER',
  onTap: () {
    Navigator.pushNamed(
      context,
      AppRoute.tripDetail,
      arguments: _nearbyTrips[index],
    );
  },
),
```

### 2. Cập Nhật Drawer
Drawer của trang chủ có link đến trang profile:

```dart
ListTile(
  leading: const Icon(Icons.person),
  title: const Text('Hồ sơ'),
  onTap: () {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      AppRoute.profile,
      arguments: 'PASSENGER',
    );
  },
),
```

## Các Route Mới

### 1. Trip Detail Route
```dart
AppRoute.tripDetail: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  return TripDetailPage(tripData: args ?? {});
},
```

### 2. Trip Review Route
```dart
AppRoute.tripReview: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  return TripReviewPage(
    tripData: args?['tripData'] ?? {},
    role: args?['role'] ?? 'PASSENGER',
  );
},
```

### 3. Profile Route
```dart
AppRoute.profile: (context) {
  final args = ModalRoute.of(context)!.settings.arguments as String?;
  return ProfilePage(role: args ?? 'PASSENGER');
},
```

## Tích Hợp BLoC

### 1. MapBloc
- **Provider**: Được thêm vào `App` widget
- **Sử dụng trong**: `TripDetailPage` để quản lý trạng thái bản đồ
- **States**: `MapInitial`, `MapLoading`, `MapTripDetailLoaded`

### 2. ChatCubit
- **Provider**: Được thêm vào `App` widget
- **Sử dụng trong**: Tất cả các trang chat
- **States**: `ChatStatus.loading`, `ChatStatus.loaded`, `ChatStatus.error`

### 3. TripDetailCubit
- **Provider**: Được thêm vào `App` widget và `TripDetailPage`
- **Sử dụng trong**: `TripDetailPage` để quản lý state chọn chỗ ngồi và đặt chuyến
- **States**: `TripDetailStatus.initial`, `TripDetailStatus.loaded`, `TripDetailStatus.booking`, `TripDetailStatus.bookingSuccess`, `TripDetailStatus.navigateToReview`, `TripDetailStatus.error`

### 4. TripReviewCubit
- **Provider**: Được thêm vào `App` widget và `TripReviewPage`
- **Sử dụng trong**: `TripReviewPage` để quản lý state đánh giá chuyến đi
- **States**: `TripReviewStatus.initial`, `TripReviewStatus.loaded`, `TripReviewStatus.submitting`, `TripReviewStatus.submitted`, `TripReviewStatus.error`

### 5. ProfileCubit
- **Provider**: Được thêm vào `App` widget và `ProfilePage`
- **Sử dụng trong**: `ProfilePage` để quản lý state chỉnh sửa thông tin cá nhân
- **States**: `ProfileStatus.initial`, `ProfileStatus.loaded`, `ProfileStatus.saving`, `ProfileStatus.saved`, `ProfileStatus.error`

## Hướng Dẫn Sử Dụng

### 1. Xem Chi Tiết Chuyến Đi
1. Từ trang chủ, bấm vào bất kỳ card chuyến đi nào
2. Trang chi tiết sẽ hiển thị với bản đồ và thông tin đầy đủ
3. Chọn chỗ ngồi mong muốn
4. Bấm "Đặt chuyến" để xác nhận

### 2. Chat Với Tài Xế
1. Trong trang chi tiết chuyến đi, bấm vào avatar tài xế (floating button)
2. Chọn "Nhắn tin" để mở chat
3. Hoặc bấm vào icon chat trong thông tin tài xế

### 3. Cập Nhật Hồ Sơ
1. Từ drawer, chọn "Hồ sơ"
2. Bấm icon edit để chỉnh sửa
3. Cập nhật thông tin và bấm "Lưu thay đổi"

### 4. Đánh Giá Chuyến Đi
1. Sau khi hoàn thành chuyến đi, chọn "Đánh giá ngay"
2. Điền rating, tags, comment theo hướng dẫn
3. Xác nhận đánh giá

## Lưu Ý Kỹ Thuật

### 1. State Management
- Tất cả các trang đều sử dụng BLoC pattern
- State được quản lý tập trung và nhất quán
- Có thể dễ dàng mở rộng và maintain

### 2. Navigation
- Sử dụng named routes với arguments
- Navigation stack được quản lý tốt
- Có thể quay lại trang trước đó

### 3. UI/UX
- Theme nhất quán theo role (PASSENGER/DRIVER)
- Responsive design cho các kích thước màn hình
- Loading states và error handling đầy đủ

## Kết Luận

Việc tích hợp các widget demo vào ứng dụng đã tạo ra một hệ thống hoàn chỉnh với:
- **Trải nghiệm người dùng mượt mà** từ trang chủ đến chi tiết
- **Chức năng đầy đủ** cho việc đặt chuyến, chat, đánh giá
- **Code structure rõ ràng** dễ maintain và mở rộng
- **Tích hợp BLoC pattern hoàn hảo** nhất quán trong toàn bộ ứng dụng

**Tất cả các trang mới đều tuân thủ BLoC pattern:**
- ✅ `TripDetailPage` sử dụng `TripDetailCubit`
- ✅ `ProfilePage` sử dụng `ProfileCubit`  
- ✅ `TripReviewPage` sử dụng `TripReviewCubit`
- ✅ State management tập trung và nhất quán
- ✅ Separation of concerns rõ ràng
- ✅ Dễ dàng test và maintain

**Refactor thành các Widget riêng biệt:**
- ✅ **TripDetailPage**: Tách thành `TripMapSection`, `TripInfoSection`, `TripSeatSelectionSection`, `TripBookingButton`
- ✅ **ProfilePage**: Tách thành `ProfileHeader`, `ProfileInfoSection`, `ProfileSettingsSection`
- ✅ **TripReviewPage**: Tách thành `TripSummarySection`, `TripReviewSection`
- ✅ **Tái sử dụng**: Các widget có thể dùng lại ở nhiều nơi khác nhau
- ✅ **Maintainability**: Code ngắn gọn, dễ đọc và sửa đổi
- ✅ **Modularity**: Mỗi widget có trách nhiệm riêng biệt

Các widget demo giờ đây không chỉ là demo mà đã trở thành các component thực tế, tạo ra giá trị thực sự cho người dùng cuối, đồng thời duy trì kiến trúc BLoC pattern chuẩn mực của project và được tổ chức theo cách modular, dễ tái sử dụng.
