import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agro_care_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isAuthenticated = false;
  String? userId;

  void initialize() {
    isAuthenticated = _authService.auth.currentUser != null;
    userId = _authService.auth.currentUser?.uid;

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      User? user =
          await _authService.signInWithEmailAndPassword(email, password);
      isAuthenticated = true;
      notifyListeners();
    } catch (error) {
      isAuthenticated = false;
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      // _userId = await _authService.signup(email, password);
      isAuthenticated = true;
      notifyListeners();
    } catch (error) {
      isAuthenticated = false;
      throw error;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    isAuthenticated = false;
    userId = null;
    notifyListeners();
  }
}
