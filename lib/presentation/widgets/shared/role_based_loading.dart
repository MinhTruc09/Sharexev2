import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/backgrounds/background_wrapper.dart';

/// Role-based Loading Screen with personalized styling
class RoleBasedLoading extends StatefulWidget {
  final String role;
  final String? message;
  final bool showBackground;
  final double? size;

  const RoleBasedLoading({
    super.key,
    required this.role,
    this.message,
    this.showBackground = true,
    this.size,
  });

  @override
  State<RoleBasedLoading> createState() => _RoleBasedLoadingState();
}

class _RoleBasedLoadingState extends State<RoleBasedLoading>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPassenger = widget.role.toUpperCase() == 'PASSENGER';
    final accentColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;
    final roleIcon = isPassenger ? Icons.person : Icons.drive_eta;
    final roleName = isPassenger ? 'Hành khách' : 'Tài xế';

    Widget content = Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Role-based loading indicator
            AnimatedBuilder(
              animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size ?? 120,
                    height: widget.size ?? 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating border
                        Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Container(
                            width: widget.size ?? 120,
                            height: widget.size ?? 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                        // Role icon
                        Icon(
                          roleIcon,
                          size: (widget.size ?? 120) * 0.4,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Role indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.circle),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    roleIcon,
                    color: accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    roleName,
                    style: AppTheme.labelLarge.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Loading message
            if (widget.message != null) ...[
              Text(
                widget.message!,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Loading dots
            _buildLoadingDots(accentColor),
          ],
        ),
      ),
    );

    if (widget.showBackground) {
      return BackgroundWrappers.roleSelection(content);
    }

    return content;
  }

  Widget _buildLoadingDots(Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_pulseController.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Role-based loading overlay for existing screens
class RoleBasedLoadingOverlay extends StatelessWidget {
  final String role;
  final String? message;
  final bool isLoading;
  final Widget child;

  const RoleBasedLoadingOverlay({
    super.key,
    required this.role,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                margin: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: RoleBasedLoading(
                  role: role,
                  message: message,
                  showBackground: false,
                  size: 80,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Extension for easy loading overlay application
extension RoleBasedLoadingExtension on Widget {
  Widget withRoleBasedLoading({
    required String role,
    required bool isLoading,
    String? message,
  }) {
    return RoleBasedLoadingOverlay(
      role: role,
      isLoading: isLoading,
      message: message,
      child: this,
    );
  }
}
