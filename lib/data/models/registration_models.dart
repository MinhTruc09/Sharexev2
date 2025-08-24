import 'dart:io';

enum RegistrationStep { stepOne, stepTwo }

enum DriverApprovalStatus { pending, approved, rejected }

class RegistrationData {
  // Step 1 data
  final String? email;
  final String? fullName;
  final String? password;
  final String? confirmPassword;
  
  // Step 2 data
  final String? phoneNumber;
  final File? profileImage;
  
  // Driver specific data
  final File? vehicleImage;
  final File? licenseImage;
  final File? licensePlateImage;
  final DriverApprovalStatus? approvalStatus;

  const RegistrationData({
    this.email,
    this.fullName,
    this.password,
    this.confirmPassword,
    this.phoneNumber,
    this.profileImage,
    this.vehicleImage,
    this.licenseImage,
    this.licensePlateImage,
    this.approvalStatus,
  });

  RegistrationData copyWith({
    String? email,
    String? fullName,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
    File? profileImage,
    File? vehicleImage,
    File? licenseImage,
    File? licensePlateImage,
    DriverApprovalStatus? approvalStatus,
  }) {
    return RegistrationData(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      vehicleImage: vehicleImage ?? this.vehicleImage,
      licenseImage: licenseImage ?? this.licenseImage,
      licensePlateImage: licensePlateImage ?? this.licensePlateImage,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }

  bool get isStepOneValid {
    return email != null &&
        email!.isNotEmpty &&
        fullName != null &&
        fullName!.isNotEmpty &&
        password != null &&
        password!.isNotEmpty &&
        confirmPassword != null &&
        confirmPassword!.isNotEmpty &&
        password == confirmPassword;
  }

  bool isStepTwoValidForRole(String role) {
    if (role == 'PASSENGER') {
      return phoneNumber != null && phoneNumber!.isNotEmpty;
    } else {
      return phoneNumber != null &&
          phoneNumber!.isNotEmpty &&
          vehicleImage != null &&
          licenseImage != null &&
          licensePlateImage != null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImage?.path,
      'vehicleImagePath': vehicleImage?.path,
      'licenseImagePath': licenseImage?.path,
      'licensePlateImagePath': licensePlateImage?.path,
      'approvalStatus': approvalStatus?.name,
    };
  }
}

class ImageUploadData {
  final String label;
  final String hint;
  final File? file;
  final bool isRequired;

  const ImageUploadData({
    required this.label,
    required this.hint,
    this.file,
    this.isRequired = true,
  });

  ImageUploadData copyWith({
    String? label,
    String? hint,
    File? file,
    bool? isRequired,
  }) {
    return ImageUploadData(
      label: label ?? this.label,
      hint: hint ?? this.hint,
      file: file ?? this.file,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}

extension DriverApprovalStatusExtension on DriverApprovalStatus {
  String get displayName {
    switch (this) {
      case DriverApprovalStatus.pending:
        return 'Đang chờ xét duyệt';
      case DriverApprovalStatus.approved:
        return 'Đã được duyệt';
      case DriverApprovalStatus.rejected:
        return 'Bị từ chối';
    }
  }

  String get description {
    switch (this) {
      case DriverApprovalStatus.pending:
        return 'Tài khoản của bạn đang được admin xem xét. Vui lòng chờ thông báo.';
      case DriverApprovalStatus.approved:
        return 'Tài khoản đã được phê duyệt. Bạn có thể bắt đầu nhận chuyến.';
      case DriverApprovalStatus.rejected:
        return 'Tài khoản bị từ chối. Vui lòng liên hệ admin để biết thêm chi tiết.';
    }
  }
}
