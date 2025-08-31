// Firebase Auth Service - Handle Firebase Authentication
// Separate from API auth service

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth/entities/user_entity.dart';
import '../models/auth/entities/user_role.dart';
import '../models/auth/mappers/app_user_mapper.dart';
import '../models/auth/mappers/user_mapper.dart';
import '../models/auth/dtos/google_login_request_dto.dart';
import 'auth_service.dart';

/// Firebase Auth Service Interface
abstract class FirebaseAuthServiceInterface {
  Future<User?> signInWithGoogle();
  Future<User?> signInWithEmailPassword(String email, String password);
  Future<User?> createUserWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<String?> getIdToken();
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
}

/// Firebase Auth Service Implementation
class FirebaseAuthService implements FirebaseAuthServiceInterface {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  // ===== Authentication State =====

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<String?> getIdToken() async {
    try {
      final user = currentUser;
      if (user == null) return null;
      
      return await user.getIdToken(true); // Force refresh
    } catch (e) {
      return null;
    }
  }

  // ===== Google Sign In =====

  @override
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw FirebaseAuthServiceException('Google sign in failed: $e');
    }
  }

  // ===== Email/Password Authentication =====

  @override
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthServiceException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw FirebaseAuthServiceException('Email sign in failed: $e');
    }
  }

  @override
  Future<User?> createUserWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthServiceException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw FirebaseAuthServiceException('Email registration failed: $e');
    }
  }

  // ===== Password Management =====

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthServiceException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw FirebaseAuthServiceException('Password reset failed: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw FirebaseAuthServiceException('No user signed in');
      }
      
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthServiceException(_getFirebaseErrorMessage(e));
    } catch (e) {
      throw FirebaseAuthServiceException('Email verification failed: $e');
    }
  }

  // ===== Sign Out =====

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw FirebaseAuthServiceException('Sign out failed: $e');
    }
  }

  // ===== Helper Methods =====

  /// Convert Firebase User to UserEntity
  UserEntity? firebaseUserToEntity(User? firebaseUser) {
    if (firebaseUser == null) return null;
    
    return AppUserMapper.fromFirebase(firebaseUser) as UserEntity?;
  }

  /// Get user-friendly error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

/// Firebase Auth Service Exception
class FirebaseAuthServiceException implements Exception {
  final String message;

  const FirebaseAuthServiceException(this.message);

  @override
  String toString() => 'FirebaseAuthServiceException: $message';
}

/// Hybrid Auth Result - combines Firebase and API auth
class HybridAuthResult {
  final User? firebaseUser;
  final UserEntity? apiUser;
  final String? idToken;
  final bool isSuccess;
  final String? errorMessage;

  const HybridAuthResult({
    this.firebaseUser,
    this.apiUser,
    this.idToken,
    required this.isSuccess,
    this.errorMessage,
  });

  factory HybridAuthResult.success({
    required User firebaseUser,
    required UserEntity apiUser,
    required String idToken,
  }) {
    return HybridAuthResult(
      firebaseUser: firebaseUser,
      apiUser: apiUser,
      idToken: idToken,
      isSuccess: true,
    );
  }

  factory HybridAuthResult.failure(String errorMessage) {
    return HybridAuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

/// Hybrid Auth Service - combines Firebase + API auth
class HybridAuthService {
  final FirebaseAuthService _firebaseAuth;
  final AuthServiceInterface _apiAuth;

  HybridAuthService({
    required FirebaseAuthService firebaseAuth,
    required AuthServiceInterface apiAuth,
  }) : _firebaseAuth = firebaseAuth,
       _apiAuth = apiAuth;

  /// Google Sign In with both Firebase and API
  Future<HybridAuthResult> signInWithGoogle(UserRole role) async {
    try {
      // 1. Sign in with Firebase
      final firebaseUser = await _firebaseAuth.signInWithGoogle();
      if (firebaseUser == null) {
        return HybridAuthResult.failure('Google sign in cancelled');
      }

      // 2. Get ID token
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        return HybridAuthResult.failure('Failed to get ID token');
      }

      // 3. Sign in with API using ID token
      final googleRequest = GoogleLoginRequestDto(
        idToken: idToken,
        role: role.toString().split('.').last,
      );
      
      final apiResponse = await _apiAuth.loginWithGoogle(googleRequest);
      final apiUser = UserMapper.userFromDto(apiResponse.user) as UserEntity;

      return HybridAuthResult.success(
        firebaseUser: firebaseUser,
        apiUser: apiUser,
        idToken: idToken,
      );
    } catch (e) {
      return HybridAuthResult.failure('Hybrid auth failed: $e');
    }
  }
}
