import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/data/services/auth_service.dart';
import 'package:sharexev2/data/services/booking_service.dart';
import 'package:sharexev2/data/services/chat_service.dart';
import 'package:sharexev2/data/services/cloudinary_service.dart';
import 'package:sharexev2/data/services/fcm_service.dart';
import 'package:sharexev2/data/services/firebase_service.dart';
import 'package:sharexev2/data/services/google_signin_service.dart';
import 'package:sharexev2/data/services/location_service.dart';
import 'package:sharexev2/data/services/notification_service.dart';
import 'package:sharexev2/data/services/ride_service.dart';
import 'package:sharexev2/data/services/ride_service_impl.dart';
import 'package:sharexev2/data/services/user_service.dart';
import 'package:sharexev2/data/services/websocket_service.dart';

/// Service Registry - Quản lý tất cả services trong app
class ServiceRegistry {
  static final ServiceRegistry _instance = ServiceRegistry._internal();
  factory ServiceRegistry() => _instance;
  ServiceRegistry._internal();

  // Core services
  late final ApiClient _apiClient = ApiClient();
  late final FirebaseService _firebaseService = FirebaseService();
  late final FCMService _fcmService = FCMService();
  late final GoogleSignInService _googleSignInService = GoogleSignInService();

  // Feature services
  late final AuthService _authService = AuthService(_apiClient);
  late final UserService _userService = UserService();
  late final RideService _rideService = RideServiceImpl();
  late final BookingService _bookingService = BookingService();
  late final ChatService _chatService = ChatService();
  late final WebSocketService _webSocketService = WebSocketService();
  late final LocationService _locationService = LocationService();
  late final NotificationService _notificationService = NotificationService();
  late final CloudinaryService _cloudinaryService = CloudinaryService();

  // Getters
  ApiClient get apiClient => _apiClient;
  FirebaseService get firebaseService => _firebaseService;
  FCMService get fcmService => _fcmService;
  GoogleSignInService get googleSignInService => _googleSignInService;
  
  AuthService get authService => _authService;
  UserService get userService => _userService;
  RideService get rideService => _rideService;
  BookingService get bookingService => _bookingService;
  ChatService get chatService => _chatService;
  WebSocketService get webSocketService => _webSocketService;
  LocationService get locationService => _locationService;
  NotificationService get notificationService => _notificationService;
  CloudinaryService get cloudinaryService => _cloudinaryService;

  /// Initialize all services
  Future<void> initialize() async {
    try {
      // Initialize Firebase first
      await FirebaseService.initialize();
      
      // Initialize FCM
      await _fcmService.initialize();
      
      // Initialize location service
      await _locationService.initialize();
      
      print('✅ All services initialized successfully');
    } catch (e) {
      print('❌ Error initializing services: $e');
    }
  }

  /// Dispose all services
  void dispose() {
    _webSocketService.disconnect();
    _locationService.dispose();
    print('🔌 All services disposed');
  }

  /// Get service status
  Map<String, bool> getServiceStatus() {
    return {
      'Firebase': FirebaseService.isAvailable,
      'FCM': true, // FCM is always available if Firebase is available
      'Location': _locationService.currentPosition != null,
      'WebSocket': _webSocketService.isConnected,
      'API Client': true, // API client is always available
    };
  }

  /// Check if all required services are ready
  bool get isReady {
    final status = getServiceStatus();
    return status.values.every((ready) => ready);
  }
}

/// Global service registry instance
final serviceRegistry = ServiceRegistry();
