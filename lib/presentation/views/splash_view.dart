import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/splash_content.dart';

class SplashView extends StatelessWidget {
  final String? role;

  const SplashView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Tái sử dụng SplashContent với 3 bộ assets khác nhau cho từng role
    final bool isPassenger = role == 'PASSENGER';
    final bool isDriver = role == 'DRIVER';

    // Bộ assets cho PASSENGER
    if (isPassenger) {
      return SplashContent(
        role: role,
        thumbNail: 'Xin chào hành khách!',
        imagePathLogo: 'assets/images/logos/PassS.png',
        imagePathLeft: 'assets/images/widgets/cloud_blue_left.png',
        imagePathRight: 'assets/images/widgets/cloud_right.png',
        imagePathBot: 'assets/images/commons/Passengerblue.png',
      );
    }

    // Bộ assets cho DRIVER
    if (isDriver) {
      return SplashContent(
        role: role,
        thumbNail: 'Xin chào tài xế!',
        imagePathLogo: 'assets/images/logos/driver_S.png',
        imagePathLeft: 'assets/images/widgets/cloud_left.png',
        imagePathRight: 'assets/images/widgets/cloud_right.png',
        imagePathBot: 'assets/images/commons/car.png',
      );
    }

    // Bộ assets mặc định (DEFAULT)
    return SplashContent(
      role: role,
      thumbNail: 'Chào mừng đến với ShareXe',
      imagePathLogo: 'assets/images/logos/smokelogo.png',
      imagePathLeft: 'assets/images/widgets/cloud_left.png',
      imagePathRight: 'assets/images/widgets/cloud_right.png',
      imagePathBot: 'assets/images/commons/carsmoke.png',
    );
  }
}
