/// Registration step enum
enum RegistrationStep {
  personalInfo,
  vehicleInfo,
  documents,
  verification,
  completed,

  // Legacy support
  stepOne,
  stepTwo,
}

/// Driver approval status
enum DriverApprovalStatus {
  pending,
  approved,
  rejected,
  underReview,
}

/// Registration data model
class RegistrationData {
  // Personal Information
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final String? confirmPassword;
  final String role;

  // Vehicle Information (for drivers)
  final String? licensePlate;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String? vehicleColor;
  final int? numberOfSeats;

  // Documents (for drivers)
  final String? driverLicenseImageUrl;
  final String? vehicleRegistrationImageUrl;
  final String? vehicleImageUrl;
  final String? avatarImageUrl;

  // Image files (for UI)
  final dynamic profileImage;
  final dynamic vehicleImage;
  final dynamic licenseImage;
  final dynamic licensePlateImage;

  // Verification
  final DriverApprovalStatus? approvalStatus;
  final String? rejectionReason;

  const RegistrationData({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.password,
    this.confirmPassword,
    required this.role,
    this.licensePlate,
    this.vehicleBrand,
    this.vehicleModel,
    this.vehicleColor,
    this.numberOfSeats,
    this.driverLicenseImageUrl,
    this.vehicleRegistrationImageUrl,
    this.vehicleImageUrl,
    this.avatarImageUrl,
    this.approvalStatus,
    this.rejectionReason,
    this.profileImage,
    this.vehicleImage,
    this.licenseImage,
    this.licensePlateImage,
  });

  RegistrationData copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    String? confirmPassword,
    String? role,
    String? licensePlate,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleColor,
    int? numberOfSeats,
    String? driverLicenseImageUrl,
    String? vehicleRegistrationImageUrl,
    String? vehicleImageUrl,
    String? avatarImageUrl,
    DriverApprovalStatus? approvalStatus,
    String? rejectionReason,
    dynamic profileImage,
    dynamic vehicleImage,
    dynamic licenseImage,
    dynamic licensePlateImage,
  }) {
    return RegistrationData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      role: role ?? this.role,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      numberOfSeats: numberOfSeats ?? this.numberOfSeats,
      driverLicenseImageUrl: driverLicenseImageUrl ?? this.driverLicenseImageUrl,
      vehicleRegistrationImageUrl: vehicleRegistrationImageUrl ?? this.vehicleRegistrationImageUrl,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      avatarImageUrl: avatarImageUrl ?? this.avatarImageUrl,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      profileImage: profileImage ?? this.profileImage,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      licenseImage: licenseImage ?? this.licenseImage,
      licensePlateImage: licensePlateImage ?? this.licensePlateImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'role': role,
      'licensePlate': licensePlate,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'numberOfSeats': numberOfSeats,
      'driverLicenseImageUrl': driverLicenseImageUrl,
      'vehicleRegistrationImageUrl': vehicleRegistrationImageUrl,
      'vehicleImageUrl': vehicleImageUrl,
      'avatarImageUrl': avatarImageUrl,
      'approvalStatus': approvalStatus?.name,
      'rejectionReason': rejectionReason,
    };
  }

  // Validation helpers
  bool get isPersonalInfoValid {
    return fullName != null &&
           fullName!.isNotEmpty &&
           email != null &&
           email!.isNotEmpty &&
           phoneNumber != null &&
           phoneNumber!.isNotEmpty &&
           password != null &&
           password!.isNotEmpty &&
           password == confirmPassword;
  }

  // Legacy support
  bool get isStepOneValid => isPersonalInfoValid;

  bool get isVehicleInfoValid {
    if (role != 'DRIVER') return true;
    
    return licensePlate != null && 
           licensePlate!.isNotEmpty &&
           vehicleBrand != null && 
           vehicleBrand!.isNotEmpty &&
           vehicleModel != null && 
           vehicleModel!.isNotEmpty &&
           vehicleColor != null && 
           vehicleColor!.isNotEmpty &&
           numberOfSeats != null && 
           numberOfSeats! > 0;
  }

  bool get isDocumentsValid {
    if (role != 'DRIVER') return true;
    
    return driverLicenseImageUrl != null && 
           driverLicenseImageUrl!.isNotEmpty &&
           vehicleRegistrationImageUrl != null && 
           vehicleRegistrationImageUrl!.isNotEmpty &&
           vehicleImageUrl != null && 
           vehicleImageUrl!.isNotEmpty;
  }

  bool get isReadyForSubmission {
    return isPersonalInfoValid && isVehicleInfoValid && isDocumentsValid;
  }

  // Legacy method support
  bool isStepTwoValidForRole(String role) {
    if (role == 'DRIVER') {
      return isVehicleInfoValid && isDocumentsValid;
    }
    return true; // Passengers don't need step two validation
  }
}
