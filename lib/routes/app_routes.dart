import 'package:flutter/material.dart';
import 'package:sharexev2/core/auth/auth_manager.dart';

// Common pages
import 'package:sharexev2/presentation/pages/common/splash_page.dart';
import 'package:sharexev2/presentation/pages/common/onboarding_page.dart';
import 'package:sharexev2/presentation/pages/common/role_selection_page.dart';

// Auth pages
import 'package:sharexev2/presentation/pages/auth/login_page.dart';
import 'package:sharexev2/presentation/pages/authflow/register_page.dart';

// Home pages
import 'package:sharexev2/presentation/pages/passenger/passenger_ride_page.dart';
import 'package:sharexev2/presentation/pages/driver/driver_home_page.dart';

// Profile pages
import 'package:sharexev2/presentation/pages/profile/profile_page.dart';

// Passenger pages
import 'package:sharexev2/presentation/pages/passenger/profile/edit_profile_page.dart';
import 'package:sharexev2/presentation/pages/passenger/profile/change_password_page.dart';
import 'package:sharexev2/presentation/pages/passenger/support/support_page.dart';
import 'package:sharexev2/presentation/pages/passenger/about/about_page.dart';
import 'package:sharexev2/presentation/pages/passenger/search_rides_page.dart';

// Chat pages
import 'package:sharexev2/presentation/pages/chat/chat_rooms_page.dart';
import 'package:sharexev2/presentation/pages/chat/chat_page.dart';

// Trip pages
import 'package:sharexev2/presentation/pages/ride/ride_detail_page.dart';
import 'package:sharexev2/presentation/pages/ride/ride_review_page.dart';

// Notification pages
import 'package:sharexev2/presentation/pages/notification/notification_details_page.dart';

// Demo pages (disabled)

// Background widgets
import 'package:sharexev2/presentation/widgets/backgrounds/sharexe_background.dart';

// Theme
import 'package:sharexev2/config/theme.dart';

// Route namespaces for better organization
class CommonRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
}

class AuthRoutes {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
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
}

class DemoRoutes {
  static const String bookingWidgets = '/demo/booking-widgets';
}

class AppRoute {
  // Common routes
  static const String splash = CommonRoutes.splash;
  static const String onboarding = CommonRoutes.onboarding;
  static const String roleSelection = CommonRoutes.roleSelection;

  // Auth routes
  static const String login = AuthRoutes.login;
  static const String register = AuthRoutes.register;

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

  // Chat routes
  static const String chatRooms = ChatRoutes.rooms;
  static const String chat = ChatRoutes.chat;

  // Trip routes
  static const String tripDetail = TripRoutes.detail;
  static const String tripReview = TripRoutes.review;

  // Notification routes
  static const String notificationDetails = NotificationRoutes.details;

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
      ChatRoutes.rooms,
      ChatRoutes.chat,
      TripRoutes.detail,
      TripRoutes.review,
      NotificationRoutes.details,
    };

    final bool requiresAuth =
        routeName != null && protectedRoutes.contains(routeName);
    if (requiresAuth) {
      final token = AuthManager().getToken();
      if (token == null || token.isEmpty) {
        return MaterialPageRoute(
          builder:
              (_) => SharexeBackgroundFactory(
                type: SharexeBackgroundType.blueWithClouds,
                child: const LoginPage(role: 'PASSENGER'),
              ),
        );
      }
    }

    // Common routes
    if (routeName == splash) {
      return MaterialPageRoute(
        builder:
            (_) => SharexeBackgroundFactory(
              type: SharexeBackgroundType.blueWithSun,
              child: const SplashPage(),
            ),
      );
    } else if (routeName == onboarding) {
      return MaterialPageRoute(
        builder:
            (_) => SharexeBackgroundFactory(
              type: SharexeBackgroundType.blueWithClouds,
              child: const OnboardingPage(),
            ),
      );
    } else if (routeName == roleSelection) {
      return MaterialPageRoute(
        builder:
            (_) => SharexeBackgroundFactory(
              type: SharexeBackgroundType.blueWithSun,
              child: const RoleSelectionPage(),
            ),
      );
    }
    // Auth routes
    else if (routeName == login) {
      final role = arguments as String? ?? 'PASSENGER';
      return MaterialPageRoute(
        builder:
            (_) => SharexeBackgroundFactory(
              type: SharexeBackgroundType.blueWithClouds,
              child: LoginPage(role: role),
            ),
      );
    } else if (routeName == register) {
      final role = arguments as String? ?? 'PASSENGER';
      return MaterialPageRoute(
        builder:
            (_) => SharexeBackgroundFactory(
              type: SharexeBackgroundType.blueWithClouds,
              child: RegisterPage(role: role),
            ),
      );
    }
    // Passenger routes - Use passenger theme
    else if (routeName == homePassenger) {
      return MaterialPageRoute(
        builder:
            (_) =>
                Theme(data: passengerTheme, child: const PassengerRidePage()),
      );
    } else if (routeName == passengerProfile) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: passengerTheme,
              child: const ProfilePage(role: 'PASSENGER'),
            ),
      );
    } else if (routeName == passengerBookings) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: passengerTheme,
              child: const ProfilePage(role: 'PASSENGER'),
            ),
      );
    } else if (routeName == passengerTripHistory) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: passengerTheme,
              child: const ProfilePage(role: 'PASSENGER'),
            ),
      );
    } else if (routeName == searchRides) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(data: passengerTheme, child: const SearchRidesPage()),
      );
    } else if (routeName == rideBooking) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: passengerTheme,
              child: const ProfilePage(
                role: 'PASSENGER',
              ), // TODO: Create RideBookingPage
            ),
      );
    }
    // Driver routes - Use driver theme
    else if (routeName == homeDriver) {
      return MaterialPageRoute(
        builder: (_) => Theme(data: driverTheme, child: const DriverHomePage()),
      );
    } else if (routeName == driverProfile) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: driverTheme,
              child: const ProfilePage(role: 'DRIVER'),
            ),
      );
    } else if (routeName == createRide) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: driverTheme,
              child: const ProfilePage(role: 'DRIVER'),
            ),
      );
    } else if (routeName == myRides) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: driverTheme,
              child: const ProfilePage(role: 'DRIVER'),
            ),
      );
    } else if (routeName == driverBookings) {
      return MaterialPageRoute(
        builder:
            (_) => Theme(
              data: driverTheme,
              child: const ProfilePage(role: 'DRIVER'),
            ),
      );
    } else if (routeName == driverRideDetails) {
      final rideData = arguments as Map<String, dynamic>? ?? {};
      final String rideId = (rideData['rideId'] ?? '').toString();
      return MaterialPageRoute(
        builder:
            (_) =>
                Theme(data: driverTheme, child: RideDetailPage(rideId: rideId)),
      );
    }
    // Chat routes - Use theme based on current user role
    else if (routeName == chatRooms) {
      return MaterialPageRoute(builder: (_) => const ChatRoomsPage());
    } else if (routeName == chat) {
      final args = arguments as Map<String, dynamic>? ?? {};
      return MaterialPageRoute(
        builder:
            (_) => ChatPage(
              roomId: args['roomId'] ?? '',
              participantName: args['participantName'] ?? '',
              participantEmail: args['participantEmail'],
            ),
      );
    }
    // Trip routes - Use theme based on current user role
    else if (routeName == tripDetail) {
      final tripData = arguments as Map<String, dynamic>? ?? {};
      final String rideId = (tripData["rideId"] ?? '').toString();
      return MaterialPageRoute(builder: (_) => RideDetailPage(rideId: rideId));
    } else if (routeName == tripReview) {
      final args = arguments as Map<String, dynamic>? ?? {};
      final String rideId = (args["rideId"] ?? '').toString();
      final String role = args["role"] ?? 'PASSENGER';
      return MaterialPageRoute(
        builder: (_) => RideReviewPage(rideId: rideId, role: role),
      );
    }
    // Notification routes
    else if (routeName == notificationDetails) {
      return MaterialPageRoute(builder: (_) => const NotificationDetailsPage());
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
final Map<String, WidgetBuilder> appRoutes = {
  AppRoute.onboarding:
      (context) => SharexeBackgroundFactory(
        type: SharexeBackgroundType.blueWithClouds,
        child: const OnboardingPage(),
      ),
  AppRoute.homePassenger:
      (context) =>
          Theme(data: passengerTheme, child: const PassengerRidePage()),
  AppRoute.homeDriver:
      (context) => Theme(data: driverTheme, child: const DriverHomePage()),
  AppRoute.roleSelection:
      (context) => SharexeBackgroundFactory(
        type: SharexeBackgroundType.blueWithSun,
        child: const RoleSelectionPage(),
      ),
  AppRoute.login: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as String?;
    return SharexeBackgroundFactory(
      type: SharexeBackgroundType.blueWithClouds,
      child: LoginPage(role: args ?? 'PASSENGER'),
    );
  },
  AppRoute.register: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as String?;
    return SharexeBackgroundFactory(
      type: SharexeBackgroundType.blueWithClouds,
      child: RegisterPage(role: args ?? 'PASSENGER'),
    );
  },
  // Demo disabled
  AppRoute.chatRooms: (context) => const ChatRoomsPage(),
  AppRoute.chat: (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return ChatPage(
      roomId: args?['roomId'] ?? '',
      participantName: args?['participantName'] ?? '',
      participantEmail: args?['participantEmail'],
    );
  },
  AppRoute.notificationDetails: (context) => const NotificationDetailsPage(),
  AppRoute.tripDetail: (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String rideId = (args?["rideId"] ?? '').toString();
    return RideDetailPage(rideId: rideId);
  },
  AppRoute.tripReview: (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String rideId = (args?["rideId"] ?? '').toString();
    final String role = args?["role"] ?? 'PASSENGER';
    return RideReviewPage(rideId: rideId, role: role);
  },
  AppRoute.passengerProfile:
      (context) => Theme(
        data: passengerTheme,
        child: const ProfilePage(role: 'PASSENGER'),
      ),
  AppRoute.driverProfile:
      (context) =>
          Theme(data: driverTheme, child: const ProfilePage(role: 'DRIVER')),
};
