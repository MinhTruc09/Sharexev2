import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/auth/login_content.dart';

class DriverLoginContent extends StatefulWidget {
  final VoidCallback? onRegisterPressed;

  const DriverLoginContent({super.key, this.onRegisterPressed});

  @override
  State<DriverLoginContent> createState() => _DriverLoginContentState();
}

class _DriverLoginContentState extends State<DriverLoginContent> {
  @override
  Widget build(BuildContext context) {
    return LoginContent(
      role: 'DRIVER',
      onRegisterPressed: widget.onRegisterPressed,
    );
  }
}
