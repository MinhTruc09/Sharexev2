import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharexev2/data/repositories/user/user_repository_interface.dart';
import 'package:sharexev2/data/repositories/auth/auth_repository_interface.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserRepositoryInterface? _userRepository;
  final AuthRepositoryInterface? _authRepository;

  ProfileCubit({
    required UserRepositoryInterface? userRepository,
    required AuthRepositoryInterface? authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository,
       super(const ProfileState());

  // ===== Repository Integration Methods =====

  /// Initialize profile and load user data from repository
  Future<void> initializeProfile(String role) async {
    emit(state.copyWith(role: role, status: ProfileStatus.loading));
    await _loadUserData();
  }

  /// Load user data from repository
  Future<void> _loadUserData() async {
    try {
      if (_userRepository != null) {
        final response = await _userRepository.getProfile();

        if (response.success && response.data != null) {
          final user = response.data!;
          emit(
            state.copyWith(
              status: ProfileStatus.loaded,
              userData: {
                'id': user.id,
                'name': user.fullName,
                'email': user.email,
                'phone': user.phoneNumber,
                'avatar': user.avatarUrl,
                'role': user.role.name,
                'isDriver': user.isDriver,
                'isPassenger': user.isPassenger,
                'isAdmin': user.isAdmin,
              },
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ProfileStatus.error,
              error: response.message ?? 'Failed to load profile',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            error: 'User repository không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, error: e.toString()));
    }
  }

  // ===== Local UI Update Methods =====

  void updateName(String name) {
    final updatedData = Map<String, dynamic>.from(state.userData);
    updatedData['name'] = name;

    emit(state.copyWith(userData: updatedData, error: null));
  }

  void updatePhone(String phone) {
    final updatedData = Map<String, dynamic>.from(state.userData);
    updatedData['phone'] = phone;

    emit(state.copyWith(userData: updatedData, error: null));
  }

  void updateAvatar(List<int>? imageBytes) {
    final updatedData = Map<String, dynamic>.from(state.userData);
    updatedData['avatar'] = imageBytes;

    emit(state.copyWith(userData: updatedData, error: null));
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditing: !state.isEditing, error: null));

    if (!state.isEditing) {
      // Reset to original values if canceling
      _loadUserData();
    }
  }

  /// Save profile changes to repository
  Future<void> saveProfile() async {
    if (!_validateProfile()) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: 'Vui lòng điền đầy đủ thông tin',
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProfileStatus.saving, error: null));

    try {
      if (_userRepository != null) {
        final userData = state.userData;
        final response = await _userRepository.updateProfile(
          phone: userData['phone'] ?? '',
          fullName: userData['name'] ?? '',
          licensePlate: userData['licensePlate'] ?? '',
          brand: userData['brand'] ?? '',
          model: userData['model'] ?? '',
          color: userData['color'] ?? '',
          numberOfSeats: userData['numberOfSeats'] ?? 4,
          vehicleImageUrl: userData['vehicleImageUrl'],
          licenseImageUrl: userData['licenseImageUrl'],
          avatarImageUrl: userData['avatar'],
        );

        if (response.success) {
          emit(
            state.copyWith(
              status: ProfileStatus.saved,
              isEditing: false,
              error: null,
            ),
          );
          // Reload fresh data from server
          await _loadUserData();
        } else {
          emit(
            state.copyWith(
              status: ProfileStatus.error,
              error: response.message ?? 'Failed to save profile',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            error: 'User repository không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: 'Lỗi lưu thông tin: $e',
        ),
      );
    }
  }

  /// Change password through repository
  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(state.copyWith(status: ProfileStatus.saving, error: null));

    try {
      if (_userRepository != null) {
        // Implement changePassword through UserRepository (PUT /api/user/change-pass)
        final response = await _userRepository.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );

        if (response.success) {
          emit(state.copyWith(status: ProfileStatus.saved, error: null));
        } else {
          emit(
            state.copyWith(
              status: ProfileStatus.error,
              error: response.message ?? 'Lỗi đổi mật khẩu',
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            error: 'User repository không khả dụng',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          error: 'Lỗi đổi mật khẩu: $e',
        ),
      );
    }
  }

  bool _validateProfile() {
    final name = state.userData['name'] as String?;
    final phone = state.userData['phone'] as String?;

    return name != null && name.isNotEmpty && phone != null && phone.isNotEmpty;
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void resetStatus() {
    emit(state.copyWith(status: ProfileStatus.loaded));
  }
}
