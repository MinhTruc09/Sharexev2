/// ChangePassDTO - Đồng bộ với Swagger API
class ChangePassDTO {
  final String oldPass;
  final String newPass;

  ChangePassDTO({
    required this.oldPass,
    required this.newPass,
  });

  factory ChangePassDTO.fromJson(Map<String, dynamic> json) {
    return ChangePassDTO(
      oldPass: json['oldPass'] ?? '',
      newPass: json['newPass'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oldPass': oldPass,
      'newPass': newPass,
    };
  }

  /// Validation
  List<String> validate() {
    final errors = <String>[];
    
    if (oldPass.trim().isEmpty) {
      errors.add('Mật khẩu cũ không được để trống');
    }
    
    if (newPass.trim().isEmpty) {
      errors.add('Mật khẩu mới không được để trống');
    }
    
    if (newPass.length < 6) {
      errors.add('Mật khẩu mới phải có ít nhất 6 ký tự');
    }
    
    if (oldPass == newPass) {
      errors.add('Mật khẩu mới phải khác mật khẩu cũ');
    }
    
    return errors;
  }
}
