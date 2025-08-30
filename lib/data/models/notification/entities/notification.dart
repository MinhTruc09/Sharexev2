class Notification {
  final int id;
  final String userEmail;
  final String title;
  final String content;
  final String type;
  final int referenceId;
  final DateTime createdAt;
  final bool read;

  Notification({
    required this.id,
    required this.userEmail,
    required this.title,
    required this.content,
    required this.type,
    required this.referenceId,
    required this.createdAt,
    required this.read,
  });
}
