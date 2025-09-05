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
  final String userName;
  final String avatarUrl;
  final int tripCount;
  final double rating;
  final bool isVerified;

  const ProfileState({
    this.role = 'PASSENGER',
    this.status = ProfileStatus.initial,
    this.userData = const {},
    this.isEditing = false,
    this.error,
    this.userName = '',
    this.avatarUrl = '',
    this.tripCount = 0,
    this.rating = 5.0,
    this.isVerified = true,
  });

  ProfileState copyWith({
    String? role,
    ProfileStatus? status,
    Map<String, dynamic>? userData,
    bool? isEditing,
    String? error,
    String? userName,
    String? avatarUrl,
    int? tripCount,
    double? rating,
    bool? isVerified,
  }) {
    return ProfileState(
      role: role ?? this.role,
      status: status ?? this.status,
      userData: userData ?? this.userData,
      isEditing: isEditing ?? this.isEditing,
      error: error ?? this.error,
      userName: userName ?? this.userName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tripCount: tripCount ?? this.tripCount,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  bool get isLoaded => status == ProfileStatus.loaded;
  bool get isLoading => status == ProfileStatus.loading;
  bool get isSaving => status == ProfileStatus.saving;
  bool get isSaved => status == ProfileStatus.saved;
  bool get hasError => status == ProfileStatus.error;
  
  String get userNameFromData => userData['name'] ?? '';
  String get userEmail => userData['email'] ?? '';
  String get userPhone => userData['phone'] ?? '';
  List<int>? get userAvatar => userData['avatar'] as List<int>?;
}
