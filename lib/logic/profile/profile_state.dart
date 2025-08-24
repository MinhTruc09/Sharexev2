part of 'profile_cubit.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  error,
}

class ProfileState {
  final String role;
  final ProfileStatus status;
  final Map<String, dynamic> userData;
  final bool isEditing;
  final String? error;

  const ProfileState({
    this.role = 'PASSENGER',
    this.status = ProfileStatus.initial,
    this.userData = const {},
    this.isEditing = false,
    this.error,
  });

  ProfileState copyWith({
    String? role,
    ProfileStatus? status,
    Map<String, dynamic>? userData,
    bool? isEditing,
    String? error,
  }) {
    return ProfileState(
      role: role ?? this.role,
      status: status ?? this.status,
      userData: userData ?? this.userData,
      isEditing: isEditing ?? this.isEditing,
      error: error ?? this.error,
    );
  }

  bool get isLoaded => status == ProfileStatus.loaded;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isSaving => status == ProfileStatus.saving;
  bool get isSaved => status == ProfileStatus.saved;
  bool get hasError => status == ProfileStatus.error;
  
  String get userName => userData['name'] ?? '';
  String get userEmail => userData['email'] ?? '';
  String get userPhone => userData['phone'] ?? '';
  List<int>? get userAvatar => userData['avatar'] as List<int>?;
}
