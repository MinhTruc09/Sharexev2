import 'package:flutter/material.dart';

class RegisterContent extends StatefulWidget {
  final String role;
  final VoidCallback? onLoginPressed;

  const RegisterContent({super.key, required this.role, this.onLoginPressed});

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đăng ký',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.role == 'PASSENGER' ? 'Hành khách' : 'Tài xế',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Placeholder for register form
          const Center(child: Text('Register form coming soon...')),

          const SizedBox(height: 24),

          // Login link
          if (widget.onLoginPressed != null)
            TextButton(
              onPressed: widget.onLoginPressed,
              child: const Text('Đã có tài khoản? Đăng nhập'),
            ),
        ],
      ),
    );
  }
}
