import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agro_care_app/services/auth_services.dart';

import '../../model/status_model.dart';
import '../../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordMatching = true;
  bool _isLoading = false;

  late MyAuthProvider auth;

  @override
  void initState() {
    super.initState();
    auth = context.read();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Status status = await _authService.updatePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      if (status.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${status.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<MyAuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Change Password',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(auth.userPhotoUrl),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              auth.userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              auth.userEmail,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Old Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your old password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _isPasswordMatching =
                                value == _confirmPasswordController.text;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm New Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _isPasswordMatching =
                                value == _newPasswordController.text;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      if (!_isPasswordMatching)
                        const Text(
                          'Passwords do not match',
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: FilledButton.tonal(
                          onPressed: () => _updatePassword(),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator())
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
