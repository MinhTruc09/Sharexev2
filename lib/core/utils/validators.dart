// Validation utilities
class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation (minimum 8 characters, at least one letter and one number)
  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[a-zA-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  // Phone number validation (Vietnamese format)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }

  // Name validation (at least 2 characters, only letters and spaces)
  static bool isValidName(String name) {
    return name.length >= 2 && RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(name);
  }

  // Get email error message
  static String? getEmailError(String? email) {
    if (email == null || email.isEmpty) return 'Email không được để trống';
    if (!isValidEmail(email)) return 'Email không hợp lệ';
    return null;
  }

  // Get password error message
  static String? getPasswordError(String? password) {
    if (password == null || password.isEmpty)
      return 'Mật khẩu không được để trống';
    if (password.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất 1 chữ cái';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }
    return null;
  }

  // Get name error message
  static String? getNameError(String name) {
    if (name.isEmpty) return 'Tên không được để trống';
    if (name.length < 2) return 'Tên phải có ít nhất 2 ký tự';
    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(name)) {
      return 'Tên chỉ được chứa chữ cái và khoảng trắng';
    }
    return null;
  }
}
