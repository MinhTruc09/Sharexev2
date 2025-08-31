import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/main.dart';
import 'package:sharexev2/routes/app_routes.dart';
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
import 'package:sharexev2/logic/trip/trip_detail_cubit.dart';
import 'package:sharexev2/logic/trip/trip_review_cubit.dart';
import 'package:sharexev2/data/services/auth_service.dart';
import 'package:sharexev2/core/network/api_client.dart';


class App extends StatelessWidget {
  final bool isFirstOpen;

  const App({super.key, required this.isFirstOpen});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Core BLoCs
        BlocProvider(create: (_) => SplashCubit(AuthService(ApiClient()))),
        BlocProvider(create: (_) => OnboardingCubit()),
        BlocProvider(create: (_) => RoleSelectionCubit(AuthService(ApiClient()))),

        // Auth BLoCs
        BlocProvider(create: (_) => AuthCubit(AuthService(ApiClient()))),
        BlocProvider(
          create: (_) => RegistrationCubit(AuthService(ApiClient()), 'PASSENGER'),
        ),

        // Home BLoCs
        BlocProvider(create: (_) => HomePassengerCubit()),
        BlocProvider(create: (_) => HomeDriverCubit()),

        // Feature BLoCs
        BlocProvider(create: (_) => BookingCubit()),
        BlocProvider(create: (_) => ChatCubit()),
        BlocProvider(create: (_) => MapBloc()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => RideCubit()),
        BlocProvider(create: (_) => TripDetailCubit()),
        BlocProvider(create: (_) => TripReviewCubit()),
      ],
      child: ThemeProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigationService.navigatorKey,
          initialRoute: isFirstOpen ? AppRoute.onboarding : AppRoute.splash,
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
  InputDecorationTheme get inputDecorationTheme => theme.inputDecorationTheme as InputDecorationTheme;

  // Card styles
  CardThemeData get cardTheme => theme.cardTheme;
}
