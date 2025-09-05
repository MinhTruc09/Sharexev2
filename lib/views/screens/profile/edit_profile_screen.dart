import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharexev2/core/di/service_locator.dart';
import 'package:sharexev2/logic/profile/profile_cubit.dart';
import 'package:sharexev2/config/theme.dart';

/// Screen chỉnh sửa thông tin cá nhân
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // Get user data from AuthCubit when available
    // For now, use default values until AuthCubit is properly integrated
    _userRole = 'PASSENGER';
    
    // Pre-fill form will be handled by ProfileState updates from ProfileCubit
    // The ProfileCubit will load user data and update the form through BlocBuilder
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _userRole == 'DRIVER' 
        ? AppColors.driverPrimary 
        : AppColors.passengerPrimary;

    return BlocProvider(
      create: (_) => ProfileCubit(
        userRepository: ServiceLocator.get(),
        authRepository: ServiceLocator.get(),
      )..initializeProfile(_userRole ?? 'PASSENGER'), // Initialize profile with user role
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(primaryColor),
        body: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            // Handle real ProfileStatus when available
            if (state.status == ProfileStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cập nhật thông tin thành công!'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            } else if (state.status == ProfileStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Có lỗi xảy ra'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            setState(() {
              _isLoading = state.status == ProfileStatus.saving;
            });
          },
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              // Update form fields when profile data is loaded
              if (state.status == ProfileStatus.loaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fullNameController.text = state.userName;
                  _phoneController.text = state.userPhone;
                  _emailController.text = state.userEmail;
                  // Update other fields as needed
                });
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAvatarSection(primaryColor),
                      const SizedBox(height: 24),
                      _buildPersonalInfoSection(primaryColor),
                      const SizedBox(height: 24),
                      _buildContactInfoSection(primaryColor),
                      const SizedBox(height: 24),
                      _buildAdditionalInfoSection(primaryColor),
                      const SizedBox(height: 32),
                      _buildUpdateButton(primaryColor),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      title: const Text('Cập nhật thông tin'),
      elevation: 0,
      actions: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarSection(Color primaryColor) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Ảnh đại diện',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : _buildDefaultAvatar(), // Will load real avatar from user profile
                    ),
                  ),
                  
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Text(
                'Nhấn vào biểu tượng máy ảnh để thay đổi',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.borderLight,
      child: Icon(
        Icons.person,
        size: 60,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildPersonalInfoSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Thông tin cá nhân',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCustomTextField(
            controller: _fullNameController,
            label: 'Họ và tên',
            hint: 'Nhập họ và tên đầy đủ',
            icon: Icons.person,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildCustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Nhập địa chỉ email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            enabled: false, // Email usually cannot be changed
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_outlined, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Thông tin liên hệ',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCustomTextField(
            controller: _phoneController,
            label: 'Số điện thoại',
            hint: 'Nhập số điện thoại',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập số điện thoại';
              }
              if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value!)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildCustomTextField(
            controller: _addressController,
            label: 'Địa chỉ',
            hint: 'Nhập địa chỉ hiện tại',
            icon: Icons.location_on,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Thông tin bổ sung',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildCustomTextField(
            controller: _bioController,
            label: 'Giới thiệu bản thân',
            hint: 'Viết vài dòng giới thiệu về bạn...',
            icon: Icons.description,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: controller.text.isEmpty ? hint : null,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: enabled ? AppColors.background : AppColors.borderLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildUpdateButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: _isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          _isLoading ? 'Đang cập nhật...' : 'Cập nhật thông tin',
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Chọn ảnh đại diện',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.info),
              ),
              title: const Text('Chụp ảnh mới'),
              subtitle: const Text('Sử dụng camera để chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_library, color: AppColors.success),
              ),
              title: const Text('Chọn từ thư viện'),
              subtitle: const Text('Chọn ảnh có sẵn trong điện thoại'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null) // Show remove option when image is selected
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete, color: AppColors.error),
                ),
                title: const Text('Xóa ảnh'),
                subtitle: const Text('Sử dụng ảnh mặc định'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement real updateProfile with ProfileCubit
      // final profileData = {
      //   'fullName': _fullNameController.text.trim(),
      //   'phoneNumber': _phoneController.text.trim(),
      //   'address': _addressController.text.trim(),
      //   'bio': _bioController.text.trim(),
      //   if (_selectedImage != null) 'avatar': _selectedImage,
      // };
      
      // Update ProfileCubit with form data
      context.read<ProfileCubit>().updateName(_fullNameController.text.trim());
      context.read<ProfileCubit>().updatePhone(_phoneController.text.trim());
      
      // Save profile using ProfileCubit
      await context.read<ProfileCubit>().saveProfile();
    }
  }
}
