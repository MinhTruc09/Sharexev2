import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

/// Splash content widget with role-based styling
class SplashContent extends StatelessWidget {
  final String? role;
  final String thumbNail;
  final String imagePathLogo;
  final String? imagePathLeft;
  final String? imagePathRight;
  final String? imagePathBot;

  const SplashContent({
    super.key,
    this.role,
    required this.thumbNail,
    required this.imagePathLogo,
    this.imagePathLeft,
    this.imagePathRight,
    this.imagePathBot,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = role?.toUpperCase() == 'PASSENGER';
    final isDriver = role?.toUpperCase() == 'DRIVER';
    
    // Role-based colors
    final primaryColor = isPassenger 
        ? AppColors.passengerPrimary 
        : isDriver 
            ? AppColors.driverPrimary 
            : AppColors.primary;
    
    final backgroundColor = isPassenger
        ? AppColors.passengerSecondary
        : isDriver
            ? AppColors.driverSecondary
            : AppColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background elements
          if (imagePathLeft != null)
            Positioned(
              left: 0,
              top: 0,
              child: Image.asset(
                imagePathLeft!,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          
          if (imagePathRight != null)
            Positioned(
              right: 0,
              top: 0,
              child: Image.asset(
                imagePathRight!,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    child: Image.asset(
                      imagePathLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isPassenger ? Icons.person : isDriver ? Icons.drive_eta : Icons.directions_car,
                          size: 60,
                          color: primaryColor,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  thumbNail,
                  style: AppTheme.headingLarge.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),

          // Bottom image
          if (imagePathBot != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                imagePathBot!,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
