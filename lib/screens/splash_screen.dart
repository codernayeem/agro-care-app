import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Function to start after 900 milliseconds
  void startChecking() async {
    Future.delayed(const Duration(milliseconds: 900)).then((value) async {
      if (await checkFirstTime()) {
        context.go('/intro');
      } else {
        context.go('/dashboard');
      }
    });
  }

  Future<bool> checkFirstTime() async {
    if (!Hive.isBoxOpen('myBox')) {
      await Hive.openBox('myBox');
    }
    var box = Hive.box('myBox');

    bool firstTime = box.get('firstTime', defaultValue: false);
    return firstTime;
  }

  @override
  void initState() {
    super.initState();
    startChecking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: "top_bar",
        child: Container(
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
                    fontFamily: 'Lexend',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Material(
                type: MaterialType.transparency,
                child: Text(
                  'আপনার ফসলকে ডাক্তার দেখান',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Jolchobi',
                    fontWeight: FontWeight.w700,
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
