import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  void initializeProfile(String role) {
    emit(state.copyWith(
      role: role,
      status: ProfileStatus.loaded,
    ));
    _loadUserData();
  }

  void _loadUserData() {
    // Mock user data - in real app, load from service
    emit(state.copyWith(
      userData: {
        'name': 'Nguyễn Văn A',
        'email': 'nguyenvana@example.com',
        'phone': '0901234567',
        'avatar': null,
      },
    ));
  }

  void updateName(String name) {
    final updatedData = Map<String, dynamic>.from(state.userData);
    updatedData['name'] = name;
    
    emit(state.copyWith(
      userData: updatedData,
      error: null,
    ));
  }

  void updatePhone(String phone) {
    final updatedData = Map<String, dynamic>.from(state.userData);
    updatedData['phone'] = phone;
    
    emit(state.copyWith(
      userData: updatedData,
      error: null,
    ));
  }

  void updateAvatar(List<int>? imageBytes) {
    final updatedData = Map<String, dynamic>.from(state.userData);
    updatedData['avatar'] = imageBytes;
    
    emit(state.copyWith(
      userData: updatedData,
      error: null,
    ));
  }

  void toggleEditMode() {
    emit(state.copyWith(
      isEditing: !state.isEditing,
      error: null,
    ));
    
    if (!state.isEditing) {
      // Reset to original values if canceling
      _loadUserData();
    }
  }

  Future<void> saveProfile() async {
    if (!_validateProfile()) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: 'Vui lòng điền đầy đủ thông tin',
      ));
      return;
    }

    emit(state.copyWith(
      status: ProfileStatus.saving,
      error: null,
    ));

    try {
      // Simulate saving to API
      await Future.delayed(const Duration(seconds: 1));
      
      emit(state.copyWith(
        status: ProfileStatus.saved,
        isEditing: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        error: 'Lỗi lưu thông tin: $e',
      ));
    }
  }

  bool _validateProfile() {
    final name = state.userData['name'] as String?;
    final phone = state.userData['phone'] as String?;
    
    return name != null && name.isNotEmpty && 
           phone != null && phone.isNotEmpty;
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  void resetStatus() {
    emit(state.copyWith(status: ProfileStatus.loaded));
  }
}
