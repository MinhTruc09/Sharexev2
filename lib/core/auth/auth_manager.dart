// lib/core/auth/auth_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharexev2/data/models/auth/app_user.dart';

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();
  factory AuthManager() => _instance;
  AuthManager._internal();

  static const _kAccessToken = "accessToken";
  static const _kRefreshToken = "refreshToken";
  static const _kUser = "user";

  String? _accessToken;
  String? _refreshToken;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  String? get refreshToken => _refreshToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_kAccessToken);
    _refreshToken = prefs.getString(_kRefreshToken);

    final userJson = prefs.getString(_kUser);
    if (userJson != null) {
      _currentUser = AppUser.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required AppUser user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, accessToken);
    await prefs.setString(_kRefreshToken, refreshToken);
    await prefs.setString(_kUser, jsonEncode(user.toJson()));

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUser = user;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
    await prefs.remove(_kUser);

    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
  }

  String? getToken() => _accessToken;
  String? getRefreshToken() => _refreshToken;
}
