import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> handleGoogleSignIn() async {
    await _googleSignIn.signOut();
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      // Create a new credential using the Google Sign In authentication
      final googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in to Firebase with the Google Auth credentials
      await _auth.signInWithCredential(googleAuthCredential);
      return true;
    } catch (e) {
      print("Error signing in with Google: $e");
      return false;
    }
  }

  void handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }
}
