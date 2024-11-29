import 'package:agro_care_app/services/auth_services.dart';
import 'package:agro_care_app/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../widgets/buttons.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.mode});

  final String mode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPwdController = TextEditingController();

  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPwdController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  var loading = false;

  void afterScuccess() {
    context.go('/dashboard');
  }

  void emailSignUp() async {
    if (loading) return;
    String email = _signupEmailController.text.trim();
    String password = _signupPwdController.text.trim();
    String name = _nameController.text.trim();

    if (email.isEmpty) {
      showSnackBar("Email can't be empty");
      return;
    } else if (password.isEmpty) {
      showSnackBar("Password can't be empty");
      return;
    } else if (name.isEmpty) {
      showSnackBar("Name can't be empty");
      return;
    } else if (name.length <= 2) {
      showSnackBar("Name should be consists of two or more letters");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      afterScuccess();
    } catch (e) {
      showSnackBar(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  void emailSignIn() async {
    if (loading) return;
    String email = _loginEmailController.text.trim();
    String password = _loginPwdController.text.trim();

    if (email.isEmpty) {
      showSnackBar("Email can't be empty");
      return;
    } else if (password.isEmpty) {
      showSnackBar("Password can't be empty");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      afterScuccess();
    } catch (e) {
      showSnackBar(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  void onForgotPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController emailController = TextEditingController();
        return AlertDialog(
          title: const Text('Forgot Password'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          content: SizedBox(
            width: double.infinity,
            height: 100,
            child: TextFieldWithLabel(
                controller: emailController,
                hint: "abcd@gmail.com",
                label: 'Email',
                icon: Icons.email_outlined),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Send Reset Link'),
              onPressed: () async {
                String email = emailController.text.trim();
                if (email.isEmpty) {
                  showSnackBar("Email can't be empty");
                  return;
                }
                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  Navigator.of(context).pop();
                  showSnackBar("Password reset link sent to $email");
                } catch (e) {
                  showSnackBar(e.toString());
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(initialPage: (widget.mode == 'login') ? 0 : 1);

    Widget loginView = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              style: TextStyle(
                  fontSize: 28,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login to continue',
              style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            TextFieldWithLabel(
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'Enter your email',
              controller: _loginEmailController,
            ),
            const SizedBox(height: 16),
            TextFieldWithLabel(
              label: 'Password',
              icon: Icons.lock_outline,
              hint: 'Enter your password',
              obscureText: true,
              controller: _loginPwdController,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: MyButtons.filledButton1(
                "Login",
                emailSignIn,
                loading: loading,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onForgotPassword,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryColor.withOpacity(.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            MyButtons.filledButton2(
              'Continue with Google',
              () async {
                if (await _authService.handleGoogleSignIn()) {
                  afterScuccess();
                }
              },
              icon: SvgPicture.asset('assets/svg/google.svg', width: 24),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor.withOpacity(.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    Widget signUpView = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Create Account',
              style: TextStyle(
                  fontSize: 28,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign up to get started',
              style: TextStyle(fontSize: 16, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 24),
            TextFieldWithLabel(
              label: 'Name',
              icon: Icons.person_outline,
              hint: 'Enter your name',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            TextFieldWithLabel(
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'Enter your email',
              controller: _signupEmailController,
            ),
            const SizedBox(height: 16),
            TextFieldWithLabel(
              label: 'Password',
              icon: Icons.lock_outline,
              hint: 'Enter your password',
              obscureText: true,
              controller: _signupPwdController,
            ),
            const SizedBox(height: 24),
            MyButtons.filledButton1(
              "Sign Up",
              emailSignUp,
              loading: loading,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            MyButtons.filledButton2(
              'Continue with Google',
              () async {
                if (await _authService.handleGoogleSignIn()) {
                  afterScuccess();
                }
              },
              icon: SvgPicture.asset('assets/svg/google.svg', width: 24),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor.withOpacity(.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [loginView, signUpView],
        ),
      ),
    );
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }
}

class TextFieldWithLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final TextEditingController controller;

  const TextFieldWithLabel({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        hasFocus ? AppColors.primaryColor : Colors.transparent,
                    width: 2,
                  ),
                  color: Colors.grey.shade200,
                ),
                child: TextField(
                  obscureText: obscureText,
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon),
                    hintText: hint,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                    border: InputBorder.none,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
