import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoveButton extends StatefulWidget {
  const LoveButton({super.key});

  @override
  State<LoveButton> createState() => _LoveButtonState();
}

class _LoveButtonState extends State<LoveButton>
    with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    isLiked = !isLiked;
    if (isLiked) {
      _controller.forward(from: 0.2);
    } else {
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleLike,
      child: LottieBuilder.asset(
        'assets/anim/heart.json',
        controller: _controller,
        width: 32,
        height: 32,
        onLoaded: (composition) {
          _controller.value = isLiked ? 1.0 : 0.0;
        },
      ),
    );
  }
}
