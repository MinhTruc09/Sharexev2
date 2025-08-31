// theme.dart
import 'package:flutter/material.dart';

// Grab-like Color System
class AppColors {
  // Grab Brand Colors
  static const Color grabGreen = Color(0xFF00B14F);
  static const Color grabDarkGreen = Color(0xFF009639);
  static const Color grabOrange = Color(0xFFFF6B35);

  // Role-specific colors
  static const Color passengerPrimary = Color(0xFF00B14F); // Grab Green
  static const Color passengerSecondary = Color(0xFF00D95F);
  static const Color driverPrimary = Color(0xFF1E40AF); // Driver Blue
  static const Color driverSecondary = Color(0xFF3B82F6);

  // Neutral colors (Grab-like)
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Shadow colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x25000000);
}

// Grab-like Gradients
class AppGradients {
  static const LinearGradient grabPrimary = LinearGradient(
    colors: [AppColors.grabGreen, AppColors.grabDarkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient driverPrimary = LinearGradient(
    colors: [AppColors.driverPrimary, Color(0xFF1E3A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardShadow = LinearGradient(
    colors: [AppColors.shadowLight, Colors.transparent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Spacing System (Grab-like)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Specific spacing
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
}

// Border Radius (Grab-like)
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circle = 999.0;

  // Specific radius
  static const double card = 12.0;
  static const double button = 8.0;
  static const double bottomSheet = 16.0;
}

// Base theme configuration
class BaseTheme {
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXl = 16.0;
  
  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  
  static const String fontFamily = 'Roboto';
  
  static const List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}

// Text styles
class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: BaseTheme.fontFamily,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: BaseTheme.fontFamily,
  );
}

// Main AppTheme class that provides all the methods and properties
class AppTheme {
  // Color getters
  static Color get passengerPrimary => AppColors.passengerPrimary;
  static Color get passengerSecondary => AppColors.passengerSecondary;
  static Color get driverPrimary => AppColors.driverPrimary;
  static Color get driverSecondary => AppColors.driverSecondary;
  static Color get success => AppColors.success;
  static Color get error => AppColors.error;
  static Color get warning => AppColors.warning;
  static Color get info => AppColors.info;
  static Color get surface => AppColors.surface;
  static Color get background => AppColors.background;
  static Color get textPrimary => AppColors.textPrimary;
  static Color get textSecondary => AppColors.textSecondary;
  static Color get textTertiary => AppColors.textTertiary;
  
  // Spacing getters
  static double get spacingXs => BaseTheme.spacingXs;
  static double get spacingS => BaseTheme.spacingS;
  static double get spacingM => BaseTheme.spacingM;
  static double get spacingL => BaseTheme.spacingL;
  static double get spacingXl => BaseTheme.spacingXl;
  static double get spacingXxl => BaseTheme.spacingXxl;
  
  // Radius getters
  static double get radiusS => BaseTheme.radiusS;
  static double get radiusM => BaseTheme.radiusM;
  static double get radiusL => BaseTheme.radiusL;
  static double get radiusXl => BaseTheme.radiusXl;
  
  // Shadow getters
  static List<BoxShadow> get shadowLight => BaseTheme.shadowLight;
  static List<BoxShadow> get shadowMedium => BaseTheme.shadowMedium;
  static List<BoxShadow> get shadowHeavy => BaseTheme.shadowHeavy;
  
  // Text style getters
  static TextStyle get displayLarge => AppTextStyles.displayLarge;
  static TextStyle get displayMedium => AppTextStyles.displayMedium;
  static TextStyle get displaySmall => AppTextStyles.displaySmall;
  static TextStyle get headingLarge => AppTextStyles.headingLarge;
  static TextStyle get headingMedium => AppTextStyles.headingMedium;
  static TextStyle get headingSmall => AppTextStyles.headingSmall;
  static TextStyle get bodyLarge => AppTextStyles.bodyLarge;
  static TextStyle get bodyMedium => AppTextStyles.bodyMedium;
  static TextStyle get bodySmall => AppTextStyles.bodySmall;
  static TextStyle get labelLarge => AppTextStyles.labelLarge;
  static TextStyle get labelMedium => AppTextStyles.labelMedium;
  static TextStyle get labelSmall => AppTextStyles.labelSmall;
  
  // Dynamic color methods
  static Color getPrimaryColor(String role) {
    return role == 'PASSENGER' ? AppColors.passengerPrimary : AppColors.driverPrimary;
  }
  
  static Color getBackgroundColor(String role) {
    return role == 'PASSENGER' ? AppColors.background : Color(0xFF1A202C);
  }
  
  static Color getSurfaceColor(String role) {
    return role == 'PASSENGER' ? AppColors.surface : Color(0xFF2D3748);
  }
  
  static Color getTextColor(String role) {
    return role == 'PASSENGER' ? AppColors.textPrimary : Colors.white;
  }
  
  // Gradient methods
  static LinearGradient getGradient(String role) {
    final primaryColor = getPrimaryColor(role);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        primaryColor.withValues(alpha: 0.8),
      ],
    );
  }
  
  // Role display methods
  static String getRoleDisplayName(String role) {
    return role == 'PASSENGER' ? 'Hành khách' : 'Tài xế';
  }
  
  // Input decoration methods
  static InputDecoration getInputDecoration({
    required String hintText,
    required String role,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: getTextColor(role).withValues(alpha: 0.5),
        fontSize: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BaseTheme.radiusM),
        borderSide: BorderSide(color: getPrimaryColor(role).withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BaseTheme.radiusM),
        borderSide: BorderSide(color: getPrimaryColor(role), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BaseTheme.radiusM),
        borderSide: BorderSide(color: getPrimaryColor(role).withValues(alpha: 0.3)),
      ),
      filled: true,
      fillColor: getSurfaceColor(role),
      contentPadding: EdgeInsets.symmetric(
        horizontal: BaseTheme.spacingM,
        vertical: BaseTheme.spacingM,
      ),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }
}

// ThemeManager for dynamic theme switching
class ThemeManager {
  static ThemeData getThemeForRole(String role) {
    return role == 'PASSENGER' ? passengerTheme : driverTheme;
  }
  
  static Color getPrimaryColorForRole(String role) {
    return AppTheme.getPrimaryColor(role);
  }
  
  static Color getBackgroundColorForRole(String role) {
    return AppTheme.getBackgroundColor(role);
  }
  
  static Color getSurfaceColorForRole(String role) {
    return AppTheme.getSurfaceColor(role);
  }
  
  static Color getTextColorForRole(String role) {
    return AppTheme.getTextColor(role);
  }
  
  // Success color getter
  static Color getSuccessColor() {
    return AppColors.success;
  }
}

// Passenger theme (light blue)
final ThemeData passengerTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.passengerPrimary,
    brightness: Brightness.light,
  ),
  fontFamily: BaseTheme.fontFamily,
  
  // App Bar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.passengerPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.headingMedium.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
  
  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.passengerPrimary,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: BaseTheme.spacingL,
        vertical: BaseTheme.spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseTheme.radiusM),
      ),
      elevation: 2,
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BaseTheme.radiusM),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BaseTheme.radiusM),
      borderSide: BorderSide(color: AppColors.passengerPrimary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: BaseTheme.spacingM,
      vertical: BaseTheme.spacingM,
    ),
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BaseTheme.radiusL),
    ),
    margin: EdgeInsets.all(BaseTheme.spacingS),
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.passengerPrimary,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);

// Driver theme (dark blue)
final ThemeData driverTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.driverPrimary,
    brightness: Brightness.dark,
  ),
  fontFamily: BaseTheme.fontFamily,
  
  // App Bar Theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.driverPrimary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyles.headingMedium.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),
  
  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.driverPrimary,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: BaseTheme.spacingL,
        vertical: BaseTheme.spacingM,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseTheme.radiusM),
      ),
      elevation: 2,
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BaseTheme.radiusM),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(BaseTheme.radiusM),
      borderSide: BorderSide(color: AppColors.driverPrimary, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: BaseTheme.spacingM,
      vertical: BaseTheme.spacingM,
    ),
  ),
  
  // Card Theme
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BaseTheme.radiusL),
    ),
    margin: EdgeInsets.all(BaseTheme.spacingS),
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF2D3748),
    selectedItemColor: AppColors.driverPrimary,
    unselectedItemColor: Colors.white70,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
