// lib/data/models/auth/value_objects/phone_number.dart
// Value Object - Phone Number với validation cho VN

import 'package:equatable/equatable.dart';

/// Value Object cho Phone Number với validation cho số điện thoại Việt Nam
class PhoneNumber extends Equatable {
  final String value;

  const PhoneNumber._(this.value);

  /// Factory constructor với validation
  factory PhoneNumber(String phone) {
    final cleaned = _cleanPhoneNumber(phone);
    
    if (cleaned.isEmpty) {
      throw PhoneValidationException('Số điện thoại không được để trống');
    }
    
    if (!_isValidVietnamesePhone(cleaned)) {
      throw PhoneValidationException('Số điện thoại không hợp lệ');
    }
    
    return PhoneNumber._(cleaned);
  }

  /// Factory constructor không validation (dùng cho trusted sources)
  factory PhoneNumber.trusted(String phone) {
    return PhoneNumber._(_cleanPhoneNumber(phone));
  }

  /// Clean phone number - remove spaces, dashes, etc.
  static String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '').trim();
  }

  /// Validation cho số điện thoại Việt Nam
  static bool _isValidVietnamesePhone(String phone) {
    // Patterns cho số điện thoại VN:
    // - Bắt đầu bằng +84 hoặc 0
    // - Theo sau là 3,5,7,8,9 (di động) hoặc 2 (cố định)
    // - Tổng cộng 10-11 số (không tính +84)
    
    final patterns = [
      // Di động: 03x, 05x, 07x, 08x, 09x
      RegExp(r'^(\+84|0)[3|5|7|8|9][0-9]{8}$'),
      // Cố định: 02x
      RegExp(r'^(\+84|0)2[0-9]{8,9}$'),
    ];
    
    return patterns.any((pattern) => pattern.hasMatch(phone));
  }

  /// Static validation method
  static bool isValid(String phone) {
    final cleaned = _cleanPhoneNumber(phone);
    return _isValidVietnamesePhone(cleaned);
  }

  /// Format để hiển thị (xxx-xxx-xxxx)
  String get formatted {
    if (value.startsWith('+84')) {
      final number = value.substring(3);
      if (number.length >= 9) {
        return '+84 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}';
      }
    } else if (value.startsWith('0')) {
      if (value.length >= 10) {
        return '${value.substring(0, 4)} ${value.substring(4, 7)} ${value.substring(7)}';
      }
    }
    return value;
  }

  /// Convert sang international format (+84)
  String get international {
    if (value.startsWith('+84')) {
      return value;
    } else if (value.startsWith('0')) {
      return '+84${value.substring(1)}';
    }
    return value;
  }

  /// Convert sang local format (0x)
  String get local {
    if (value.startsWith('+84')) {
      return '0${value.substring(3)}';
    }
    return value;
  }

  /// Kiểm tra có phải số di động không
  bool get isMobile {
    final localNumber = local;
    return localNumber.length >= 2 && 
           ['03', '05', '07', '08', '09'].contains(localNumber.substring(0, 2));
  }

  /// Kiểm tra có phải số cố định không
  bool get isLandline {
    final localNumber = local;
    return localNumber.length >= 2 && localNumber.startsWith('02');
  }

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}

/// Exception cho Phone validation
class PhoneValidationException implements Exception {
  final String message;
  
  const PhoneValidationException(this.message);
  
  @override
  String toString() => 'PhoneValidationException: $message';
}
