import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:sharexev2/data/models/auth/app_user.dart';
import 'package:sharexev2/data/models/auth/mappers/app_user_mapper.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  /// Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google sign in cancelled');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final fb_auth.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final fb_auth.User? user = userCredential.user;

      if (user != null) {
        // Convert Firebase user to AppUser
        return AppUserMapper.fromFirebase(user);
      }

      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      print('Signed out from Google and Firebase');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Check if user is signed in
  Future<bool> get isSignedIn => _googleSignIn.isSignedIn();

  /// Get current Google user
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('Error getting current Google user: $e');
      return null;
    }
  }

  /// Get user profile information
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      if (user != null) {
        return {
          'id': user.id,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoUrl,
          'serverAuthCode': user.serverAuthCode,
        };
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Check if Google Play Services are available
  Future<bool> isGooglePlayServicesAvailable() async {
    try {
      // TODO: Implement Google Play Services availability check
      // For now, return true
      return true;
    } catch (e) {
      print('Error checking Google Play Services: $e');
      return false;
    }
  }

  /// Request additional scopes
  Future<bool> requestScopes(List<String> scopes) async {
    try {
      // TODO: Implement scope request
      // For now, return true
      return true;
    } catch (e) {
      print('Error requesting scopes: $e');
      return false;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      if (user != null) {
        final GoogleSignInAuthentication auth = await user.authentication;
        return auth.accessToken;
      }
      return null;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  /// Get ID token
  Future<String?> getIdToken() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signInSilently();
      if (user != null) {
        final GoogleSignInAuthentication auth = await user.authentication;
        return auth.idToken;
      }
      return null;
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  /// Disconnect from Google
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      print('Disconnected from Google');
    } catch (e) {
      print('Error disconnecting from Google: $e');
    }
  }
}
