import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/models/registration_models.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';

part 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  final dynamic _authRepository; // TODO: Type as AuthRepositoryInterface when DI is ready
  final String role;

  RegistrationCubit({
    required dynamic authRepository,
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
          // TODO: Implement driver registration with proper DTO mapping
          // final driverRequest = RegisterDriverRequestDto(...);
          // final authResponse = await _authRepository.registerDriver(driverRequest);
          emit(state.copyWith(
            status: RegistrationStatus.error,
            error: 'Driver registration API chưa được triển khai',
          ));
          return;
        } else {
          // TODO: Implement passenger registration with proper DTO mapping
          // final passengerRequest = RegisterPassengerRequestDto(...);
          // final authResponse = await _authRepository.registerPassenger(passengerRequest);
          emit(state.copyWith(
            status: RegistrationStatus.error,
            error: 'Passenger registration API chưa được triển khai',
          ));
          return;
        }
      } else {
        emit(state.copyWith(
          status: RegistrationStatus.error,
          error: 'Auth repository không khả dụng',
        ));
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
