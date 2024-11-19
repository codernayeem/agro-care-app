import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text((mode == 'login') ? 'Login' : 'Sign Up'),
      ),
    );
  }
}
