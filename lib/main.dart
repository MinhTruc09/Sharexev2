import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/app.dart';
import 'package:sharexev2/core/services/navigation_service.dart';
// TODO: Create these files when Firebase integration is needed
// import 'package:sharexev2/data/services/firebase_api.dart';
// import 'package:sharexev2/data/services/firebase_service.dart';
// import 'package:sharexev2/data/repositories/auth/auth_api_repository.dart';
import 'package:sharexev2/core/network/api_client.dart';
import 'package:sharexev2/core/auth/auth_refresh_coordinator.dart';
// auth repository interfaces are used by specific modules when needed
import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/core/di/service_locator.dart';
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

  // Initialize Dependency Injection
  await ServiceLocator.setup();

  // ServiceRegistry removed; using GetIt ServiceLocator only

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

    // TODO: Initialize Firebase services when implemented
    // await FirebaseService.initialize();

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
      // Delegate to centralized coordinator which uses ServiceLocator
      try {
        return await AuthRefreshCoordinator.tryRefresh();
      } catch (_) {
        return false;
      }
    };

    // TODO: Initialize FCM notifications when implemented
    // await FirebaseApi().initNotification();

    // TODO: Get FCM token when Firebase is setup
    // final token = await FirebaseMessaging.instance.getToken();
    // debugPrint('FCM Token: ${token?.substring(0, 10)}...');

    debugPrint('Firebase initialization skipped - not implemented yet');
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
    // Continue without Firebase if initialization fails
  }
}
