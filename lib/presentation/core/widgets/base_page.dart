import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Base page widget with common functionality
abstract class BasePage extends StatelessWidget {
  final String title;
  final String role;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;

  const BasePage({
    super.key,
    required this.title,
    required this.role,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }

  /// Build the app bar
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final primaryColor = role == 'PASSENGER' 
        ? AppColors.passengerPrimary 
        : AppColors.driverPrimary;

    return AppBar(
      title: Text(title),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => onNotificationTap(context),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => onProfileTap(context),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build the main body content
  Widget buildBody(BuildContext context);

  /// Build bottom navigation (optional)
  Widget? buildBottomNavigation(BuildContext context) => null;

  /// Handle notification tap
  void onNotificationTap(BuildContext context) {
    // Default implementation
  }

  /// Handle profile tap
  void onProfileTap(BuildContext context) {
    Navigator.pushNamed(context, '/$role/profile');
  }
}

/// Base page with BLoC provider
abstract class BaseBlocPage<T extends StateStreamable<S>, S> extends StatelessWidget {
  final String title;
  final String role;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;

  const BaseBlocPage({
    super.key,
    required this.title,
    required this.role,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  /// Create the BLoC instance
  T createBloc(BuildContext context);

  /// Build the body with BLoC
  Widget buildBlocBody(BuildContext context, T bloc);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: createBloc,
      child: Builder(
        builder: (context) {
          final bloc = context.read<T>();
          return BasePage(
            title: title,
            role: role,
            actions: actions,
            floatingActionButton: floatingActionButton,
            showBackButton: showBackButton,
          ).copyWith(
            body: buildBlocBody(context, bloc),
          );
        },
      ),
    );
  }
}

/// Extension to copy BasePage with different body
extension BasePageExtension on BasePage {
  Widget copyWith({Widget? body}) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(null as BuildContext),
      body: body ?? buildBody(null as BuildContext),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: buildBottomNavigation(null as BuildContext),
    );
  }
}
