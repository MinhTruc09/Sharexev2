import 'package:flutter/material.dart';
import 'package:sharexev2/presentation/widgets/auth/register_content.dart';

class DriverRegisterContent extends StatefulWidget {
  final VoidCallback? onLoginPressed;

  const DriverRegisterContent({super.key, this.onLoginPressed});

  @override
  State<DriverRegisterContent> createState() => _DriverRegisterContentState();
}

class _DriverRegisterContentState extends State<DriverRegisterContent> {
  @override
  Widget build(BuildContext context) {
    return RegisterContent(
      role: 'DRIVER',
      onLoginPressed: widget.onLoginPressed,
    );
  }
}
