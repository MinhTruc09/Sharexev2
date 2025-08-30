import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/app.dart';
import 'package:sharexev2/core/services/navigation_service.dart';
import 'package:sharexev2/data/services/firebase_api.dart';
import 'package:sharexev2/data/services/firebase_service.dart';
import 'package:sharexev2/data/repositories/auth/auth_api_repository.dart';
import 'package:sharexev2/data/services/service_registry.dart';
import 'package:sharexev2/core/network/api_client.dart';
// auth repository interfaces are used by specific modules when needed
import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/firebase_options.dart';

// Global navigation service instance
final NavigationService navigationService = NavigationService();

// Required for handling background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Ensure Firebase is initialized
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Handling a background message: ${message.messageId}");
  } catch (e) {
    debugPrint("Error handling background message: $e");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations for better performance
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase with error handling
  await _initializeFirebase();

  // Initialize Service Registry (DI)
  await ServiceRegistry.I.initialize();

  // Get shared preferences for first open check
  final prefs = await SharedPreferences.getInstance();
  final isFirstOpen = prefs.getBool('isFirstOpen') ?? true;

  runApp(App(isFirstOpen: isFirstOpen));
}

// Extract Firebase initialization to a separate method
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    // Initialize Firebase services
    await FirebaseService.initialize();

    // Wire ApiClient token providers to the AuthManager singleton
    final authManager = AuthManager();
    await authManager.init();

    ApiClient.tokenProvider = () async {
      try {
        return authManager.getToken();
      } catch (_) {
        return null;
      }
    };

    ApiClient.refreshTokenProvider = () async {
      try {
        final refresh = authManager.getRefreshToken();
        if (refresh == null) return false;

        // Try backend refresh via repository
        final svc = ServiceRegistry.I.apiClient;
        final repo = AuthApiRepository(AuthService(svc), AuthManager());
        try {
          await repo.refreshToken();
          return true;
        } catch (e) {
          await authManager.clearSession();
          return false;
        }
      } catch (_) {
        return false;
      }
    };

    // Initialize FCM notifications
    await FirebaseApi().initNotification();

    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: ${token?.substring(0, 10)}...');
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
    // Continue without Firebase if initialization fails
  }
}
