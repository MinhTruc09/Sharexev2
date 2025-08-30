import 'package:sharexev2/core/auth/auth_manager.dart';

class ChatMessage {
  final String messageId;
  final String senderEmail;
  final String receiverEmail;
  final String senderName;
  final String content;
  final String roomId;
  final DateTime timestamp;
  final bool read;

  ChatMessage({
    required this.messageId,
    required this.senderEmail,
    required this.receiverEmail,
    required this.senderName,
    required this.content,
    required this.roomId,
    required this.timestamp,
    required this.read,
  });

  /// Helper: kiểm tra tin này có phải từ mình gửi không
  bool get isFromMe {
    final currentEmail = getCurrentUserEmail();
    return currentEmail.isNotEmpty &&
        senderEmail.toLowerCase() == currentEmail.toLowerCase();
  }

  /// Small helpers để lấy thông tin user hiện tại
  static String getCurrentUserEmail() {
    return AuthManager().currentUser?.email.toString() ?? '';
  }

  static String getCurrentUserName() {
    return AuthManager().currentUser?.fullName ?? '';
  }
}
