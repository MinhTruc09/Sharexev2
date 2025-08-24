import 'package:flutter/material.dart';

/// ShareXe Background Widget - Variant 1 (Blue with clouds)
class SharexeBackground extends StatelessWidget {
  final Widget child;
  const SharexeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF00AEEF),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Đám mây góc trên bên trái
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_left.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              // Đám mây góc trên bên phải
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_right.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              // Đám mây dưới cùng
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_bottom.png',
                  height: screenHeight * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              // Widget con (ví dụ logo, form, ...)
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// ShareXe Background Widget - Variant 2 (Blue with sun)
class SharexeBackground1 extends StatelessWidget {
  final Widget child;
  const SharexeBackground1({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF00AEEF),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Mặt trời góc trên bên trái
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/widgets/sun_left.png',
                  width: screenWidth * 0.15,
                  fit: BoxFit.contain,
                ),
              ),
              // Đám mây góc trên bên phải
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_right.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              // Đám mây dưới cùng
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_bottom.png',
                  height: screenHeight * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              // Widget con (ví dụ logo, form, ...)
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// ShareXe Background Widget - Variant 3 (Dark blue with clouds)
class SharexeBackground2 extends StatelessWidget {
  final Widget child;
  const SharexeBackground2({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFF003087),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Đám mây góc trên bên trái
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_left.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              // Đám mây góc trên bên phải
              Positioned(
                top: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_right.png',
                  width: screenWidth * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
              // Đám mây dưới cùng
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/widgets/cloud_bottom.png',
                  height: screenHeight * 0.4,
                  fit: BoxFit.cover,
                ),
              ),
              // Widget con (ví dụ logo, form, ...)
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Background type enum for easy selection
enum SharexeBackgroundType {
  blueWithClouds,    // SharexeBackground
  blueWithSun,       // SharexeBackground1
  darkBlueWithClouds // SharexeBackground2
}

/// Factory widget to create the appropriate background based on type
class SharexeBackgroundFactory extends StatelessWidget {
  final Widget child;
  final SharexeBackgroundType type;

  const SharexeBackgroundFactory({
    super.key,
    required this.child,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SharexeBackgroundType.blueWithClouds:
        return SharexeBackground(child: child);
      case SharexeBackgroundType.blueWithSun:
        return SharexeBackground1(child: child);
      case SharexeBackgroundType.darkBlueWithClouds:
        return SharexeBackground2(child: child);
    }
  }
}
