import 'package:agro_care_app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({super.key});

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

  final PageController _pageController = PageController();

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
                Image.asset(
                  "assets/icon_128.png",
                  width: 40,
                ),
                const SizedBox(width: 10),
                Material(
                  type: MaterialType.transparency,
                  child: Text(
                    'Agro Care',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ],
            ),
            // Feature Slider
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

            const SizedBox(height: 20),

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
                  authRow(context),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/dashboard');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(50), // Full width
                    ),
                    child: const Text(
                      "Continue to App",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            context.push('/auth/login');
          },
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ),
        const Text("|", style: TextStyle(fontSize: 16)),
        TextButton(
          onPressed: () {
            context.push('/auth/signup');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ),
      ],
    );
  }
}
