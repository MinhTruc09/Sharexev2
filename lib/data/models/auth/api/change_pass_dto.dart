class ChangePassDTO {
  final String oldPass;
  final String newPass;

  ChangePassDTO({required this.oldPass, required this.newPass});

  Map<String, dynamic> toJson() {
    return {"oldPass": oldPass, "newPass": newPass};
  }
}
