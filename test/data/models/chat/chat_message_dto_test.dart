import 'package:flutter_test/flutter_test.dart';
import 'package:sharexev2/data/models/chat/dtos/chat_message_dto.dart';

void main() {
  group('ChatMessageDto Tests', () {
    test('should create ChatMessageDto correctly', () {
      final dto = ChatMessageDto(
        token: 'test_token',
        senderEmail: 'sender@test.com',
        receiverEmail: 'receiver@test.com',
        senderName: 'Test Sender',
        content: 'Hello World',
        roomId: 'room123',
        timestamp: DateTime(2024, 1, 1, 12, 0),
        read: false,
      );

      expect(dto.token, equals('test_token'));
      expect(dto.senderEmail, equals('sender@test.com'));
      expect(dto.receiverEmail, equals('receiver@test.com'));
      expect(dto.senderName, equals('Test Sender'));
      expect(dto.content, equals('Hello World'));
      expect(dto.roomId, equals('room123'));
      expect(dto.read, isFalse);
    });

    test('should serialize to JSON correctly', () {
      final dto = ChatMessageDto(
        token: 'test_token',
        senderEmail: 'sender@test.com',
        receiverEmail: 'receiver@test.com',
        senderName: 'Test Sender',
        content: 'Hello World',
        roomId: 'room123',
        timestamp: DateTime(2024, 1, 1, 12, 0),
        read: false,
      );

      final json = dto.toJson();

      expect(json['token'], equals('test_token'));
      expect(json['senderEmail'], equals('sender@test.com'));
      expect(json['content'], equals('Hello World'));
      expect(json['read'], isFalse);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'token': 'test_token',
        'senderEmail': 'sender@test.com',
        'receiverEmail': 'receiver@test.com',
        'senderName': 'Test Sender',
        'content': 'Hello World',
        'roomId': 'room123',
        'timestamp': '2024-01-01T12:00:00.000Z',
        'read': false,
      };

      final dto = ChatMessageDto.fromJson(json);

      expect(dto.token, equals('test_token'));
      expect(dto.senderEmail, equals('sender@test.com'));
      expect(dto.content, equals('Hello World'));
      expect(dto.read, isFalse);
    });

    test('should handle missing fields in JSON', () {
      final json = {
        'senderEmail': 'sender@test.com',
        'content': 'Hello World',
      };

      final dto = ChatMessageDto.fromJson(json);

      expect(dto.token, equals(''));
      expect(dto.senderEmail, equals('sender@test.com'));
      expect(dto.content, equals('Hello World'));
      expect(dto.read, isFalse);
    });
  });
}
