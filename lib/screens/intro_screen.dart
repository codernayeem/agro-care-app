import 'dart:async';

import 'package:agro_care_app/theme/colors.dart';
import 'package:agro_care_app/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final List<Map<String, String>> featureSlides = [
    {
      "title": "Scan Leaves for Diseases",
      "description": "Detect crop diseases instantly with our AI-powered tool.",
      "image": "assets/anim/leaf_scan.json",
    },
    {
      "title": "Marketplace for Farmers",
      "description": "Buy and sell agro-products with ease.",
      "image": "assets/anim/cart.json",
    },
    {
      "title": "Gardening Advice",
      "description": "Get expert advice for your garden or rooftop plants.",
      "image": "assets/anim/gardening.json",
    },
  ];
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    _startAutoScroll();

    // Listen for manual page changes
    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        _currentPage = newPage;
        _resetAutoScroll();
      }
    });
  }

  /// Starts the auto-scroll timer
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % featureSlides.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Resets the auto-scroll timer
  void _resetAutoScroll() {
    _timer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    'Agro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  "assets/icon_128.png",
                  width: 40,
                ),
                const SizedBox(width: 4),
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    'Care',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Make your farming experience better",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                itemCount: featureSlides.length,
                controller: _pageController,
                itemBuilder: (context, index) {
                  final slide = featureSlides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(slide["image"]!, width: 200),
                      const SizedBox(height: 30),
                      Text(
                        slide["title"]!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          slide["description"]!,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SmoothPageIndicator(
              controller: _pageController,
              count: featureSlides.length,
              effect: const ExpandingDotsEffect(
                dotColor: Colors.grey,
                activeDotColor: AppColors.primaryColor,
                dotHeight: 10,
                dotWidth: 10,
                spacing: 10,
              ),
            ),

            const SizedBox(height: 30),

            // Bottom Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  authRow(context),
                  const SizedBox(height: 10),
                  MyButtons.filledButton2("Continue to App", () {
                    context.go('/dashboard');
                  }, color: Colors.grey.shade700),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget authRow(BuildContext context) {
    return Column(
      children: [
        MyButtons.filledButton1("Create an account", () {
          context.push('/auth/signup');
        }, icon: Icons.arrow_forward),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            Text("Already have an account?",
                style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.green[50],
              ),
              padding: EdgeInsets.zero,
              child: TextButton(
                onPressed: () {
                  context.push('/auth/login');
                },
                child: Text(
                  "Login",
                  style: TextStyle(fontSize: 16, color: Colors.green[800]),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
