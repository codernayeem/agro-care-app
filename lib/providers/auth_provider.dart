import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isAuthenticated = false;
  String? userId;
  String userName = "";
  String userEmail = "";
  String userPhotoUrl = "";

  void initialize() {
    setUserDetails();

    _auth.authStateChanges().listen((User? user) {
      setUserDetails();
      notifyListeners();
    });
  }

  void setUserDetails() {
    if (_auth.currentUser == null) {
      isAuthenticated = false;
      return;
    }
    var user = _auth.currentUser!;
    userId = user.uid;
    userName = user.displayName ?? "";
    userEmail = user.email ?? "";
    userPhotoUrl = user.photoURL ?? "";
    isAuthenticated = true;
  }

  void update() {
    setUserDetails();
    notifyListeners();
  }
}
