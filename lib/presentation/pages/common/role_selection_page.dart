import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/role_repository.dart';
import 'package:sharexev2/logic/roleselection/role_selection_cubit.dart';
import 'package:sharexev2/logic/roleselection/role_selection_state.dart';
import 'package:sharexev2/presentation/widgets/splash_content.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/routes/app_routes.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _buttonsController;
  late Animation<double> _backgroundOpacity;
  late Animation<Offset> _buttonsSlide;
  late Animation<double> _buttonsOpacity;

  String? _selectedRole;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeIn),
    );

    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutBack),
    );

    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() async {
    _backgroundController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoleSelectionCubit(LocalRoleRepository()),
      child: BlocConsumer<RoleSelectionCubit, RoleSelectionState>(
        listener: (context, state) async {
          if (state.status == RoleStatus.saving && state.pendingRole != null) {
            if (!context.mounted) return;

            // Show transition animation
            setState(() {
              _isTransitioning = true;
            });

            // Wait for animation then navigate
            await Future.delayed(const Duration(milliseconds: 1500));

            if (!context.mounted) return;
            Navigator.pushReplacementNamed(
              context,
              AppRoute.login,
              arguments: state.pendingRole!,
            );
            return;
          }

          if (state.status == RoleStatus.success) {
            final cubit = context.read<RoleSelectionCubit>();
            final role = await cubit.getRole();
            if (!context.mounted || role == null) return;

            Navigator.pushReplacementNamed(
              context,
              AppRoute.login,
              arguments: role,
            );
          }

          if (state.status == RoleStatus.error && state.error != null) {
            setState(() {
              _isTransitioning = false;
              _selectedRole = null;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isTransitioning && _selectedRole != null) {
            return _buildTransitionView();
          }

          return _buildRoleSelectionView(context, state);
        },
      ),
    );
  }

  Widget _buildTransitionView() {
    return SplashContent(
      role: _selectedRole,
      thumbNail:
          _selectedRole == 'PASSENGER'
              ? 'Chào mừng hành khách!'
              : 'Chào mừng tài xế!',
      imagePathLogo:
          _selectedRole == 'PASSENGER'
              ? 'assets/images/logos/PassS.png'
              : 'assets/images/logos/driver_S.png',
      imagePathLeft:
          _selectedRole == 'PASSENGER'
              ? 'assets/images/widgets/cloud_blue_left.png'
              : 'assets/images/widgets/cloud_left.png',
      imagePathRight: 'assets/images/widgets/cloud_right.png',
      imagePathBot:
          _selectedRole == 'PASSENGER'
              ? 'assets/images/commons/Passengerblue.png'
              : 'assets/images/commons/car.png',
    );
  }

  Widget _buildRoleSelectionView(
    BuildContext context,
    RoleSelectionState state,
  ) {
    final cubit = context.read<RoleSelectionCubit>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF3F51B5)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _backgroundOpacity,
            builder: (context, child) {
              return Opacity(
                opacity: _backgroundOpacity.value,
                child: Stack(
                  children: [
                    // Background elements
                    Positioned(
                      top: -50,
                      left: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        children: [
                          // Header
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logos/smokelogo.png',
                                  width: 120,
                                  height: 120,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusL,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.directions_car,
                                        size: 60,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: AppTheme.spacingL),
                                Text(
                                  'Chào mừng đến với ShareXe',
                                  style: AppTheme.headingLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: AppTheme.spacingM),
                                Text(
                                  'Vui lòng chọn vai trò của bạn để tiếp tục',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Role selection buttons
                          Expanded(
                            flex: 1,
                            child: AnimatedBuilder(
                              animation: _buttonsController,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: _buttonsSlide,
                                  child: Opacity(
                                    opacity: _buttonsOpacity.value,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildRoleButton(
                                          context: context,
                                          role: 'PASSENGER',
                                          title: 'Tôi là Hành khách',
                                          subtitle: 'Tìm kiếm chuyến đi',
                                          icon: Icons.person,
                                          isLoading:
                                              state.status ==
                                                  RoleStatus.saving &&
                                              state.pendingRole == 'PASSENGER',
                                          onPressed:
                                              () => _selectRole(
                                                cubit,
                                                'PASSENGER',
                                              ),
                                        ),

                                        SizedBox(height: AppTheme.spacingL),

                                        _buildRoleButton(
                                          context: context,
                                          role: 'DRIVER',
                                          title: 'Tôi là Tài xế',
                                          subtitle: 'Cung cấp chuyến đi',
                                          icon: Icons.drive_eta,
                                          isLoading:
                                              state.status ==
                                                  RoleStatus.saving &&
                                              state.pendingRole == 'DRIVER',
                                          onPressed:
                                              () =>
                                                  _selectRole(cubit, 'DRIVER'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    final isSelected = _selectedRole == role;
    final primaryColor = AppTheme.getPrimaryColor(role);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? primaryColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.shadowMedium : AppTheme.shadowLight,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingM),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? primaryColor
                              : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child:
                        isLoading
                            ? CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isSelected ? Colors.white : primaryColor,
                              ),
                            )
                            : Icon(
                              icon,
                              color: isSelected ? Colors.white : primaryColor,
                              size: 24,
                            ),
                  ),

                  SizedBox(width: AppTheme.spacingM),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTheme.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppTheme.spacingXs),
                        Text(
                          subtitle,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.6),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectRole(RoleSelectionCubit cubit, String role) {
    setState(() {
      _selectedRole = role;
    });

    // Add haptic feedback
    // HapticFeedback.lightImpact();

    cubit.selectRole(role);
  }
}
