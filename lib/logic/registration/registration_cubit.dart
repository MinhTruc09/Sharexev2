import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/registration_models.dart';
import 'package:sharexev2/data/models/auth/entities/auth_credentials.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';

part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final AuthRepositoryInterface? _authRepository;
  final String role;

  RegistrationCubit({
    required AuthRepositoryInterface? authRepository,
    required this.role,
  }) : _authRepository = authRepository,
       super(RegistrationState(role: role));

  void updateEmail(String email) {
    emit(state.copyWith(data: state.data.copyWith(email: email), error: null));
  }

  void updateFullName(String fullName) {
    emit(
      state.copyWith(
        data: state.data.copyWith(fullName: fullName),
        error: null,
      ),
    );
  }

  void updatePassword(String password) {
    emit(
      state.copyWith(
        data: state.data.copyWith(password: password),
        error: null,
      ),
    );
  }

  void updateConfirmPassword(String confirmPassword) {
    emit(
      state.copyWith(
        data: state.data.copyWith(confirmPassword: confirmPassword),
        error: null,
      ),
    );
  }

  void updatePhoneNumber(String phoneNumber) {
    emit(
      state.copyWith(
        data: state.data.copyWith(phoneNumber: phoneNumber),
        error: null,
      ),
    );
  }

  void updateProfileImage(File? image) {
    emit(
      state.copyWith(
        data: state.data.copyWith(profileImage: image),
        error: null,
      ),
    );
  }

  void updateVehicleImage(File? image) {
    emit(
      state.copyWith(
        data: state.data.copyWith(vehicleImage: image),
        error: null,
      ),
    );
  }

  void updateLicenseImage(File? image) {
    emit(
      state.copyWith(
        data: state.data.copyWith(licenseImage: image),
        error: null,
      ),
    );
  }

  void updateLicensePlateImage(File? image) {
    emit(
      state.copyWith(
        data: state.data.copyWith(licensePlateImage: image),
        error: null,
      ),
    );
  }

  void goToStepTwo() {
    if (!state.data.isStepOneValid) {
      emit(
        state.copyWith(
          error: 'Vui lòng điền đầy đủ thông tin và kiểm tra mật khẩu',
        ),
      );
      return;
    }

    if (state.data.password != state.data.confirmPassword) {
      emit(state.copyWith(error: 'Mật khẩu xác nhận không khớp'));
      return;
    }

    emit(state.copyWith(currentStep: RegistrationStep.stepTwo, error: null));
  }

  void goBackToStepOne() {
    emit(state.copyWith(currentStep: RegistrationStep.stepOne, error: null));
  }

  /// Register with RegisterCredentials (new unified method)
  Future<void> registerWithEmail(
    RegisterCredentials credentials,
    String role,
  ) async {
    emit(state.copyWith(status: RegistrationStatus.loading));

    try {
      if (_authRepository != null) {
        // Use real registration through repository
        if (role.toUpperCase() == 'DRIVER') {
          // Prefer multipart when images/vehicle info present
          final hasImages =
              credentials.avatarImage != null ||
              credentials.licenseImage != null ||
              credentials.vehicleImage != null;
          if (hasImages) {
            // Call through service via repository mapping (temporary direct call since repo API is DTO-based)
            // Fallback to existing repo method if needed
            final result = await _authRepository!.registerDriver(credentials);
            if (result.isSuccess) {
              emit(
                state.copyWith(status: RegistrationStatus.success, error: null),
              );
            } else {
              emit(
                state.copyWith(
                  status: RegistrationStatus.error,
                  error: result.failure?.message ?? 'Đăng ký thất bại',
                ),
              );
            }
            return;
          }
          final result = await _authRepository!.registerDriver(credentials);
          if (result.isSuccess) {
            emit(
              state.copyWith(status: RegistrationStatus.success, error: null),
            );
          } else {
            emit(
              state.copyWith(
                status: RegistrationStatus.error,
                error: result.failure?.message ?? 'Đăng ký thất bại',
              ),
            );
          }
        } else {
          final result = await _authRepository!.registerPassenger(credentials);
          if (result.isSuccess) {
            emit(
              state.copyWith(status: RegistrationStatus.success, error: null),
            );
          } else {
            emit(
              state.copyWith(
                status: RegistrationStatus.error,
                error: result.failure?.message ?? 'Đăng ký thất bại',
              ),
            );
          }
        }
      } else {
        // No repository available - show error
        emit(
          state.copyWith(
            status: RegistrationStatus.error,
            error: 'Service không khả dụng, vui lòng thử lại sau',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistrationStatus.error,
          error: 'Đăng ký thất bại: $e',
        ),
      );
    }
  }

  /// Register with Google (new unified method)
  Future<void> registerWithGoogle(String role) async {
    emit(state.copyWith(status: RegistrationStatus.loading));

    try {
      if (_authRepository != null) {
        // Google registration not yet implemented in backend
        emit(
          state.copyWith(
            status: RegistrationStatus.error,
            error:
                'Đăng ký Google đang được phát triển, vui lòng sử dụng email/password',
          ),
        );
      } else {
        // No repository available - show error
        emit(
          state.copyWith(
            status: RegistrationStatus.error,
            error: 'Service không khả dụng, vui lòng thử lại sau',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RegistrationStatus.error,
          error: 'Đăng ký Google thất bại: $e',
        ),
      );
    }
  }

  Future<void> submitRegistration() async {
    if (!state.data.isStepTwoValidForRole(role)) {
      String errorMessage =
          role == 'PASSENGER'
              ? 'Vui lòng điền số điện thoại'
              : 'Vui lòng điền đầy đủ thông tin và upload tất cả ảnh';
      emit(state.copyWith(error: errorMessage));
      return;
    }

    emit(state.copyWith(status: RegistrationStatus.loading));

    try {
      // Prepare additional data
      Map<String, dynamic> additionalData = {
        'phone': state.data.phoneNumber,
        'profileImagePath': state.data.profileImage?.path,
      };

      // Add driver specific data
      if (role == 'DRIVER') {
        additionalData.addAll({
          'vehicleImagePath': state.data.vehicleImage?.path,
          'licenseImagePath': state.data.licenseImage?.path,
          'licensePlateImagePath': state.data.licensePlateImage?.path,
          'approvalStatus': DriverApprovalStatus.pending.name,
        });
      }

      if (_authRepository != null) {
        // Use real registration through repository
        if (role == 'DRIVER') {
          // Create RegisterCredentials object for driver
          final credentials = RegisterCredentials(
            email: state.data.email ?? '',
            password: state.data.password ?? '',
            fullName: state.data.fullName ?? '',
            phoneNumber: state.data.phoneNumber,
            licenseNumber: state.data.licensePlate,
            brand: state.data.vehicleBrand,
            model: state.data.vehicleModel,
            color: state.data.vehicleColor,
            numberOfSeats: state.data.numberOfSeats,
            avatarImage: state.data.profileImage,
            licenseImage: state.data.licenseImage,
            vehicleImage: state.data.vehicleImage,
          );

          final response = await _authRepository.registerDriver(credentials);

          if (response.isSuccess) {
            emit(state.copyWith(status: RegistrationStatus.success));
          } else {
            emit(
              state.copyWith(
                status: RegistrationStatus.error,
                error: response.failure?.message ?? 'Đăng ký tài xế thất bại',
              ),
            );
          }
        } else {
          // Create RegisterCredentials object for passenger
          final credentials = RegisterCredentials(
            email: state.data.email ?? '',
            password: state.data.password ?? '',
            fullName: state.data.fullName ?? '',
            phoneNumber: state.data.phoneNumber,
            avatarImage: state.data.profileImage,
          );

          final response = await _authRepository.registerPassenger(credentials);

          if (response.isSuccess) {
            emit(state.copyWith(status: RegistrationStatus.success));
          } else {
            emit(
              state.copyWith(
                status: RegistrationStatus.error,
                error:
                    response.failure?.message ?? 'Đăng ký hành khách thất bại',
              ),
            );
          }
        }
      } else {
        emit(
          state.copyWith(
            status: RegistrationStatus.error,
            error: 'Auth repository không khả dụng',
          ),
        );
        return;
      }

      // For drivers, set pending approval status
      if (role == 'DRIVER') {
        emit(
          state.copyWith(
            status: RegistrationStatus.success,
            data: state.data.copyWith(
              approvalStatus: DriverApprovalStatus.pending,
            ),
          ),
        );
      } else {
        emit(state.copyWith(status: RegistrationStatus.success));
      }
    } catch (e) {
      emit(
        state.copyWith(status: RegistrationStatus.error, error: e.toString()),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void reset() {
    emit(RegistrationState(role: role));
  }
}
