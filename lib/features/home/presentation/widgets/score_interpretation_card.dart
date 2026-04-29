import 'package:flutter/material.dart';
import 'score_indicator.dart';

class ScoreInterpretationCard extends StatelessWidget {
  const ScoreInterpretationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score Interpretation',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const ScoreIndicator(range: '80-100', label: 'Excellent', color: Colors.green),
        const SizedBox(height: 8),
        const ScoreIndicator(range: '60-79', label: 'Fair', color: Colors.orange),
        const SizedBox(height: 8),
        const ScoreIndicator(range: '0-59', label: 'Poor', color: Colors.red),
      ],
    );
  }
}
