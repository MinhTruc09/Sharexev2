import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';

class AuthContainer extends StatelessWidget {
  final String role;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBackPressed;
  final bool showRoleIndicator;

  const AuthContainer({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBackPressed,
    this.showRoleIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getGradient(role),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Content Container
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXl),
                      topRight: Radius.circular(AppTheme.radiusXl),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusXl),
                      topRight: Radius.circular(AppTheme.radiusXl),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: child,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          // Back button and role indicator
          Row(
            children: [
              if (onBackPressed != null)
                IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              const Spacer(),
              if (showRoleIndicator)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: AppTheme.spacingS),
                      Text(
                        _getRoleDisplayName(role),
                        style: AppTheme.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacingL),
          
          // Title and subtitle
          Column(
            children: [
              Text(
                title,
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppTheme.spacingS),
              Text(
                subtitle,
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AuthInputField extends StatefulWidget {
  final String label;
  final String hint;
  final String role;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;

  const AuthInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.role,
    this.controller,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: AppTheme.labelLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: AppTheme.spacingS),
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isFocused = hasFocus;
                  });
                  if (hasFocus) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                },
                child: TextFormField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  validator: widget.validator,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  enabled: widget.enabled,
                  decoration: AppTheme.getInputDecoration(
                    hintText: widget.hint,
                    role: widget.role,
                    suffixIcon: widget.suffixIcon,

                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AuthPasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final String role;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.role,
    this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthInputField(
      label: widget.label,
      hint: widget.hint,
      role: widget.role,
      controller: widget.controller,
      onChanged: widget.onChanged,
      validator: widget.validator,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppTheme.getPrimaryColor(widget.role),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

// Helper methods for role icons and display names
IconData _getRoleIcon(String role) {
  switch (role.toUpperCase()) {
    case 'PASSENGER':
      return Icons.person;
    case 'DRIVER':
      return Icons.drive_eta;
    default:
      return Icons.person;
  }
}

String _getRoleDisplayName(String role) {
  switch (role.toUpperCase()) {
    case 'PASSENGER':
      return 'Hành khách';
    case 'DRIVER':
      return 'Tài xế';
    default:
      return 'Người dùng';
  }
}
