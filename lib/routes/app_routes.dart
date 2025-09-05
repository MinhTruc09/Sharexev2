import 'package:flutter/material.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';
import 'package:sharexev2/core/services/navigation_service.dart';

// Common pages
import 'package:sharexev2/views/screens/splash/main_splash_screen.dart';
import 'package:sharexev2/views/screens/onboarding/onboarding_screen.dart';
import 'package:sharexev2/views/screens/splash/role_splash_screen.dart';
// Auth pages - New implementation
import 'package:sharexev2/views/screens/auth/login_screen.dart';
import 'package:sharexev2/views/screens/auth/register_screen.dart';
import 'package:sharexev2/views/screens/auth/forgot_password_screen.dart';
// Common pages
import 'package:sharexev2/views/screens/common/role_selection_screen.dart';
// Chat pages - New implementation
import 'package:sharexev2/views/screens/chat/sharexe_chat_list_screen.dart';
import 'package:sharexev2/views/screens/chat/sharexe_chat_room_screen.dart';
// Passenger pages - New implementation
import 'package:sharexev2/views/screens/passenger/history_screen.dart';
import 'package:sharexev2/views/screens/passenger/favorites_screen.dart';
// Driver pages - New implementation
import 'package:sharexev2/views/screens/driver/driver_home_screen.dart';
import 'package:sharexev2/views/screens/driver/driver_notifications_screen.dart';
import 'package:sharexev2/views/screens/driver/driver_tracking_screen.dart';
import 'package:sharexev2/views/screens/driver/driver_review_screen.dart';
import 'package:sharexev2/views/screens/driver/driver_revenue_screen.dart';
import 'package:sharexev2/views/screens/driver/driver_history_screen.dart';
// Common pages - New implementation
import 'package:sharexev2/views/screens/common/notifications_screen.dart';
import 'package:sharexev2/views/screens/common/map_tracking_screen.dart';
import 'package:sharexev2/views/screens/common/ride_details_screen.dart';
// Driver pages - Additional
import 'package:sharexev2/views/screens/driver/create_ride_screen.dart';
// import 'package:sharexev2/presentation/pages/passenger/passenger_ride_page.dart';
// import 'package:sharexev2/presentation/pages/driver/driver_home_page.dart';
// import 'package:sharexev2/presentation/pages/profile/profile_page.dart';
// import 'package:sharexev2/presentation/pages/passenger/search_rides_page.dart';
// import 'package:sharexev2/presentation/pages/chat/chat_rooms_page.dart';
// import 'package:sharexev2/presentation/pages/chat/chat_page.dart';
// import 'package:sharexev2/presentation/pages/ride/ride_detail_page.dart';
// import 'package:sharexev2/presentation/pages/ride/ride_review_page.dart';
// import 'package:sharexev2/presentation/pages/notification/notification_details_page.dart';
// import 'package:sharexev2/presentation/widgets/backgrounds/sharexe_background.dart';

// Theme
import 'package:sharexev2/config/theme.dart';

// Route namespaces for better organization
class CommonRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String passengerSplash = '/splash/passenger';
  static const String driverSplash = '/splash/driver';
}

class AuthRoutes {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
}

class PassengerRoutes {
  static const String home = '/passenger/home';
  static const String profile = '/passenger/profile';
  static const String bookings = '/passenger/bookings';
  static const String tripHistory = '/passenger/trip-history';
  static const String editProfile = '/passenger/edit-profile';
  static const String changePassword = '/passenger/change-password';
  static const String support = '/passenger/support';
  static const String about = '/passenger/about';
  static const String searchRides = '/passenger/search-rides';
  static const String rideBooking = '/passenger/ride-booking';
}

class DriverRoutes {
  static const String home = '/driver/home';
  static const String profile = '/driver/profile';
  static const String createRide = '/driver/create-ride';
  static const String myRides = '/driver/my-rides';
  static const String bookings = '/driver/bookings';
  static const String rideDetails = '/driver/ride-details';
  static const String passengersList = '/driver/passengers-list';
}

class ChatRoutes {
  static const String rooms = '/chat/rooms';
  static const String chat = '/chat/room';
}

class TripRoutes {
  static const String detail = '/trip/detail';
  static const String review = '/trip/review';
}

class NotificationRoutes {
  static const String details = '/notification/details';
  static const String promotions = '/notification/promotions';
}

class SettingsRoutes {
  static const String main = '/settings';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String notifications = '/settings/notifications';
  static const String vehicle = '/settings/vehicle';
  static const String payment = '/settings/payment';
  static const String about = '/about';
  static const String userGuide = '/help/guide';
  static const String support = '/support';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
}

class DemoRoutes {
  static const String bookingWidgets = '/demo/booking-widgets';
}

// Compatibility class for old imports
class AppRoutes {
  // Common routes
  static const String splash = CommonRoutes.splash;
  static const String onboarding = CommonRoutes.onboarding;
  static const String roleSelection = CommonRoutes.roleSelection;
  static const String passengerSplash = CommonRoutes.passengerSplash;
  static const String driverSplash = CommonRoutes.driverSplash;

  // Auth routes
  static const String login = AuthRoutes.login;
  static const String register = AuthRoutes.register;
  static const String forgotPassword = AuthRoutes.forgotPassword;

  // Passenger routes
  static const String homePassenger = PassengerRoutes.home;
  static const String passengerProfile = PassengerRoutes.profile;
  static const String searchRides = PassengerRoutes.searchRides;

  // Driver routes
  static const String homeDriver = DriverRoutes.home;
  static const String driverProfile = DriverRoutes.profile;

  // Chat routes
  static const String chatRooms = ChatRoutes.rooms;
  static const String chat = ChatRoutes.chat;
}

class AppRoute {
  // Common routes
  static const String splash = CommonRoutes.splash;
  static const String onboarding = CommonRoutes.onboarding;
  static const String roleSelection = CommonRoutes.roleSelection;
  static const String passengerSplash = CommonRoutes.passengerSplash;
  static const String driverSplash = CommonRoutes.driverSplash;

  // Auth routes
  static const String login = AuthRoutes.login;
  static const String register = AuthRoutes.register;
  static const String forgotPassword = AuthRoutes.forgotPassword;

  // Passenger routes
  static const String homePassenger = PassengerRoutes.home;
  static const String passengerProfile = PassengerRoutes.profile;
  static const String passengerBookings = PassengerRoutes.bookings;
  static const String passengerTripHistory = PassengerRoutes.tripHistory;
  static const String passengerEditProfile = PassengerRoutes.editProfile;
  static const String passengerChangePassword = PassengerRoutes.changePassword;
  static const String passengerSupport = PassengerRoutes.support;
  static const String passengerAbout = PassengerRoutes.about;
  static const String searchRides = PassengerRoutes.searchRides;
  static const String rideBooking = PassengerRoutes.rideBooking;

  // Driver routes
  static const String homeDriver = DriverRoutes.home;
  static const String driverProfile = DriverRoutes.profile;
  static const String createRide = DriverRoutes.createRide;
  static const String myRides = DriverRoutes.myRides;
  static const String driverBookings = DriverRoutes.bookings;
  static const String driverRideDetails = DriverRoutes.rideDetails;
  static const String passengersList = DriverRoutes.passengersList;

  // Chat routes
  static const String chatRooms = ChatRoutes.rooms;
  static const String chat = ChatRoutes.chat;

  // Trip routes
  static const String tripDetail = TripRoutes.detail;
  static const String tripReview = TripRoutes.review;

  // Notification routes
  static const String notificationDetails = NotificationRoutes.details;
  static const String promotions = NotificationRoutes.promotions;

  // Demo routes (disabled)
  static const String bookingDemo = '/__disabled__';

  // Route generation with proper argument handling, background integration, and dynamic themes
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;
    final dynamic arguments = settings.arguments;

    // Simple auth guard: redirect protected routes to login when not authenticated
    final Set<String> protectedRoutes = {
      PassengerRoutes.home,
      PassengerRoutes.profile,
      PassengerRoutes.bookings,
      PassengerRoutes.tripHistory,
      DriverRoutes.home,
      DriverRoutes.profile,
      DriverRoutes.createRide,
      DriverRoutes.myRides,
      DriverRoutes.bookings,
      DriverRoutes.rideDetails,
      DriverRoutes.passengersList,
      ChatRoutes.rooms,
      ChatRoutes.chat,
      TripRoutes.detail,
      TripRoutes.review,
      NotificationRoutes.details,
      NotificationRoutes.promotions,
    };

    final bool requiresAuth =
        routeName != null && protectedRoutes.contains(routeName);
    if (requiresAuth) {
      final token = AuthManager().getToken();
      if (token == null || token.isEmpty) {
        return MaterialPageRoute(
          builder: (_) => _placeholderPage('Login Required'),
        );
      }
    }

    // Common routes
    if (routeName == splash) {
      return MaterialPageRoute(
        builder: (_) => const MainSplashScreen(),
      );
    } else if (routeName == onboarding) {
      return MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      );
    } else if (routeName == passengerSplash) {
      return MaterialPageRoute(
        builder: (_) => const PassengerSplashScreen(),
      );
    } else if (routeName == driverSplash) {
      return MaterialPageRoute(
        builder: (_) => const DriverSplashScreen(),
      );
    } else if (routeName == roleSelection) {
      return MaterialPageRoute(
        builder: (_) => const RoleSelectionScreen(),
      );
    }
    // Auth routes
    else if (routeName == login) {
      final role = arguments as String? ?? 'PASSENGER';
      return MaterialPageRoute(
        builder: (_) => LoginScreen(role: role),
      );
    } else if (routeName == register) {
      final args = arguments;
      String role = 'PASSENGER';
      
      if (args is String) {
        role = args;
      } else if (args is Map<String, dynamic>) {
        role = args['role'] ?? 'PASSENGER';
        if (args['action'] == 'forgot_password') {
          return MaterialPageRoute(
            builder: (_) => ForgotPasswordScreen(role: role),
          );
        }
      }
      
      return MaterialPageRoute(
        builder: (_) => RegisterScreen(role: role),
      );
    } else if (routeName == forgotPassword) {
      final role = arguments as String? ?? 'PASSENGER';
      return MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(role: role),
      );
    }
    // Passenger routes
    else if (routeName == homePassenger) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Passenger Home'),
      );
    } else if (routeName == passengerProfile) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Passenger Profile'),
      );
    } else if (routeName == searchRides) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Search Rides'),
      );
    } else if (routeName == '/history') {
      return MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      );
    } else if (routeName == '/favorites') {
      return MaterialPageRoute(
        builder: (_) => const FavoritesScreen(),
      );
    }
    // Driver routes
    else if (routeName == '/driver-home') {
      return MaterialPageRoute(
        builder: (_) => const DriverHomeScreen(),
      );
    } else if (routeName == '/driver-notifications') {
      return MaterialPageRoute(
        builder: (_) => const DriverNotificationsScreen(),
      );
    } else if (routeName == '/driver-tracking') {
      final args = settings.arguments as Map<String, dynamic>?;
      final booking = args?['booking'];
      if (booking == null) {
        return MaterialPageRoute(
          builder: (_) => _placeholderPage('Driver Tracking - No booking data'),
        );
      }
      return MaterialPageRoute(
        builder: (_) => DriverTrackingScreen(booking: booking),
      );
    } else if (routeName == '/driver-review') {
      final args = settings.arguments as Map<String, dynamic>?;
      final booking = args?['booking'];
      if (booking == null) {
        return MaterialPageRoute(
          builder: (_) => _placeholderPage('Driver Review - No booking data'),
        );
      }
      return MaterialPageRoute(
        builder: (_) => DriverReviewScreen(booking: booking),
      );
    } else if (routeName == '/driver-revenue') {
      return MaterialPageRoute(
        builder: (_) => const DriverRevenueScreen(),
      );
    } else if (routeName == '/driver-history') {
      return MaterialPageRoute(
        builder: (_) => const DriverHistoryScreen(),
      );
    } else if (routeName == '/driver/passengers-list') {
      final args = settings.arguments as Map<String, dynamic>?;
      final ride = args?['ride'];
      if (ride == null) {
        return MaterialPageRoute(
          builder: (_) => _placeholderPage('Passengers List - No ride data'),
        );
      }
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Passengers List - ${ride.toString()}'),
      );
    }
    // Common routes
    else if (routeName == '/notifications') {
      final args = settings.arguments as Map<String, dynamic>?;
      final userRole = args?['userRole'] ?? 'PASSENGER';
      return MaterialPageRoute(
        builder: (_) => NotificationsScreen(userRole: userRole),
      );
    } else if (routeName == '/map-tracking') {
      final args = settings.arguments as Map<String, dynamic>?;
      final rideId = args?['rideId'] ?? 1;
      final userRole = args?['userRole'] ?? 'PASSENGER';
      final isDriverTracking = args?['isDriverTracking'] ?? false;
      return MaterialPageRoute(
        builder: (_) => MapTrackingScreen(
          rideId: rideId,
          userRole: userRole,
          isDriverTracking: isDriverTracking,
        ),
      );
    } else if (routeName == '/create-ride') {
      return MaterialPageRoute(
        builder: (_) => const CreateRideScreen(),
      );
    } else if (routeName == '/ride-details') {
      final args = settings.arguments as Map<String, dynamic>?;
      final ride = args?['ride'];
      final userRole = args?['userRole'] ?? 'PASSENGER';
      return MaterialPageRoute(
        builder: (_) => RideDetailsScreen(
          ride: ride,
          userRole: userRole,
        ),
      );
    }
    // Driver routes
    else if (routeName == homeDriver) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Driver Home'),
      );
    } else if (routeName == driverProfile) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Driver Profile'),
      );
    }
    // Chat routes
    else if (routeName == chatRooms) {
      return MaterialPageRoute(
        builder: (_) => const ShareXeChatListScreen(),
      );
    } else if (routeName == chat) {
      final args = arguments as Map<String, dynamic>?;
      if (args != null && 
          args['roomId'] != null && 
          args['participantName'] != null && 
          args['participantEmail'] != null) {
        return MaterialPageRoute(
          builder: (_) => ShareXeChatRoomScreen(
            roomId: args['roomId'] as String,
            participantName: args['participantName'] as String,
            participantEmail: args['participantEmail'] as String,
          ),
        );
      }
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Chat - Missing Arguments'),
      );
    }
    // Notification routes
    else if (routeName == promotions) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Promotions Screen'),
      );
    }
    // Settings routes
    else if (routeName == SettingsRoutes.main) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Settings - Import needed'),
      );
    } else if (routeName == SettingsRoutes.editProfile) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Edit Profile - Import needed'),
      );
    } else if (routeName == SettingsRoutes.changePassword) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Change Password - Import needed'),
      );
    } else if (routeName == SettingsRoutes.about) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('About - Import needed'),
      );
    } else if (routeName == SettingsRoutes.userGuide) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('User Guide - Import needed'),
      );
    }
    // Other routes
    else if (routeName == tripDetail) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Trip Detail'),
      );
    } else if (routeName == tripReview) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Trip Review'),
      );
    } else if (routeName == notificationDetails) {
      return MaterialPageRoute(
        builder: (_) => _placeholderPage('Notification Details'),
      );
    }
    // Demo routes (disabled)
    else if (routeName == bookingDemo) {
      return _errorRoute(routeName);
    }
    // Default error route
    else {
      return _errorRoute(routeName);
    }
  }

  // Placeholder page for routes under development
  static Widget _placeholderPage(String pageName) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              '$pageName',
              style: AppTextStyles.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Trang này đang được phát triển',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final context = NavigationService().navigatorKey.currentContext;
                if (context != null) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  // Error route handler
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Lỗi'),
              backgroundColor: Colors.red,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy trang: $routeName',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper methods for navigation with proper arguments
  static Future<T?> navigateToLogin<T extends Object?>(
    BuildContext context, {
    String role = 'PASSENGER',
  }) {
    return Navigator.pushNamed(context, login, arguments: role);
  }

  static Future<T?> navigateToRegister<T extends Object?>(
    BuildContext context, {
    String role = 'PASSENGER',
  }) {
    return Navigator.pushNamed(context, register, arguments: role);
  }

  static Future<T?> navigateToChat<T extends Object?>(
    BuildContext context, {
    required String roomId,
    required String participantName,
    String? participantEmail,
  }) {
    return Navigator.pushNamed(
      context,
      chat,
      arguments: {
        'roomId': roomId,
        'participantName': participantName,
        'participantEmail': participantEmail,
      },
    );
  }

  static Future<T?> navigateToTripDetail<T extends Object?>(
    BuildContext context, {
    required Map<String, dynamic> tripData,
  }) {
    return Navigator.pushNamed(context, tripDetail, arguments: tripData);
  }

  static Future<T?> navigateToTripReview<T extends Object?>(
    BuildContext context, {
    required Map<String, dynamic> tripData,
    String role = 'PASSENGER',
  }) {
    return Navigator.pushNamed(
      context,
      tripReview,
      arguments: {'tripData': tripData, 'role': role},
    );
  }

  static Future<T?> navigateToDriverRideDetails<T extends Object?>(
    BuildContext context, {
    required Map<String, dynamic> rideData,
  }) {
    return Navigator.pushNamed(context, driverRideDetails, arguments: rideData);
  }
}

// Legacy route map for backward compatibility
// Temporarily commented out until pages are created
final Map<String, WidgetBuilder> appRoutes = {
  AppRoute.splash: (context) => const MainSplashScreen(),
  AppRoute.onboarding: (context) => const OnboardingScreen(),
  AppRoute.passengerSplash: (context) => const PassengerSplashScreen(),
  AppRoute.driverSplash: (context) => const DriverSplashScreen(),
  // TODO: Uncomment when pages are created
  // AppRoute.homePassenger: (context) => Theme(data: passengerTheme, child: const PassengerRidePage()),
  // AppRoute.homeDriver: (context) => Theme(data: driverTheme, child: const DriverHomePage()),
  // Note: These routes are commented out as the corresponding pages are not yet implemented
  // AppRoute.roleSelection: (context) => _placeholderPage('Role Selection'),
  // AppRoute.login: (context) => _placeholderPage('Login'),
  // AppRoute.register: (context) => _placeholderPage('Register'),
  // AppRoute.chatRooms: (context) => _placeholderPage('Chat Rooms'),
  // AppRoute.chat: (context) => _placeholderPage('Chat'),
  // AppRoute.notificationDetails: (context) => _placeholderPage('Notifications'),
  // AppRoute.tripDetail: (context) => _placeholderPage('Trip Detail'),
  // AppRoute.tripReview: (context) => _placeholderPage('Trip Review'),
  // AppRoute.passengerProfile: (context) => _placeholderPage('Passenger Profile'),
  // AppRoute.driverProfile: (context) => _placeholderPage('Driver Profile'),
};
