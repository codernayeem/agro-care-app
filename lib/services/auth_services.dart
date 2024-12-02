import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/status_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Status> emailSignIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Status.success();
    } catch (e) {
      print("Error signing in with email: $e");
      return Status.fail(message: e.toString());
    }
  }

  Future<Status> emailSignUp(String email, String password, String name) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      return Status.success();
    } catch (e) {
      print("Error signing in with email: $e");
      return Status.fail(message: e.toString());
    }
  }

  Future<Status> handleGoogleSignIn() async {
    await _googleSignIn.signOut();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      await _auth.signInWithCredential(googleAuthCredential);
      return Status.success();
    } catch (e) {
      print("Error signing in with Google: $e");
      return Status.fail(message: e.toString());
    }
  }

  Future<Status> handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
      return Status.success();
    } catch (e) {
      print("Error signing out: $e");
      return Status.fail(message: e.toString());
    }
  }
}
