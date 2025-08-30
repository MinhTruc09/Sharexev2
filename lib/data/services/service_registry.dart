import 'package:sharexev2/data/services/auth/auth_service_interface.dart';
import 'package:sharexev2/data/services/auth/auth_api_service.dart';
import 'package:sharexev2/data/services/chat/chat_service_interface.dart';
import 'package:sharexev2/data/services/chat/chat_api_service.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_impl.dart';
import 'package:sharexev2/data/repositories/chat/chat_repository_interface.dart';
import 'package:sharexev2/data/repositories/chat/chat_repository_impl.dart';
import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/data/services/auth/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/data/services/tracking_service.dart';
import 'package:sharexev2/data/repositories/tracking/tracking_repository_interface.dart';
import 'package:sharexev2/data/repositories/tracking/tracking_repository_impl.dart';
import 'package:sharexev2/data/services/notification_service.dart';
import 'package:sharexev2/data/repositories/notification/notification_repository_interface.dart';
import 'package:sharexev2/data/repositories/notification/notification_repository_impl.dart';
import 'package:flutter/foundation.dart';

/// Service Registry - Dependency Injection Container
/// Quản lý tất cả services và repositories
class ServiceRegistry {
  static final ServiceRegistry _instance = ServiceRegistry._internal();
  factory ServiceRegistry() => _instance;
  ServiceRegistry._internal();

  static ServiceRegistry get I => _instance;

  // ===== API Client =====
  late final ApiClient _apiClient = ApiClient();

  // ===== Services =====
  late final AuthServiceInterface _authService = AuthApiService(_apiClient);
  late final ChatServiceInterface _chatService = ChatApiService(_apiClient);
  late final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  late final TrackingService _trackingService = TrackingService(_apiClient);
  late final NotificationService _notificationService = NotificationService(_apiClient);
  SharedPreferences? _prefs;

  // ===== Repositories =====
  late AuthRepositoryInterface _authRepository;
  late final ChatRepositoryInterface _chatRepository = ChatRepositoryImpl(
    _chatService,
  );
  late final TrackingRepositoryInterface _trackingRepository =
      TrackingRepositoryImpl(_trackingService);
  late final NotificationRepositoryInterface _notificationRepository =
      NotificationRepositoryImpl(_notificationService);

  // ===== Getters =====
  ApiClient get apiClient => _apiClient;
  AuthServiceInterface get authService => _authService;
  ChatServiceInterface get chatService => _chatService;
  TrackingService get trackingService => _trackingService;
  NotificationService get notificationService => _notificationService;
  AuthRepositoryInterface get authRepository => _authRepository;
  ChatRepositoryInterface get chatRepository => _chatRepository;
  TrackingRepositoryInterface get trackingRepository => _trackingRepository;
  NotificationRepositoryInterface get notificationRepository => _notificationRepository;

  // ===== Initialization =====
  Future<void> initialize() async {
    try {
      // Initialize shared preferences and repositories
      _prefs = await SharedPreferences.getInstance();
      _authRepository = AuthRepositoryImpl(
        authApiService: _authService,
        firebaseAuthService: _firebaseAuthService,
        prefs: _prefs!,
      );

      if (kDebugMode) {
        debugPrint('✅ ServiceRegistry initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ServiceRegistry initialization failed: $e');
      }
      rethrow;
    }
  }

  // ===== Cleanup =====
  Future<void> dispose() async {
    try {
      // No disposable resources at the moment
      if (kDebugMode) {
        debugPrint('✅ ServiceRegistry disposed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ServiceRegistry disposal failed: $e');
      }
    }
  }
}
