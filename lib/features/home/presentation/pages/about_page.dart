import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What is VMAF?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'VMAF (Video Multimethod Assessment Fusion) is a '
              'objective video quality metric developed by Netflix that '
              'predicts how humans perceive video quality. It uses a '
              'machine-learning model to combine multiple metrics and '
              'produce a score from 0-100.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'VMAF compares a "distorted" (encoded) video against a '
              '"reference" (original) video to measure how much quality '
              'was lost during encoding.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Score Interpretation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildScoreIndicator('80-100', 'Excellent', Colors.green),
            const SizedBox(height: 8),
            _buildScoreIndicator('60-79', 'Fair', Colors.orange),
            const SizedBox(height: 8),
            _buildScoreIndicator('0-59', 'Poor', Colors.red),
            const SizedBox(height: 24),
            const Text(
              'How This App Works',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app uses FFmpeg with the libvmaf filter to calculate '
              'VMAF scores. You select an original (reference) video and '
              'an encoded (distorted) video, and the app runs the VMAF '
              'computation using FFmpeg.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'App Version',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flutter VMAF v1.0.0',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            const Text(
              'Licenses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This application uses the following open source packages:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildLicenseSection(
              'flutter_bloc',
              'BSD-3-Clause',
              'https://github.com/felangel/flutter_bloc',
            ),
            _buildLicenseSection(
              'Freezed',
              'MIT',
              'https://github.com/rrousselGit/freezed',
            ),
            _buildLicenseSection(
              'Dartz',
              'MIT',
              'https://github.com/spebbe/dartz',
            ),
            _buildLicenseSection(
              'GetIt',
              'MIT',
              'https://github.com/fluttercommunity/get_it',
            ),
            _buildLicenseSection(
              'File Picker',
              'MIT',
              'https://github.com/miguelpruivo/flutter_file_picker',
            ),
            _buildLicenseSection(
              'Equatable',
              'MIT',
              'https://github.com/felangel/equatable',
            ),
            _buildLicenseSection(
              'Path Provider',
              'MIT',
              'https://github.com/flutter/plugins',
            ),
            _buildLicenseSection(
              'JSON Serializable',
              'MIT',
              'https://github.com/google/json_serializable.dart',
            ),
            const SizedBox(height: 24),
            const Text(
              'FFmpeg & libvmaf',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app requires FFmpeg to be installed. FFmpeg is free '
              'software licensed under LGPL/GPL. The libvmaf filter used '
              'for VMAF calculation is licensed under the BSD-3-Clause '
              'license (see: https://github.com/Netflix/vmaf).',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'When distributing this application, you may need to '
              'consider how FFmpeg is distributed with your app. If you '
              'bundle FFmpeg, check the FFmpeg licensing page for details.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'FFmpeg Licensing: https://ffmpeg.org/legal.html',
              style: TextStyle(fontSize: 15, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String range, String label, Color color) {
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

  Widget _buildLicenseSection(String package, String license, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              package,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '$license\n$url',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}