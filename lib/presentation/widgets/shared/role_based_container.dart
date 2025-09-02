import 'package:flutter/material.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/backgrounds/background_wrapper.dart';

/// Role-based Container Widget - Combines AuthContainer with ShareXe backgrounds
/// Supports different container types and role-based styling
class RoleBasedContainer extends StatelessWidget {
  final String role;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBackPressed;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final EdgeInsetsGeometry? padding;
  final bool showBackButton;
  final ContainerType type;
  final bool useBackground;

  const RoleBasedContainer({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBackPressed,
    this.headerWidget,
    this.footerWidget,
    this.padding,
    this.showBackButton = true,
    this.type = ContainerType.auth,
    this.useBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassenger = role.toUpperCase() == 'PASSENGER';
    final accentColor = isPassenger ? AppColors.passengerPrimary : AppColors.driverPrimary;
    final accentGradient = isPassenger ? AppGradients.grabPrimary : AppGradients.driverPrimary;

    if (useBackground && type == ContainerType.roleSelection) {
      return _buildWithBackground(context, theme, accentColor, accentGradient);
    }

    return _buildStandardContainer(context, theme, accentColor, accentGradient);
  }

  Widget _buildWithBackground(BuildContext context, ThemeData theme, Color accentColor, LinearGradient accentGradient) {
    return BackgroundWrappers.roleSelection(
      Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: accentGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // App bar with back button
                    if (showBackButton)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: onBackPressed ?? () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 24,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.circle),
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),

                    // Header content
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.screenPadding,
                        right: AppSpacing.screenPadding,
                        top: showBackButton ? AppSpacing.lg : AppSpacing.xl,
                        bottom: AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Role indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppRadius.circle),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPassenger ? Icons.person : Icons.drive_eta,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isPassenger ? 'Hành khách' : 'Tài xế',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Title
                          Text(
                            title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Subtitle
                          Text(
                            subtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),

                          // Custom header widget
                          if (headerWidget != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            headerWidget!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.screenPadding),
                  child: child,
                ),
              ),

              // Footer widget
              if (footerWidget != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                  ),
                  child: footerWidget!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardContainer(BuildContext context, ThemeData theme, Color accentColor, LinearGradient accentGradient) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: accentGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // App bar with back button
                  if (showBackButton)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: onBackPressed ?? () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.circle),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                  // Header content
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacing.screenPadding,
                      right: AppSpacing.screenPadding,
                      top: showBackButton ? AppSpacing.lg : AppSpacing.xl,
                      bottom: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Role indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.circle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPassenger ? Icons.person : Icons.drive_eta,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                isPassenger ? 'Hành khách' : 'Tài xế',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Title
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Subtitle
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),

                        // Custom header widget
                        if (headerWidget != null) ...[
                          const SizedBox(height: AppSpacing.lg),
                          headerWidget!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: padding ?? const EdgeInsets.all(AppSpacing.screenPadding),
                child: child,
              ),
            ),

            // Footer widget
            if (footerWidget != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: footerWidget!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum ContainerType {
  auth,
  roleSelection,
  standard,
}
