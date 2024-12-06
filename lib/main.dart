import 'package:agro_care_app/firebase_options.dart';
import 'package:agro_care_app/providers/active_nav_provider.dart';
import 'package:agro_care_app/screens/dashboard_screen.dart';
import 'package:agro_care_app/screens/intro_screen.dart';
import 'package:agro_care_app/screens/splash_screen.dart';
import 'package:agro_care_app/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/profile/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
}

FirebaseAnalytics analytics = FirebaseAnalytics.instance;
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

final GoRouter _router = GoRouter(
  observers: [observer],
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/auth/:mode',
      builder: (context, state) =>
          AuthScreen(mode: state.pathParameters['mode'] ?? 'login'),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashBoardScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActiveNavProvider>(
            create: (context) => ActiveNavProvider()),
        ChangeNotifierProvider<MyAuthProvider>(
            create: (context) => MyAuthProvider())
      ],
      child: MaterialApp.router(
        title: 'Agro Care',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
