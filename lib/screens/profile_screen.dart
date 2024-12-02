import 'package:agro_care_app/providers/auth_provider.dart';
import 'package:agro_care_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<MyAuthProvider>(
        builder: (context, auth, child) {
          return Center(
            child: auth.isAuthenticated
                ? ElevatedButton(
                    onPressed: () async {
                      if ((await _authService.handleSignOut()).success)
                        context.go('/intro');
                    },
                    child: const Text('Logout'),
                  )
                : ElevatedButton(
                    onPressed: () {
                      context.push('/auth/login');
                    },
                    child: const Text('Login'),
                  ),
          );
        },
      ),
    );
  }
}
