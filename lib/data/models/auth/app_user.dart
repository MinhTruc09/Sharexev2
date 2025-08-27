enum UserRole { passenger, driver, admin, unknown }

class AppUser {
  final int? id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;

  AppUser({
    this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
  });

  // ===== JSON =====
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json["id"],
      email: json["email"] ?? "",
      fullName: json["fullName"] ?? "",
      phoneNumber: json["phoneNumber"],
      avatarUrl: json["avatarUrl"],
      role: UserRole.values.firstWhere(
        (r) => r.toString() == "UserRole.${json["role"]}",
        orElse: () => UserRole.unknown,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "avatarUrl": avatarUrl,
      "role": role.toString().split(".").last,
    };
  }
}
