// Domain Value Object: AuthCredentials
// Chứa thông tin đăng nhập và validation

/// Value Object: AuthCredentials
/// Chứa thông tin đăng nhập với validation
class AuthCredentials {
  final String email;
  final String password;

  const AuthCredentials({
    required this.email,
    required this.password,
  });

  // ===== Validation =====

  /// Kiểm tra email có hợp lệ không
  bool get hasValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Kiểm tra password có đủ mạnh không
  bool get hasValidPassword {
    return password.length >= 6; // Minimum 6 characters
  }

  /// Kiểm tra password có đủ mạnh không (strict)
  bool get hasStrongPassword {
    if (password.length < 8) return false;
    
    // Phải có ít nhất 1 chữ hoa, 1 chữ thường, 1 số
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasDigits;
  }

  /// Validate toàn bộ credentials
  List<String> validate({bool requireStrongPassword = false}) {
    final errors = <String>[];

    if (email.trim().isEmpty) {
      errors.add('Email không được để trống');
    } else if (!hasValidEmail) {
      errors.add('Email không hợp lệ');
    }

    if (password.isEmpty) {
      errors.add('Mật khẩu không được để trống');
    } else if (requireStrongPassword && !hasStrongPassword) {
      errors.add('Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường và số');
    } else if (!hasValidPassword) {
      errors.add('Mật khẩu phải có ít nhất 6 ký tự');
    }

    return errors;
  }

  /// Kiểm tra credentials có hợp lệ không
  bool get isValid => validate().isEmpty;

  /// Kiểm tra credentials có đủ mạnh không
  bool get isStrong => validate(requireStrongPassword: true).isEmpty;

  // ===== Utility Methods =====

  /// Tạo credentials với email đã normalize
  AuthCredentials normalize() {
    return AuthCredentials(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // ===== Equality & Hash =====

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthCredentials &&
           other.email.toLowerCase() == email.toLowerCase();
  }

  @override
  int get hashCode => email.toLowerCase().hashCode;

  @override
  String toString() {
    return 'AuthCredentials(email: $email, passwordLength: ${password.length})';
  }
}

/// Value Object: RegisterCredentials
/// Chứa thông tin đăng ký với validation mở rộng
class RegisterCredentials extends AuthCredentials {
  final String fullName;
  final String? phoneNumber;
  final String? licenseNumber; // For drivers

  const RegisterCredentials({
    required super.email,
    required super.password,
    required this.fullName,
    this.phoneNumber,
    this.licenseNumber,
  });

  // ===== Additional Validation =====

  /// Kiểm tra tên có hợp lệ không
  bool get hasValidFullName {
    return fullName.trim().length >= 2 && fullName.trim().length <= 50;
  }

  /// Kiểm tra số điện thoại có hợp lệ không (VN format)
  bool get hasValidPhoneNumber {
    if (phoneNumber == null) return true; // Optional field
    final phoneRegex = RegExp(r'^(\+84|0)[3|5|7|8|9][0-9]{8}$');
    return phoneRegex.hasMatch(phoneNumber!);
  }

  /// Kiểm tra license number có hợp lệ không (for drivers)
  bool get hasValidLicenseNumber {
    if (licenseNumber == null) return true; // Optional for passengers
    return licenseNumber!.trim().length >= 8;
  }

  @override
  List<String> validate({bool requireStrongPassword = true}) {
    final errors = super.validate(requireStrongPassword: requireStrongPassword);

    if (fullName.trim().isEmpty) {
      errors.add('Họ tên không được để trống');
    } else if (!hasValidFullName) {
      errors.add('Họ tên phải từ 2-50 ký tự');
    }

    if (!hasValidPhoneNumber) {
      errors.add('Số điện thoại không hợp lệ');
    }

    if (!hasValidLicenseNumber) {
      errors.add('Số giấy phép lái xe phải có ít nhất 8 ký tự');
    }

    return errors;
  }

  /// Tạo credentials với data đã normalize
  @override
  RegisterCredentials normalize() {
    return RegisterCredentials(
      email: email.trim().toLowerCase(),
      password: password,
      fullName: fullName.trim(),
      phoneNumber: phoneNumber?.trim(),
      licenseNumber: licenseNumber?.trim(),
    );
  }

  @override
  String toString() {
    return 'RegisterCredentials(email: $email, fullName: $fullName, hasLicense: ${licenseNumber != null})';
  }
}
