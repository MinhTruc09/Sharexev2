import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/main.dart';
import 'package:sharexev2/routes/app_routes.dart';

// Repository interfaces
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';
import 'package:sharexev2/data/repositories/booking/booking_repository_interface.dart';
import 'package:sharexev2/data/repositories/chat/chat_repository_interface.dart';
import 'package:sharexev2/data/repositories/location/location_repository_interface.dart';
import 'package:sharexev2/data/repositories/ride/ride_repository_interface.dart';
import 'package:sharexev2/data/repositories/tracking/tracking_repository_interface.dart';
import 'package:sharexev2/data/repositories/user/user_repository_interface.dart';

// Services
import 'package:sharexev2/data/services/auth_service.dart';
import 'package:sharexev2/logic/auth/auth_cubit.dart';
import 'package:sharexev2/logic/auth/auth_state.dart';
import 'package:sharexev2/logic/booking/booking_cubit.dart';
import 'package:sharexev2/logic/chat/chat_cubit.dart';
import 'package:sharexev2/logic/home/home_driver_cubit.dart';
import 'package:sharexev2/logic/home/home_passenger_cubit.dart';
import 'package:sharexev2/logic/map/map_bloc.dart';
import 'package:sharexev2/logic/onboarding/onboarding_cubit.dart';
import 'package:sharexev2/logic/profile/profile_cubit.dart';
import 'package:sharexev2/logic/registration/registration_cubit.dart';
import 'package:sharexev2/logic/ride/ride_cubit.dart';
import 'package:sharexev2/logic/roleselection/role_selection_cubit.dart';
import 'package:sharexev2/logic/splash/splash_cubit.dart';
import 'package:sharexev2/logic/location/location_cubit.dart';
import 'package:sharexev2/logic/tracking/tracking_cubit.dart';
// Removed unused imports - now using ServiceLocator for DI

// Dependency Injection
import 'package:sharexev2/core/di/service_locator.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Core BLoCs
        BlocProvider(
          create: (_) => SplashCubit(ServiceLocator.get<AuthService>()),
        ),
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(
          create:
              (_) => RoleSelectionCubit(
                ServiceLocator.get<AuthRepositoryInterface>(),
              ),
        ),

        // Auth BLoCs
        BlocProvider(
          create:
              (_) => AuthCubit(ServiceLocator.get<AuthRepositoryInterface>()),
        ),
        BlocProvider(
          create:
              (_) => RegistrationCubit(
                authRepository: ServiceLocator.get<AuthRepositoryInterface>(),
                role: 'PASSENGER',
              ),
        ),

        // Home BLoCs
        BlocProvider(
          create:
              (_) => HomePassengerCubit(
                rideRepository: ServiceLocator.get<RideRepositoryInterface>(),
                bookingRepository:
                    ServiceLocator.get<BookingRepositoryInterface>(),
                locationRepository:
                    ServiceLocator.get<LocationRepositoryInterface>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => HomeDriverCubit(
                rideRepository: ServiceLocator.get<RideRepositoryInterface>(),
                bookingRepository:
                    ServiceLocator.get<BookingRepositoryInterface>(),
                userRepository: ServiceLocator.get<UserRepositoryInterface>(),
              ),
        ),

        // Feature BLoCs
        BlocProvider(
          create:
              (_) => BookingCubit(
                ServiceLocator.get<BookingRepositoryInterface>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => ChatCubit(
                chatRepository: ServiceLocator.get<ChatRepositoryInterface>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => MapBloc(
                locationRepository:
                    ServiceLocator.get<LocationRepositoryInterface>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => ProfileCubit(
                userRepository: ServiceLocator.get<UserRepositoryInterface>(),
                authRepository: ServiceLocator.get<AuthRepositoryInterface>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => RideCubit(
                rideRepository: ServiceLocator.get<RideRepositoryInterface>(),
                bookingRepository:
                    ServiceLocator.get<BookingRepositoryInterface>(),
              ),
        ),
        // New Grab-like features
        BlocProvider(
          create:
              (_) => LocationCubit(
                locationRepository:
                    ServiceLocator.get<LocationRepositoryInterface>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => TrackingCubit(
                ServiceLocator.get<TrackingRepositoryInterface>(),
              ),
        ),
      ],
      child: ThemeProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigationService.navigatorKey,
          initialRoute: AppRoute.splash,
          onGenerateRoute: AppRoute.onGenerateRoute,
          title: 'ShareXev2',
          builder: (context, child) {
            return MediaQuery(
              // Set text scaling to prevent layout issues
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

/// Theme provider that manages dynamic theme switching based on user role
class ThemeProvider extends StatefulWidget {
  final Widget child;

  const ThemeProvider({super.key, required this.child});

  @override
  State<ThemeProvider> createState() => _ThemeProviderState();
}

class _ThemeProviderState extends State<ThemeProvider> {
  String _currentRole = 'PASSENGER'; // Default role

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Update theme when user role changes
        if (state.user != null && state.user!.role.name != _currentRole) {
          setState(() {
            _currentRole = state.user!.role.name;
          });
        }
      },
      child: Theme(
        data: ThemeManager.getThemeForRole(_currentRole),
        child: widget.child,
      ),
    );
  }
}

/// Extension to easily access theme colors
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  Color get primaryColor => theme.primaryColor;
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Helper methods for common theme elements
  TextStyle get headlineStyle => textTheme.headlineMedium!;
  TextStyle get titleStyle => textTheme.titleLarge!;
  TextStyle get bodyStyle => textTheme.bodyMedium!;
  TextStyle get labelStyle => textTheme.labelLarge!;

  // Button styles
  ButtonStyle get primaryButtonStyle => theme.elevatedButtonTheme.style!;
  ButtonStyle get outlinedButtonStyle => theme.outlinedButtonTheme.style!;
  ButtonStyle get textButtonStyle => theme.textButtonTheme.style!;

  // Input styles
  InputDecorationTheme get inputDecorationTheme =>
      theme.inputDecorationTheme as InputDecorationTheme;

  // Card styles
  CardThemeData get cardTheme => theme.cardTheme;
}
