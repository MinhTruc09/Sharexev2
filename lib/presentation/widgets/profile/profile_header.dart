import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/profile/profile_cubit.dart';
import 'package:sharexev2/presentation/widgets/common/profile_avatar_picker.dart';

class ProfileHeader extends StatelessWidget {
  final String role;

  const ProfileHeader({
    super.key,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeManager.getPrimaryColorForRole(role),
                ThemeManager.getPrimaryColorForRole(role).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    ProfileAvatarPicker(
                      initials: state.userName.isNotEmpty 
                          ? state.userName.split(' ').map((e) => e[0]).take(2).join('').toUpperCase()
                          : 'NA',
                      role: role,
                      size: 120,
                      onImageSelected: (imageBytes) {
                        if (imageBytes != null) {
                          context.read<ProfileCubit>().updateAvatar(imageBytes);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.userName.isNotEmpty ? state.userName : 'Chưa có tên',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      role == 'PASSENGER' ? 'Hành khách' : 'Tài xế',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
