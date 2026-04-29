import 'package:flutter/material.dart';

class CalculateButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const CalculateButton({
    super.key,
    required this.isEnabled,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Calculate VMAF'),
    );
  }
}
