import 'package:shared_preferences/shared_preferences.dart';

abstract class IRoleRepository {
  Future<void> setRole(String role);
  Future<String?> getRole();
}

class LocalRoleRepository implements IRoleRepository {
  static const String _key = 'role';

  @override
  Future<void> setRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, role);
  }

  @override
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }
}


