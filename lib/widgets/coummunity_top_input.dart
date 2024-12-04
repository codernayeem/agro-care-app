import 'package:flutter/material.dart';

class CommunityTopBar extends StatefulWidget {
  const CommunityTopBar({super.key});

  @override
  State<CommunityTopBar> createState() => _CommunityTopBarState();
}

class _CommunityTopBarState extends State<CommunityTopBar> {
  final List<String> hints = [
    "Help others with your insight...",
    "Share your ideas and thoughts...",
    "Build your network, grow more...",
    "Connect, inspire, and create ...",
    "Learn, share, and grow daily ...",
  ];
  int _currentHintIndex = 0;

  @override
  void initState() {
    super.initState();
    _startHintRotation();
  }

  void _startHintRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % hints.length;
        });
        _startHintRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation = Tween<Offset>(
                begin: child.key == ValueKey<int>(_currentHintIndex)
                    ? const Offset(0, 1)
                    : const Offset(0, -1),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: offsetAnimation,
                  child: child,
                ),
              );
            },
            child: Text(
              hints[_currentHintIndex],
              key: ValueKey<int>(_currentHintIndex),
              style: const TextStyle(color: Colors.black54, fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }
}
