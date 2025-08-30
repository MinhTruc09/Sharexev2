// lib/data/models/auth/value_objects/email.dart
// Value Object - Email với validation

import 'package:equatable/equatable.dart';

/// Value Object cho Email với built-in validation
class Email extends Equatable {
  final String value;

  const Email._(this.value);

  /// Factory constructor với validation
  factory Email(String email) {
    final trimmed = email.trim().toLowerCase();
    
    if (trimmed.isEmpty) {
      throw EmailValidationException('Email không được để trống');
    }
    
    if (!_isValidEmail(trimmed)) {
      throw EmailValidationException('Email không hợp lệ');
    }
    
    return Email._(trimmed);
  }

  /// Factory constructor không validation (dùng cho trusted sources)
  factory Email.trusted(String email) {
    return Email._(email.trim().toLowerCase());
  }

  /// Validation logic
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    return emailRegex.hasMatch(email);
  }

  /// Static validation method
  static bool isValid(String email) {
    return _isValidEmail(email.trim().toLowerCase());
  }

  /// Domain của email (phần sau @)
  String get domain {
    final parts = value.split('@');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Local part của email (phần trước @)
  String get localPart {
    final parts = value.split('@');
    return parts.isNotEmpty ? parts[0] : '';
  }

  /// Kiểm tra có phải email doanh nghiệp không
  bool get isBusinessEmail {
    final commonPersonalDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com',
    ];
    return !commonPersonalDomains.contains(domain.toLowerCase());
  }

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}

/// Exception cho Email validation
class EmailValidationException implements Exception {
  final String message;
  
  const EmailValidationException(this.message);
  
  @override
  String toString() => 'EmailValidationException: $message';
}
