import 'package:agro_care_app/providers/auth_provider.dart';
import 'package:agro_care_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void startChecking() async {
    MyAuthProvider authProvider = context.read();
    authProvider.initialize();
    CartProvider cartProvider = context.read();
    cartProvider.getCount();

    Future.delayed(const Duration(milliseconds: 1000)).then((value) async {
      if (await checkFirstTime()) {
        context.go('/intro');
      } else {
        context.go('/dashboard');
      }
    });
  }

  Future<bool> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
    }

    return isFirstTime;
  }

  @override
  void initState() {
    super.initState();
    startChecking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icon_128.png",
              width: 86,
            ),
            const SizedBox(height: 10),
            const Material(
              type: MaterialType.transparency,
              child: Text(
                'Agro Care',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              'আপনার ফসলকে ডাক্তার দেখান',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Jolchobi',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
