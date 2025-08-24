import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sharexev2/data/models/auth_models.dart';
import 'package:sharexev2/data/services/api_service.dart';

class AuthService {
  static const String _roleKey = 'role';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _expiresAtKey = 'expires_at';

  firebase_auth.FirebaseAuth? _firebaseAuth;
  GoogleSignIn? _googleSignIn;
  final ApiService _apiService = ApiService();

  // Lazy initialization cho Firebase Auth
  firebase_auth.FirebaseAuth? get _firebaseAuthInstance {
    try {
      _firebaseAuth ??= firebase_auth.FirebaseAuth.instance;
      return _firebaseAuth;
    } catch (e) {
      print('Firebase Auth not available: $e');
      return null;
    }
  }

  // Lazy initialization cho Google Sign-In
  GoogleSignIn? get _googleSignInInstance {
    try {
      _googleSignIn ??= GoogleSignIn();
      return _googleSignIn;
    } catch (e) {
      print('Google Sign-In not available: $e');
      return null;
    }
  }

  // Kiểm tra Firebase có sẵn sàng không
  bool get _isFirebaseAvailable {
    return _firebaseAuthInstance != null;
  }

  // Kiểm tra đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final expiresAt = prefs.getString(_expiresAtKey);
    
    if (accessToken == null || expiresAt == null) return false;
    
    // Kiểm tra token có hết hạn chưa
    final expiryDate = DateTime.parse(expiresAt);
    if (DateTime.now().isAfter(expiryDate)) {
      // Token hết hạn, thử refresh
      try {
        await refreshToken();
        return true;
      } catch (e) {
        await logout();
        return false;
      }
    }
    
    return true;
  }

  // Lấy role hiện tại
  Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Lưu role
  Future<void> setCurrentUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  // Lấy access token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Đăng nhập bằng email/password
  Future<AuthResponse> loginWithEmail(
    String email, 
    String password, 
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String? firebaseToken;
      
      // Thử đăng nhập Firebase nếu có
      if (_isFirebaseAvailable) {
        try {
          final userCredential = await _firebaseAuthInstance!.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          firebaseToken = await userCredential.user?.getIdToken();
        } catch (e) {
          print('Firebase login failed, continuing without Firebase: $e');
        }
      }

      // Gọi API để lấy access token và refresh token
      final loginRequest = LoginRequest(
        email: email,
        password: password,
        firebaseToken: firebaseToken,
      );
      
      final authResponse = await _apiService.login(loginRequest, role, additionalData: additionalData);
      
      // Lưu thông tin vào local storage
      await _saveAuthData(authResponse);
      
      return authResponse;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  // Đăng nhập bằng Google
  Future<AuthResponse> loginWithGoogle(String role) async {
    try {
      String? firebaseToken;
      
      // Thử đăng nhập Google nếu có
      if (_googleSignInInstance != null && _isFirebaseAvailable) {
        try {
          final GoogleSignInAccount? googleUser = await _googleSignInInstance!.signIn();
          if (googleUser == null) throw Exception('Đăng nhập Google bị hủy');
          
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          
          final credential = firebase_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          
          final userCredential = await _firebaseAuthInstance!.signInWithCredential(credential);
          firebaseToken = await userCredential.user?.getIdToken();
        } catch (e) {
          print('Google Sign-In failed, continuing without Google: $e');
          throw Exception('Đăng nhập Google thất bại: $e');
        }
      } else {
        throw Exception('Google Sign-In không khả dụng');
      }

      // Gọi API để lấy access token và refresh token
      final loginRequest = LoginRequest(
        email: '', // Sẽ được lấy từ Google
        password: '',
        firebaseToken: firebaseToken,
      );
      
      final authResponse = await _apiService.loginWithGoogle(loginRequest, role);
      
      // Lưu thông tin vào local storage
      await _saveAuthData(authResponse);
      
      return authResponse;
    } catch (e) {
      throw Exception('Đăng nhập Google thất bại: $e');
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) throw Exception('Không có refresh token');
      
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final authResponse = await _apiService.refreshToken(request);
      
      await _saveAuthData(authResponse);
    } catch (e) {
      throw Exception('Refresh token thất bại: $e');
    }
  }

  // Đăng ký
  Future<AuthResponse> register(
    String email, 
    String password, 
    String name, 
    String role, {
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      String? firebaseToken;
      
      // Thử tạo tài khoản Firebase nếu có
      if (_isFirebaseAvailable) {
        try {
          final userCredential = await _firebaseAuthInstance!.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          await userCredential.user?.updateDisplayName(name);
          firebaseToken = await userCredential.user?.getIdToken();
        } catch (e) {
          print('Firebase registration failed, continuing without Firebase: $e');
        }
      }

      // Gọi API để đăng ký và lấy tokens
      final authResponse = await _apiService.register(
        email, 
        password, 
        name, 
        role, 
        firebaseToken,
        additionalData: additionalData,
      );
      
      // Lưu thông tin vào local storage
      await _saveAuthData(authResponse);
      
      return authResponse;
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      // Đăng xuất Firebase (nếu có)
      if (_isFirebaseAvailable) {
        try {
          await _firebaseAuthInstance!.signOut();
        } catch (e) {
          print('Firebase logout failed: $e');
        }
      }
      
      // Đăng xuất Google (nếu có)
      if (_googleSignInInstance != null) {
        try {
          await _googleSignInInstance!.signOut();
        } catch (e) {
          print('Google logout failed: $e');
        }
      }
      
      // Xóa dữ liệu local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_expiresAtKey);
      // Giữ lại role để biết user đã chọn role nào
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }

  // Lưu auth data vào local storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await prefs.setString(_userKey, authResponse.user.toJson().toString());
    await prefs.setString(_expiresAtKey, authResponse.expiresAt.toIso8601String());
    await prefs.setString(_roleKey, authResponse.user.role);
  }

  // Lấy thông tin user hiện tại
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;
      
      // Parse JSON string thành Map
      final userMap = Map<String, dynamic>.from(
        userJson as Map<String, dynamic>
      );
      return User.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }
}
