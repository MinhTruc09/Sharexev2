import 'package:flutter_test/flutter_test.dart';
import 'package:sharexev2/data/models/auth/dtos/login_request_dto.dart';
import 'package:sharexev2/data/models/auth/dtos/register_passenger_request_dto.dart';
import 'package:sharexev2/data/models/auth/dtos/google_login_request_dto.dart';

void main() {
  group('DTO Creation Tests', () {
    test('LoginRequestDto should create correctly', () {
      final loginRequest = LoginRequestDto(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(loginRequest.email, equals('test@example.com'));
      expect(loginRequest.password, equals('password123'));
    });

    test('RegisterPassengerRequestDto should create correctly', () {
      final registerRequest = RegisterPassengerRequestDto(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        phoneNumber: '0123456789',
      );

      expect(registerRequest.email, equals('test@example.com'));
      expect(registerRequest.fullName, equals('Test User'));
      expect(registerRequest.phoneNumber, equals('0123456789'));
    });

    test('GoogleLoginRequestDto should create correctly', () {
      final googleRequest = GoogleLoginRequestDto(
        idToken: 'valid_token_123',
        role: 'passenger',
      );

      expect(googleRequest.idToken, equals('valid_token_123'));
      expect(googleRequest.role, equals('passenger'));
    });
  });

  group('DTO Serialization Tests', () {
    test('LoginRequestDto toJson/fromJson should work correctly', () {
      final original = LoginRequestDto(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = original.toJson();
      final restored = LoginRequestDto.fromJson(json);

      expect(restored.email, equals(original.email));
      expect(restored.password, equals(original.password));
    });

    test('RegisterPassengerRequestDto toJson/fromJson should work correctly', () {
      final original = RegisterPassengerRequestDto(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        phoneNumber: '0123456789',
      );

      final json = original.toJson();
      final restored = RegisterPassengerRequestDto.fromJson(json);

      expect(restored.email, equals(original.email));
      expect(restored.fullName, equals(original.fullName));
      expect(restored.phoneNumber, equals(original.phoneNumber));
    });
  });
}

