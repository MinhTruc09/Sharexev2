import 'package:shared_preferences/shared_preferences.dart';

/// Local role repository for managing user role selection
class LocalRoleRepository {
  static const String _keyRole = 'user_role';

  /// Save selected role to local storage
  Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, role);
  }

  /// Get saved role from local storage
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  /// Clear saved role
  Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRole);
  }

  /// Check if role is saved
  Future<bool> hasRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyRole);
  }
}
