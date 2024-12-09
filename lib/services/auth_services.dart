import 'package:agro_care_app/services/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../model/status_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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
      print("User created: ${userCredential.user?.uid} : " + name);
      var currentUser = FirebaseAuth.instance.currentUser;
      await currentUser!.updateDisplayName(name);
      FireStoreServices.publicUserData(_auth.currentUser!.uid).set({
        "email": email,
        "name": name,
        "photoUrl": _auth.currentUser!.photoURL,
      });
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

      FireStoreServices.publicUserData(_auth.currentUser!.uid).set({
        "email": _auth.currentUser!.email,
        "name": _auth.currentUser!.displayName,
        "photoUrl": _auth.currentUser!.photoURL,
      });

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

  Future<Status> updateProfile({String? name, File? image}) async {
    bool updated = false;
    try {
      final user = _auth.currentUser;
      if (name != null && name.isNotEmpty && name != user?.displayName) {
        await user?.updateDisplayName(name);
        await FireStoreServices.publicUserData(user!.uid)
            .update({"name": name});
        updated = true;
      }
      if (image != null) {
        final photoUrl = await uploadImage(image);
        await user?.updatePhotoURL(photoUrl);
        await FireStoreServices.publicUserData(user!.uid)
            .update({"photoUrl": photoUrl});
        updated = true;
      }
      if (!updated) {
        return Status.success(message: "No changes detected");
      }
      return Status.success();
    } catch (e) {
      print("Error updating profile: $e");
      return Status.fail(message: e.toString());
    }
  }

  Future<String> uploadImage(File image) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No user signed in");
    }

    final storageRef = FirebaseStorage.instance.ref();
    final profileImagesRef = storageRef.child('profile_images/${user.uid}.jpg');

    final uploadTask = profileImagesRef.putFile(File(image.path));
    final snapshot = await uploadTask.whenComplete(() => null);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<Status> updatePassword(String oldPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user signed in");
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return Status.success();
    } catch (e) {
      print("Error updating password: $e");
      return Status.fail(message: e.toString());
    }
  }
}
