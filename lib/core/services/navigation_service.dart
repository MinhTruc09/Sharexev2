import 'package:flutter/material.dart';
import 'package:sharexev2/routes/app_routes.dart';

/// A centralized navigation service that provides type-safe navigation methods
/// and proper argument handling throughout the app.
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Navigate to a named route
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and replace the current route
  Future<T?> navigateToReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Navigate to a named route and clear the navigation stack
  Future<T?> navigateToAndClear<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to a named route and remove routes until a predicate is met
  Future<T?> navigateToAndRemoveUntil<T extends Object?>(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Go back to the previous route
  void goBack<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  /// Check if navigation can go back
  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  // MARK: - Common Routes

  /// Navigate to splash screen
  Future<T?> navigateToSplash<T extends Object?>() {
    return navigateTo<T>(AppRoute.splash);
  }

  /// Navigate to onboarding screen
  Future<T?> navigateToOnboarding<T extends Object?>() {
    return navigateTo<T>(AppRoute.onboarding);
  }

  /// Navigate to role selection screen
  Future<T?> navigateToRoleSelection<T extends Object?>() {
    return navigateTo<T>(AppRoute.roleSelection);
  }

  // MARK: - Auth Routes

  /// Navigate to login screen
  Future<T?> navigateToLogin<T extends Object?>({
    String role = 'PASSENGER',
  }) {
    return AppRoute.navigateToLogin<T>(
      navigatorKey.currentContext!,
      role: role,
    );
  }

  /// Navigate to register screen
  Future<T?> navigateToRegister<T extends Object?>({
    String role = 'PASSENGER',
  }) {
    return AppRoute.navigateToRegister<T>(
      navigatorKey.currentContext!,
      role: role,
    );
  }

  // MARK: - Passenger Routes

  /// Navigate to passenger home screen
  Future<T?> navigateToPassengerHome<T extends Object?>() {
    return navigateTo<T>(AppRoute.homePassenger);
  }

  /// Navigate to passenger profile screen
  Future<T?> navigateToPassengerProfile<T extends Object?>() {
    return navigateTo<T>(AppRoute.passengerProfile);
  }

  /// Navigate to passenger bookings screen
  Future<T?> navigateToPassengerBookings<T extends Object?>() {
    return navigateTo<T>(AppRoute.passengerBookings);
  }

  /// Navigate to passenger trip history screen
  Future<T?> navigateToPassengerTripHistory<T extends Object?>() {
    return navigateTo<T>(AppRoute.passengerTripHistory);
  }

  // MARK: - Driver Routes

  /// Navigate to driver home screen
  Future<T?> navigateToDriverHome<T extends Object?>() {
    return navigateTo<T>(AppRoute.homeDriver);
  }

  /// Navigate to driver profile screen
  Future<T?> navigateToDriverProfile<T extends Object?>() {
    return navigateTo<T>(AppRoute.driverProfile);
  }

  /// Navigate to create ride screen
  Future<T?> navigateToCreateRide<T extends Object?>() {
    return navigateTo<T>(AppRoute.createRide);
  }

  /// Navigate to my rides screen
  Future<T?> navigateToMyRides<T extends Object?>() {
    return navigateTo<T>(AppRoute.myRides);
  }

  /// Navigate to driver bookings screen
  Future<T?> navigateToDriverBookings<T extends Object?>() {
    return navigateTo<T>(AppRoute.driverBookings);
  }

  /// Navigate to driver ride details screen
  Future<T?> navigateToDriverRideDetails<T extends Object?>({
    required Map<String, dynamic> rideData,
  }) {
    return AppRoute.navigateToDriverRideDetails<T>(
      navigatorKey.currentContext!,
      rideData: rideData,
    );
  }

  // MARK: - Chat Routes

  /// Navigate to chat rooms screen
  Future<T?> navigateToChatRooms<T extends Object?>() {
    return navigateTo<T>(AppRoute.chatRooms);
  }

  /// Navigate to chat room screen
  Future<T?> navigateToChat<T extends Object?>({
    required String roomId,
    required String participantName,
    String? participantEmail,
  }) {
    return AppRoute.navigateToChat<T>(
      navigatorKey.currentContext!,
      roomId: roomId,
      participantName: participantName,
      participantEmail: participantEmail,
    );
  }

  // MARK: - Trip Routes

  /// Navigate to trip detail screen
  Future<T?> navigateToTripDetail<T extends Object?>({
    required Map<String, dynamic> tripData,
  }) {
    return AppRoute.navigateToTripDetail<T>(
      navigatorKey.currentContext!,
      tripData: tripData,
    );
  }

  /// Navigate to trip review screen
  Future<T?> navigateToTripReview<T extends Object?>({
    required Map<String, dynamic> tripData,
    String role = 'PASSENGER',
  }) {
    return AppRoute.navigateToTripReview<T>(
      navigatorKey.currentContext!,
      tripData: tripData,
      role: role,
    );
  }

  // MARK: - Notification Routes

  /// Navigate to notification details screen
  Future<T?> navigateToNotificationDetails<T extends Object?>() {
    return navigateTo<T>(AppRoute.notificationDetails);
  }

  // MARK: - Demo Routes

  /// Navigate to booking widgets demo screen
  Future<T?> navigateToBookingDemo<T extends Object?>({
    String role = 'PASSENGER',
  }) {
    return navigateTo<T>(AppRoute.bookingDemo, arguments: role);
  }

  // MARK: - Utility Methods

  /// Navigate to home based on user role
  Future<T?> navigateToHome<T extends Object?>(String role) {
    switch (role.toUpperCase()) {
      case 'DRIVER':
        return navigateToDriverHome<T>();
      case 'PASSENGER':
      default:
        return navigateToPassengerHome<T>();
    }
  }

  /// Navigate to profile based on user role
  Future<T?> navigateToProfile<T extends Object?>(String role) {
    switch (role.toUpperCase()) {
      case 'DRIVER':
        return navigateToDriverProfile<T>();
      case 'PASSENGER':
      default:
        return navigateToPassengerProfile<T>();
    }
  }

  /// Clear navigation stack and navigate to home
  Future<T?> navigateToHomeAndClear<T extends Object?>(String role) {
    switch (role.toUpperCase()) {
      case 'DRIVER':
        return navigateToAndClear<T>(AppRoute.homeDriver);
      case 'PASSENGER':
      default:
        return navigateToAndClear<T>(AppRoute.homePassenger);
    }
  }

  /// Clear navigation stack and navigate to login
  Future<T?> navigateToLoginAndClear<T extends Object?>({
    String role = 'PASSENGER',
  }) {
    return navigateToAndClear<T>(
      AppRoute.login,
      arguments: role,
    );
  }
}
