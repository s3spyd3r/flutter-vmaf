import 'package:flutter/material.dart';

class ScoreIndicator extends StatelessWidget {
  final String range;
  final String label;
  final Color color;

  const ScoreIndicator({
    super.key,
    required this.range,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$range: $label',
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
