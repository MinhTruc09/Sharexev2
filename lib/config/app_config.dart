import 'package:sharexev2/config/env.dart';
import 'package:sharexev2/config/environment.dart';

///  AppConfig
///
/// Build endpoint URL dựa vào Env
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  static AppConfig get I => _instance;

  /// Base API - Using Environment config
  String get baseUrl => Environment.apiBaseUrl;
  String get apiVersion => Env.apiVersion;

  /// Helper build endpoint (API doc không dùng version prefix)
  String _ep(String path) => "$baseUrl$path";

  /// ========== AUTH ==========
  final auth = _AuthEndpoints();

  /// ========== USER ==========
  final user = _UserEndpoints();

  /// ========== RIDES ==========
  final rides = _RideEndpoints();

  /// ========== PASSENGER ==========
  final passenger = _PassengerEndpoints();

  /// ========== DRIVER ==========
  final driver = _DriverEndpoints();

  /// ========== CHAT ==========
  final chat = _ChatEndpoints();

  /// ========== NOTIFICATIONS ==========
  final notifications = _NotificationEndpoints();

  /// ========== TRACKING ==========
  final tracking = _TrackingEndpoints();

  /// ========== ADMIN ==========
  final admin = _AdminEndpoints();

  /// WebSocket URL - Using Environment config
  String get webSocketUrl => Environment.websocketUrl;

  /// Cloudinary
  String get cloudinaryCloudName => Env.cloudinaryCloudName;
  String get cloudinaryApiKey => Env.cloudinaryApiKey;
  String get cloudinaryApiSecret => Env.cloudinaryApiSecret;

  /// Firebase / FCM
  bool get enableFirebase => Env.enableFirebase;
  String get fcmServerKey => Env.fcmServerKey;
}

// ================== Endpoints ==================
class _AuthEndpoints {
  String get login => AppConfig.I._ep("/auth/login");
  String get registerPassenger => AppConfig.I._ep("/auth/passenger-register");
  String get registerDriver => AppConfig.I._ep("/auth/driver-register");
  String get refresh => AppConfig.I._ep("/auth/refresh");
  String get googleSignIn => AppConfig.I._ep("/auth/google-signin");
  String get logout => AppConfig.I._ep("/auth/logout");
  String get verify => AppConfig.I._ep("/auth/verify");
  String get profile => AppConfig.I._ep("/auth/profile");
  String get changePassword => AppConfig.I._ep("/auth/change-password");
  String get registerDevice => AppConfig.I._ep("/auth/device/register");
  String get unregisterDevice => AppConfig.I._ep("/auth/device/unregister");
}

class _UserEndpoints {
  String get profile => AppConfig.I._ep("/user/profile");
  String get updateProfile => AppConfig.I._ep("/user/update-profile");
  String get changePassword => AppConfig.I._ep("/user/change-pass");
}

class _RideEndpoints {
  String get getRide => AppConfig.I._ep("/ride/"); // + {id}
  String get search => AppConfig.I._ep("/ride/search");
  String get available => AppConfig.I._ep("/ride/available");
  String get all => AppConfig.I._ep("/ride/all-rides");
  String get create => AppConfig.I._ep("/ride");
  String get update => AppConfig.I._ep("/ride/update/"); // + {id}
  String get cancel => AppConfig.I._ep("/ride/cancel/"); // + {id}
}

class _PassengerEndpoints {
  String get profile => AppConfig.I._ep("/passenger/profile");
  String get bookings => AppConfig.I._ep("/passenger/bookings");
  String get bookingDetail =>
      AppConfig.I._ep("/passenger/booking/"); // + {bookingId}
  String get createBooking =>
      AppConfig.I._ep("/passenger/booking/"); // + {rideId}
  String get confirmRide =>
      AppConfig.I._ep("/passenger/passenger-confirm/"); // + {rideId}
  String get cancelBooking =>
      AppConfig.I._ep("/passenger/cancel-bookings/"); // + {rideId}
}

class _DriverEndpoints {
  String get profile => AppConfig.I._ep("/driver/profile");
  String get myRides => AppConfig.I._ep("/driver/my-rides");
  String get bookings => AppConfig.I._ep("/driver/bookings");
  String get rejectBooking =>
      AppConfig.I._ep("/driver/reject/"); // + {bookingId}
  String get acceptBooking =>
      AppConfig.I._ep("/driver/accept/"); // + {bookingId}
  String get completeRide => AppConfig.I._ep("/driver/complete/"); // + {rideId}
}

class _ChatEndpoints {
  String get messages => AppConfig.I._ep("/chat/"); // + {roomId}
  String get rooms => AppConfig.I._ep("/chat/rooms");
  String get roomByUser => AppConfig.I._ep("/chat/room/"); // + {otherUserEmail}
  String get sendTest => AppConfig.I._ep("/chat/test/"); // + {roomId}
  String get markRead => AppConfig.I._ep("/chat/"); // + {roomId}/mark-read
}

class _NotificationEndpoints {
  String get all => AppConfig.I._ep("/notifications");
  String get unreadCount => AppConfig.I._ep("/notifications/unread-count");
  String get markRead => AppConfig.I._ep("/notifications/"); // + {id}/read
  String get markAllRead => AppConfig.I._ep("/notifications/read-all");
}

class _TrackingEndpoints {
  String get sendTest => AppConfig.I._ep("/tracking/test/"); // + {rideId}
}

class _AdminEndpoints {
  String get usersByRole => AppConfig.I._ep("/admin/user/role");
  String get userDetail => AppConfig.I._ep("/admin/user/"); // + {id}
  String get approveUser => AppConfig.I._ep("/admin/user/approved/"); // + {id}
  String get rejectUser => AppConfig.I._ep("/admin/user/reject/"); // + {id}
  String get deleteUser => AppConfig.I._ep("/admin/user/delete/"); // + {id}
}
