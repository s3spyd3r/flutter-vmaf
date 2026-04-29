import 'package:flutter/material.dart';

class AboutInfoSection extends StatelessWidget {
  final String title;
  final String content;
  final double titleFontSize;
  final double contentFontSize;

  const AboutInfoSection({
    super.key,
    required this.title,
    required this.content,
    this.titleFontSize = 20,
    this.contentFontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(fontSize: contentFontSize, height: 1.5),
        ),
      ],
    );
  }
}
