import 'package:agro_care_app/providers/auth_provider.dart';
import 'package:agro_care_app/services/auth_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../market/order_list_screen.dart';
import 'auth_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService _authService = AuthService();

  void _logout(BuildContext context) async {
    await _authService.handleSignOut();
  }

  void _editProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<MyAuthProvider>(
          builder: (context, auth, child) {
            return auth.isAuthenticated
                ? Column(
                    children: [
                      _buildProfile(auth),
                      const SizedBox(height: 24),
                      _buildSettings(context),
                    ],
                  )
                : const AuthScreen(mode: 'login');
          },
        ),
      ),
    );
  }

  Widget _buildProfile(auth) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: -45,
          child: Lottie.asset(
            'assets/anim/autumn_plant.json',
            width: 180,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            // bouncing
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            auth.userPhotoUrl,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  auth.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  auth.userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Column(
      children: [
        _listTile(
          'Edit Profile',
          'Update your personal information',
          () {
            _editProfile(context);
          },
          "assets/icons/profile.png",
        ),
        _listTile(
          'Change Password',
          'Set a new password',
          () {
            _changePassword(context);
          },
          "assets/icons/edit.png",
        ),
        _listTile(
          'Your Orders',
          'View your order history',
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderListScreen(),
              ),
            );
          },
          "assets/icons/orders.png",
        ),
        _listTile(
          'Logout',
          'Sign out of your account',
          () {
            _logout(context);
          },
          "assets/icons/logout.png",
          color: const Color.fromARGB(255, 114, 26, 34),
        ),

        // disclaimer
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text(
                  'Agro Care App v1.0.0',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'By @codernayeem',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listTile(
    String title,
    String subTitle,
    void Function() onTap,
    String image, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        dense: true,
        title: Text(title),
        subtitle: Text(subTitle),
        onTap: onTap,
        leading: Image.asset(
          image,
          width: 28,
          color: color ?? Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        tileColor: Colors.grey.shade300.withOpacity(0.5),
        focusColor: Colors.grey[200],
        hoverColor: Colors.grey[200],
      ),
    );
  }
}
