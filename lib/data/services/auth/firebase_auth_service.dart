// lib/data/services/auth/firebase_auth_service.dart
// Service - Firebase Authentication Operations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/auth/entities/user_role.dart';

/// Service để handle Firebase Authentication operations
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ===== Current User =====

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // ===== Email/Password Authentication =====

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthServiceException('Sign in failed: No user returned');
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Sign in failed');
    } catch (e) {
      throw FirebaseAuthServiceException('Unexpected error during sign in: $e');
    }
  }

  /// Create user with email and password
  Future<User> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw FirebaseAuthServiceException(
          'Registration failed: No user returned',
        );
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      return _firebaseAuth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Registration failed');
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Unexpected error during registration: $e',
      );
    }
  }

  // ===== Google Sign In =====

  /// Sign in with Google
  Future<User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthServiceException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw FirebaseAuthServiceException(
          'Google sign in failed: No user returned',
        );
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Google sign in failed');
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Unexpected error during Google sign in: $e',
      );
    }
  }

  /// Get Google ID token for backend authentication
  Future<String?> getGoogleIdToken() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      return googleAuth.idToken;
    } catch (e) {
      throw FirebaseAuthServiceException('Failed to get Google ID token: $e');
    }
  }

  // ===== Session Management =====

  /// Sign out from Firebase and Google
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw FirebaseAuthServiceException('Sign out failed: $e');
    }
  }

  /// Get current user's ID token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentUser;
      if (user == null) return null;

      return await user.getIdToken(forceRefresh);
    } catch (e) {
      throw FirebaseAuthServiceException('Failed to get ID token: $e');
    }
  }

  /// Refresh current user
  Future<void> reloadUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      throw FirebaseAuthServiceException('Failed to reload user: $e');
    }
  }

  // ===== Profile Management =====

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('No user signed in');
      }

      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Profile update failed');
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Unexpected error updating profile: $e',
      );
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('No user signed in');
      }

      await user.updateEmail(newEmail);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Email update failed');
    } catch (e) {
      throw FirebaseAuthServiceException('Unexpected error updating email: $e');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('No user signed in');
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Password update failed');
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Unexpected error updating password: $e',
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e, 'Password reset failed');
    } catch (e) {
      throw FirebaseAuthServiceException(
        'Unexpected error sending password reset: $e',
      );
    }
  }

  // ===== Error Handling =====

  FirebaseAuthServiceException _handleFirebaseAuthException(
    FirebaseAuthException e,
    String operation,
  ) {
    String message;
    String code = e.code;

    switch (e.code) {
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản với email này';
        break;
      case 'wrong-password':
        message = 'Mật khẩu không chính xác';
        break;
      case 'email-already-in-use':
        message = 'Email này đã được sử dụng';
        break;
      case 'weak-password':
        message = 'Mật khẩu quá yếu';
        break;
      case 'invalid-email':
        message = 'Email không hợp lệ';
        break;
      case 'user-disabled':
        message = 'Tài khoản đã bị vô hiệu hóa';
        break;
      case 'too-many-requests':
        message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
        break;
      case 'operation-not-allowed':
        message = 'Phương thức đăng nhập này không được phép';
        break;
      default:
        message = e.message ?? '$operation: Unknown error';
    }

    return FirebaseAuthServiceException(message, code: code);
  }
}

extension on User {
  updateEmail(String newEmail) {}
}

/// Exception cho Firebase Auth operations
class FirebaseAuthServiceException implements Exception {
  final String message;
  final String? code;

  const FirebaseAuthServiceException(this.message, {this.code});

  @override
  String toString() {
    return 'FirebaseAuthServiceException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}
