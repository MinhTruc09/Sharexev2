import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/profile/profile_cubit.dart';
import 'package:sharexev2/presentation/widgets/profile/profile_header.dart';
import 'package:sharexev2/presentation/widgets/profile/profile_info_section.dart';
import 'package:sharexev2/presentation/widgets/profile/profile_settings_section.dart';

class ProfilePage extends StatelessWidget {
  final String role;

  const ProfilePage({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(
        userRepository: null, // TODO: Inject repositories
        authRepository: null,
      )..initializeProfile(role),
      child: ProfileView(role: role),
    );
  }
}

class ProfileView extends StatefulWidget {
  final String role;

  const ProfileView({
    super.key,
    required this.role,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // This will be called by the cubit
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: const Color(0xFFE53E3E),
              action: SnackBarAction(
                label: 'Đóng',
                textColor: Colors.white,
                onPressed: () {
                  context.read<ProfileCubit>().clearError();
                },
              ),
            ),
          );
        }
        
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thông tin đã được cập nhật!'),
              backgroundColor: const Color(0xFF38A169),
            ),
          );
          context.read<ProfileCubit>().resetStatus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar() as PreferredSizeWidget,
        body: SingleChildScrollView(
                      child: Column(
              children: [
                ProfileHeader(role: widget.role),
                ProfileInfoSection(role: widget.role),
                ProfileSettingsSection(),
                const SizedBox(height: 32),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return AppBar(
          backgroundColor: ThemeManager.getPrimaryColorForRole(widget.role),
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Hồ sơ cá nhân',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(state.isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (state.isEditing) {
                  context.read<ProfileCubit>().saveProfile();
                } else {
                  context.read<ProfileCubit>().toggleEditMode();
                }
              },
            ),
          ],
        );
      },
    );
  }










}
