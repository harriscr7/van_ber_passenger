import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  String? error;

  FirebaseAuthService() {
    _configurePersistence();
  }

  // Configure Firebase Auth persistence
  void _configurePersistence() {
    // Firebase Auth automatically persists authentication state
    // This is enabled by default on mobile platforms
    // The user will remain signed in until they explicitly sign out
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Initialize with your server client ID
      await _googleSignIn.initialize(
        serverClientId:
            "560965488283-0sgrss9a07q5l810vr2raf53njtn7e7i.apps.googleusercontent.com",
      );

      // Start Google authentication
      final account = await _googleSignIn.authenticate();

      // Get ID token
      final googleAuth = account.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      error = e.toString();
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();
      
      // Sign out from Google (if user was signed in with Google)
      await _googleSignIn.signOut();
      
      print('User signed out successfully');
    } catch (e) {
      error = e.toString();
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get authentication state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user changes stream (includes profile updates)
  Stream<User?> get userChanges => _auth.userChanges();
}
