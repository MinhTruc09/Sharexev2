import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/logic/registration/registration_cubit.dart';
import 'package:sharexev2/presentation/widgets/common/auth_container.dart';
import 'package:sharexev2/presentation/widgets/common/auth_button.dart';
import 'package:sharexev2/presentation/widgets/registration/image_upload_widget.dart';
import 'package:sharexev2/config/theme.dart';

class RegistrationStepTwo extends StatefulWidget {
  final String role;

  const RegistrationStepTwo({super.key, required this.role});

  @override
  State<RegistrationStepTwo> createState() => _RegistrationStepTwoState();
}

class _RegistrationStepTwoState extends State<RegistrationStepTwo>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _slideController,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Progress indicator
              _buildProgressIndicator(),

              const SizedBox(height: 32),

              // Phone number field
              AuthInputField(
                label: 'Số điện thoại',
                hint: 'Nhập số điện thoại của bạn',
                role: widget.role,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  context.read<RegistrationCubit>().updatePhoneNumber(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Profile image upload
              BlocBuilder<RegistrationCubit, RegistrationState>(
                builder: (context, state) {
                  return ImageUploadWidget(
                    label: 'Ảnh đại diện',
                    hint: 'Chọn ảnh đại diện để hiển thị trong profile',
                    role: widget.role,
                    image: state.data.profileImage,
                    isRequired: false,
                    onImageSelected: (image) {
                      context.read<RegistrationCubit>().updateProfileImage(
                        image,
                      );
                    },
                  );
                },
              ),

              // Driver specific fields
              if (widget.role == 'DRIVER') ...[
                const SizedBox(height: 24),
                _buildDriverFields(),
              ],

              const SizedBox(height: 32),

              // Action buttons
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bước 2/2',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 1.0,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            widget.role == 'PASSENGER' ? Colors.blue : Colors.green,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildDriverFields() {
    return BlocBuilder<RegistrationCubit, RegistrationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Vehicle image
            ImageUploadWidget(
              label: 'Ảnh xe',
              hint: 'Chụp ảnh xe của bạn (góc nghiêng, rõ biển số)',
              role: widget.role,
              image: state.data.vehicleImage,
              onImageSelected: (image) {
                context.read<RegistrationCubit>().updateVehicleImage(image);
              },
            ),

            const SizedBox(height: 24),

            // License image
            ImageUploadWidget(
              label: 'Ảnh bằng lái xe',
              hint: 'Chụp ảnh mặt trước bằng lái xe (rõ nét, không bị mờ)',
              role: widget.role,
              image: state.data.licenseImage,
              onImageSelected: (image) {
                context.read<RegistrationCubit>().updateLicenseImage(image);
              },
            ),

            const SizedBox(height: 24),

            // License plate image
            ImageUploadWidget(
              label: 'Ảnh biển số xe',
              hint: 'Chụp ảnh biển số xe rõ nét',
              role: widget.role,
              image: state.data.licensePlateImage,
              onImageSelected: (image) {
                context.read<RegistrationCubit>().updateLicensePlateImage(
                  image,
                );
              },
            ),

            const SizedBox(height: 16),

            // Driver approval notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tài khoản tài xế sẽ được admin xem xét và phê duyệt trong vòng 24-48 giờ.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<RegistrationCubit, RegistrationState>(
      builder: (context, state) {
        return Column(
          children: [
            // Register button
            AuthButton(
              text: widget.role == 'DRIVER' ? 'Gửi yêu cầu' : 'Đăng ký',
              role: widget.role,
              icon: widget.role == 'DRIVER' ? Icons.send : Icons.check,
              isLoading: state.status == RegistrationStatus.loading,
              onPressed: state.canSubmit ? _handleSubmit : null,
            ),

            SizedBox(height: 16),

            // Back button
            AuthButton(
              text: 'Quay lại',
              role: widget.role,
              icon: Icons.arrow_back,
              isOutlined: true,
              onPressed:
                  state.status == RegistrationStatus.loading
                      ? null
                      : _handleBack,
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<RegistrationCubit>().submitRegistration();
    }
  }

  void _handleBack() {
    context.read<RegistrationCubit>().goBackToStepOne();
  }
}
