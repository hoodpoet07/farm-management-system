import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double interval) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {

        double value =
            (_controller.value + interval) % 1.0;

        double opacity;

        if (value < 0.33) {
          opacity = 0.3;
        } else if (value < 0.66) {
          opacity = 0.6;
        } else {
          opacity = 1.0;
        }

        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            const CircleAvatar(
              radius: 16,
              child: Icon(
                Icons.smart_toy,
                size: 18,
              ),
            ),

            const SizedBox(width: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  _dot(0),

                  _dot(0.3),

                  _dot(0.6),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}