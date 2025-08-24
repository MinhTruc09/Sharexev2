import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/logic/profile/profile_cubit.dart';

class ProfileInfoSection extends StatefulWidget {
  final String role;

  const ProfileInfoSection({
    super.key,
    required this.role,
  });

  @override
  State<ProfileInfoSection> createState() => _ProfileInfoSectionState();
}

class _ProfileInfoSectionState extends State<ProfileInfoSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin cá nhân',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildInfoField(
                label: 'Họ và tên',
                controller: _nameController,
                icon: Icons.person,
                enabled: state.isEditing,
                onChanged: (value) {
                  context.read<ProfileCubit>().updateName(value);
                },
                initialValue: state.userName,
              ),
              const SizedBox(height: 16),
              
              _buildInfoField(
                label: 'Email',
                controller: _emailController,
                icon: Icons.email,
                enabled: false, // Email không được sửa
                initialValue: state.userEmail,
              ),
              const SizedBox(height: 16),
              
              _buildInfoField(
                label: 'Số điện thoại',
                controller: _phoneController,
                icon: Icons.phone,
                enabled: state.isEditing,
                onChanged: (value) {
                  context.read<ProfileCubit>().updatePhone(value);
                },
                initialValue: state.userPhone,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    String? initialValue,
    Function(String)? onChanged,
  }) {
    // Set initial value if provided
    if (initialValue != null && controller.text != initialValue) {
      controller.text = initialValue;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Icon(icon, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
