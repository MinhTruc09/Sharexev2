import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/backgrounds/sharexe_background.dart';

/// A wrapper widget that applies ShareXe backgrounds to any content
/// This makes it easy to add backgrounds to existing pages without modifying their structure
class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final SharexeBackgroundType backgroundType;
  final bool useScaffold;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.backgroundType = SharexeBackgroundType.blueWithClouds,
    this.useScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useScaffold) {
      return SharexeBackgroundFactory(
        type: backgroundType,
        child: child,
      );
    } else {
      // For pages that already have their own Scaffold
      return SharexeBackgroundFactory(
        type: backgroundType,
        child: child,
      );
    }
  }
}

/// Predefined background wrappers for common use cases
class BackgroundWrappers {
  /// Splash screen background (blue with sun)
  static Widget splash(Widget child) {
    return BackgroundWrapper(
      backgroundType: SharexeBackgroundType.blueWithSun,
      child: child,
    );
  }

  /// Onboarding background (blue with clouds)
  static Widget onboarding(Widget child) {
    return BackgroundWrapper(
      backgroundType: SharexeBackgroundType.blueWithClouds,
      child: child,
    );
  }

  /// Auth background (blue with clouds)
  static Widget auth(Widget child) {
    return BackgroundWrapper(
      backgroundType: SharexeBackgroundType.blueWithClouds,
      child: child,
    );
  }

  /// Role selection background (blue with sun)
  static Widget roleSelection(Widget child) {
    return BackgroundWrapper(
      backgroundType: SharexeBackgroundType.blueWithSun,
      child: child,
    );
  }

  /// Demo background (dark blue with clouds)
  static Widget demo(Widget child) {
    return BackgroundWrapper(
      backgroundType: SharexeBackgroundType.darkBlueWithClouds,
      child: child,
    );
  }

  /// Custom background
  static Widget custom(Widget child, SharexeBackgroundType type) {
    return BackgroundWrapper(
      backgroundType: type,
      child: child,
    );
  }
}

/// Extension methods for easy background application
extension BackgroundExtension on Widget {
  /// Apply splash background
  Widget withSplashBackground() {
    return BackgroundWrappers.splash(this);
  }

  /// Apply onboarding background
  Widget withOnboardingBackground() {
    return BackgroundWrappers.onboarding(this);
  }

  /// Apply auth background
  Widget withAuthBackground() {
    return BackgroundWrappers.auth(this);
  }

  /// Apply role selection background
  Widget withRoleSelectionBackground() {
    return BackgroundWrappers.roleSelection(this);
  }

  /// Apply demo background
  Widget withDemoBackground() {
    return BackgroundWrappers.demo(this);
  }

  /// Apply custom background
  Widget withCustomBackground(SharexeBackgroundType type) {
    return BackgroundWrappers.custom(this, type);
  }
}
