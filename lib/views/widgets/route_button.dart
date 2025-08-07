import 'package:flutter/material.dart';

class RouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;

  const RouteButton({
    required this.onPressed,
    required this.isVisible,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Positioned(
        bottom: 16.0,
        left: 16.0,
        right: 16.0,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.alt_route),
          label: const Text('Start Route'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
